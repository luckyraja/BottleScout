import SwiftUI
import SwiftData
import OSLog

private let addBottleLog = Logger(subsystem: "com.bottlescout.app", category: "AddBottleView")

// MARK: - AddBottleView

enum ImageSource {
    case camera
    case photoLibrary
}

struct AddBottleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var capturedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var imageSource: ImageSource
    @State private var isAnalyzing = false
    @State private var analysisResult: BottleAnalysisResult?
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var showingSettings = false
    @State private var persistedBottle: BottleEntry?

    var onDismiss: (() -> Void)? = nil

    init(initialImage: UIImage? = nil, initialImageSource: ImageSource = .camera, onDismiss: (() -> Void)? = nil) {
        _capturedImage = State(initialValue: initialImage)
        _imageSource = State(initialValue: initialImageSource)
        self.onDismiss = onDismiss
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let image = capturedImage {
                    imagePreview(image)
                } else {
                    imagePlaceholder
                }

                if isAnalyzing {
                    analyzingView
                } else if let result = analysisResult {
                    analysisResultView(result)
                } else if let errorMessage {
                    errorStateView(message: errorMessage)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color.surface.ignoresSafeArea())
        .navigationTitle("Bottle Review")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingImagePicker) {
            Group {
                if imageSource == .camera {
                    CameraView(image: $capturedImage, sourceType: .camera)
                } else {
                    ImagePickerView(image: $capturedImage)
                }
            }
            .background(.ultraThinMaterial)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let error = errorMessage {
                Text(error)
            }
        }
        .onChange(of: capturedImage) { _, newValue in
            persistedBottle = nil
            if newValue != nil {
                analyzeImage()
            }
        }
        .onChange(of: showingSettings) { _, isPresented in
            guard !isPresented, capturedImage != nil, analysisResult == nil else { return }
            analyzeImage()
        }
        .task {
            if capturedImage != nil && analysisResult == nil && !isAnalyzing {
                analyzeImage()
            }
        }
    }

    // MARK: - Placeholder View

    private var imagePlaceholder: some View {
        VStack(spacing: 20) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.surfaceContainerLow)
                .frame(height: 260)
                .overlay {
                    VStack(spacing: 12) {
                        Image(systemName: "camera")
                            .font(.system(size: 42))
                            .foregroundStyle(.secondary)
                        Text("Take a photo of the bottle label")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                }

            HStack(spacing: 12) {
                primaryActionButton(title: "Take Photo", systemImage: "camera") {
                    imageSource = .camera
                    showingImagePicker = true
                }
                secondaryActionButton(title: "Choose Photo", systemImage: "photo.on.rectangle") {
                    imageSource = .photoLibrary
                    showingImagePicker = true
                }
            }
        }
    }

    // MARK: - Image Preview View

    private func imagePreview(_ image: UIImage) -> some View {
        VStack(spacing: 12) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            HStack(spacing: 12) {
                secondaryActionButton(title: "Retake", systemImage: "camera") {
                    imageSource = .camera
                    showingImagePicker = true
                }
                secondaryActionButton(title: "Replace", systemImage: "photo") {
                    imageSource = .photoLibrary
                    showingImagePicker = true
                }
            }
        }
    }

    // MARK: - Analyzing View

    private var analyzingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Analyzing bottle…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Error State

    private func errorStateView(message: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Analysis Failed", systemImage: "exclamationmark.triangle.fill")
                .font(.headline)
                .foregroundStyle(.red)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                secondaryActionButton(title: "Settings", systemImage: "gearshape") {
                    showingSettings = true
                }
                primaryActionButton(title: "Try Again", systemImage: "arrow.clockwise") {
                    analyzeImage()
                }
                .disabled(isAnalyzing || capturedImage == nil)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Analysis Result View

    private func analysisResultView(_ result: BottleAnalysisResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(result.name)
                    .font(.title2.bold())
                    .fixedSize(horizontal: false, vertical: true)
                Text(result.alcoholType.capitalized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)

            VStack(spacing: 12) {
                resultRow(label: "Price Range", value: result.priceRange)
                resultBlock(label: "Tasting Notes", text: result.tastingNotes)
                resultBlock(label: "Pairing Notes", text: result.pairingNotes)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Confidence")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(result.confidenceNote)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(result.sourceNote)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 4)
            .padding(.top, 4)

            ownedCTA
                .padding(.top, 8)
        }
    }

    private func resultRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func resultBlock(label: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Text(text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Shared Button Styles

    private func primaryActionButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(LinearGradient.primaryButtonGradient)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func secondaryActionButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primaryColor)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(Color.surfaceContainerHigh)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Owned CTA

    private var ownedCTA: some View {
        let alreadyOwned = persistedBottle?.inCollection == true

        return Label(alreadyOwned ? "In Your Collection" : "Add to Collection",
                     systemImage: alreadyOwned ? "checkmark.circle.fill" : "plus.circle.fill")
            .font(.headline.weight(.semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(LinearGradient.primaryButtonGradient)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .opacity(alreadyOwned ? 0.7 : 1)
            .contentShape(Rectangle())
            .onTapGesture {
                guard !alreadyOwned else { return }
                addBottleLog.info("Add to Collection tapped. persistedBottle=\(self.persistedBottle == nil ? "nil" : "set") alreadyOwned=\(alreadyOwned)")
                markBottleOwned()
            }
    }

    // MARK: - Analyze Image

    private func analyzeImage() {
        guard let image = capturedImage else { return }

        isAnalyzing = true
        errorMessage = nil
        analysisResult = nil

        Task {
            do {
                let result = try await GeminiService().analyzeBottle(image: image)
                await MainActor.run {
                    addBottleLog.info("analyzeImage: Gemini succeeded for '\(result.name)'")
                    analysisResult = result
                    isAnalyzing = false
                    persistHistoryEntry(result: result, image: image)
                }
            } catch {
                await MainActor.run {
                    isAnalyzing = false
                    errorMessage = error.localizedDescription
                    if case GeminiError.invalidAPIKey = error {
                        showingError = false
                    } else {
                        showingError = true
                    }
                }
            }
        }
    }

    // MARK: - Persistence

    private func persistHistoryEntry(result: BottleAnalysisResult, image: UIImage) {
        let imageData = ImageProcessor.prepareForStorage(image)

        do {
            if let bottle = persistedBottle {
                bottle.name = result.name
                bottle.alcoholType = result.alcoholType
                bottle.tastingNotes = result.tastingNotes
                bottle.pairingNotes = result.pairingNotes
                bottle.priceRange = result.priceRange
                bottle.imageData = imageData
                addBottleLog.info("persistHistoryEntry: updated existing bottle '\(bottle.name)'")
            } else {
                let bottle = BottleEntry(
                    name: result.name,
                    alcoholType: result.alcoholType,
                    tastingNotes: result.tastingNotes,
                    pairingNotes: result.pairingNotes,
                    priceRange: result.priceRange,
                    imageData: imageData,
                    inCollection: false
                )

                modelContext.insert(bottle)
                persistedBottle = bottle
                addBottleLog.info("persistHistoryEntry: inserted new bottle '\(bottle.name)'")
            }

            try modelContext.save()
            addBottleLog.info("persistHistoryEntry: modelContext saved successfully")
        } catch {
            addBottleLog.error("persistHistoryEntry: save failed — \(error.localizedDescription)")
            errorMessage = "Unable to save this scan to history: \(error.localizedDescription)"
            showingError = true
        }
    }

    private func markBottleOwned() {
        addBottleLog.info("markBottleOwned: entered. analysisResult=\(self.analysisResult == nil ? "nil" : "set") capturedImage=\(self.capturedImage == nil ? "nil" : "set") persistedBottle=\(self.persistedBottle == nil ? "nil" : "set")")

        guard let result = analysisResult else {
            addBottleLog.error("markBottleOwned: aborting — analysisResult is nil")
            errorMessage = "No analysis result available to save."
            showingError = true
            return
        }

        do {
            let bottle: BottleEntry
            if let persistedBottle {
                bottle = persistedBottle
            } else {
                let imageData = capturedImage.flatMap { ImageProcessor.prepareForStorage($0) }
                let newBottle = BottleEntry(
                    name: result.name,
                    alcoholType: result.alcoholType,
                    tastingNotes: result.tastingNotes,
                    pairingNotes: result.pairingNotes,
                    priceRange: result.priceRange,
                    imageData: imageData,
                    inCollection: false
                )
                modelContext.insert(newBottle)
                persistedBottle = newBottle
                bottle = newBottle
                addBottleLog.info("markBottleOwned: created fallback bottle '\(newBottle.name)'")
            }

            bottle.inCollection = true
            try modelContext.save()
            addBottleLog.info("markBottleOwned: saved bottle '\(bottle.name)' as inCollection=true")
            if let onDismiss { onDismiss() } else { dismiss() }
        } catch {
            addBottleLog.error("markBottleOwned: save failed — \(error.localizedDescription)")
            errorMessage = "Unable to mark this bottle as owned: \(error.localizedDescription)"
            showingError = true
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AddBottleView()
    }
    .modelContainer(for: BottleEntry.self, inMemory: true)
}
