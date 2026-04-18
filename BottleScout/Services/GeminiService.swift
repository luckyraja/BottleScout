import UIKit

enum GeminiError: Error, LocalizedError {
    case invalidAPIKey
    case invalidImage
    case networkError(Error)
    case invalidResponse
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Missing Gemini API key. Add it in Settings before analyzing a bottle."
        case .invalidImage:
            return "Unable to process the image."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from API."
        case .apiError(let message):
            return "API error: \(message)"
        }
    }
}

struct BottleAnalysisResult {
    let name: String
    let alcoholType: String
    let tastingNotes: String
    let pairingNotes: String
    let priceRange: String
    let confidenceNote: String
    let sourceNote: String
    let rawResponse: String
}

struct GeminiService {
    private let apiKey: String
    private let endpoint: String

    init(apiKey: String = Config.geminiAPIKey, endpoint: String = Config.geminiAPIEndpoint) {
        self.apiKey = apiKey
        self.endpoint = endpoint
    }

    func analyzeBottle(image: UIImage) async throws -> BottleAnalysisResult {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty,
              trimmedKey != "YOUR_GEMINI_API_KEY_HERE",
              !trimmedKey.contains("$(GEMINI_API_KEY)") else {
            throw GeminiError.invalidAPIKey
        }

        guard let imageData = ImageProcessor.prepareForAPI(image) else {
            throw GeminiError.invalidImage
        }
        let base64String = ImageProcessor.toBase64(imageData)

        let urlString = "\(endpoint)?key=\(trimmedKey)"
        guard let url = URL(string: urlString) else {
            throw GeminiError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let prompt = """
        Identify the bottle from this label image and return strict JSON only.
        Required fields:
        {"name":"string","type":"wine|beer|spirits|other","priceRange":"string","tastingNotes":"string","pairingNotes":"string","confidenceNote":"high|medium|low","sourceNote":"string"}
        Keep every field non-empty. Use concise tasting and pairing notes. Use a short consumer price range like "$18-$25" when possible. If estimating, say so in sourceNote.
        """

        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt],
                        [
                            "inline_data": [
                                "mime_type": "image/jpeg",
                                "data": base64String
                            ]
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "response_mime_type": "application/json",
                "temperature": 0.2
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw GeminiError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if let errorMessage = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorMessage["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw GeminiError.apiError(message)
            }
            throw GeminiError.apiError("HTTP \(httpResponse.statusCode)")
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw GeminiError.invalidResponse
        }

        return parseAnalysisResult(from: text)
    }

    private func parseAnalysisResult(from text: String) -> BottleAnalysisResult {
        if let parsed = parseJSONResult(from: text) {
            return parsed
        }

        var name = "Unknown Bottle"
        var alcoholType = "other"
        var tastingNotes = "No tasting notes available."
        var pairingNotes = "No pairing suggestions available."
        var priceRange = "Price unavailable"

        let lines = text.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.lowercased().contains("name:") {
                name = extractValue(from: trimmed, after: "name:", fallback: name)
            } else if trimmed.lowercased().contains("type:") {
                alcoholType = extractValue(from: trimmed, after: "type:", fallback: alcoholType)
            } else if trimmed.lowercased().contains("tasting notes:") {
                tastingNotes = extractValue(from: trimmed, after: "tasting notes:", fallback: tastingNotes)
            } else if trimmed.lowercased().contains("pairing notes:") {
                pairingNotes = extractValue(from: trimmed, after: "pairing notes:", fallback: pairingNotes)
            } else if trimmed.lowercased().contains("price range:") {
                priceRange = extractValue(from: trimmed, after: "price range:", fallback: priceRange)
            }
        }

        return BottleAnalysisResult(
            name: name,
            alcoholType: alcoholType,
            tastingNotes: tastingNotes,
            pairingNotes: pairingNotes,
            priceRange: priceRange,
            confidenceNote: "low",
            sourceNote: "Fallback parse from unstructured model response.",
            rawResponse: text
        )
    }

    private func parseJSONResult(from text: String) -> BottleAnalysisResult? {
        let jsonString = extractJSONObject(from: text) ?? text
        guard let data = jsonString.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        func value(_ key: String, fallback: String) -> String {
            let raw = (obj[key] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
            if let raw, !raw.isEmpty {
                return raw
            }
            return fallback
        }

        return BottleAnalysisResult(
            name: value("name", fallback: "Unknown Bottle"),
            alcoholType: value("type", fallback: "other"),
            tastingNotes: value("tastingNotes", fallback: "No tasting notes available."),
            pairingNotes: value("pairingNotes", fallback: "No pairing suggestions available."),
            priceRange: value("priceRange", fallback: "Price unavailable"),
            confidenceNote: value("confidenceNote", fallback: "medium"),
            sourceNote: value("sourceNote", fallback: "Model estimate; grounded references may be unavailable."),
            rawResponse: text
        )
    }

    private func extractJSONObject(from text: String) -> String? {
        if let fencedRange = text.range(of: "```json") {
            let afterFence = text[fencedRange.upperBound...]
            if let closing = afterFence.range(of: "```") {
                return String(afterFence[..<closing.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        guard let start = text.firstIndex(of: "{"),
              let end = text.lastIndex(of: "}") else {
            return nil
        }

        return String(text[start...end])
    }

    private func extractValue(from line: String, after prefix: String, fallback: String) -> String {
        guard let range = line.range(of: prefix, options: .caseInsensitive) else {
            return fallback
        }
        let value = line[range.upperBound...].trimmingCharacters(in: .whitespaces)
        return value.isEmpty ? fallback : value
    }
}
