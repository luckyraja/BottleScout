import SwiftUI
import SwiftData

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

    init(initialImage: UIImage? = nil, initialImageSource: ImageSource = .camera) {
        _capturedImage = State(initialValue: initialImage)
        _imageSource = State(initialValue: initialImageSource)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
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
            .padding(32)
        }
        .background(Color.surface.ignoresSafeArea())
        .navigationTitle("Bottle Review")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if analysisResult != nil && !isAnalyzing {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        markBottleOwned()
                    } label: {
                        Text("Owned")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundColor(.white)
                            .background(LinearGradient.primaryButtonGradient)
                            .cornerRadius(32)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 100)
                }
            }
        }
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
        VStack(spacing: 32) {
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.surfaceContainerLow)
                .frame(height: 250)
                .overlay {
                    VStack(spacing: 20) {
                        Image(systemName: "camera")
                            .font(.system(size: 50))
                            .foregroundColor(.secondaryText)
                        Text("Take a photo of the bottle label")
                            .font(.title3.bold())
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(32)
                }

            HStack(spacing: 16) {
                Button {
                    imageSource = .camera
                    showingImagePicker = true
                } label: {
                    Label("Take Photo", systemImage: "camera")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .background(LinearGradient.primaryButtonGradient)
                        .cornerRadius(32)
                }
                .buttonStyle(.plain)

                Button {
                    imageSource = .photoLibrary
                    showingImagePicker = true
                } label: {
                    Label("Choose Photo", systemImage: "photo.on.rectangle")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.primaryColor)
                        .background(Color.surfaceContainerHigh)
                        .cornerRadius(32)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Image Preview View

    private func imagePreview(_ image: UIImage) -> some View {
        VStack(spacing: 24) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .background(Color.surfaceContainerLow.cornerRadius(32))

            HStack(spacing: 16) {
                Button {
                    imageSource = .camera
                    showingImagePicker = true
                } label: {
                    Label("Retake", systemImage: "camera")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.primaryColor)
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)
                        .background(Color.surfaceContainerHigh.cornerRadius(32))
                }
                .buttonStyle(.plain)

                Button {
                    imageSource = .photoLibrary
                    showingImagePicker = true
                } label: {
                    Label("Use Photo", systemImage: "photo")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.primaryColor)
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)
                        .background(Color.surfaceContainerHigh.cornerRadius(32))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(24)
        .background(Color.surfaceContainerLow.cornerRadius(32))
    }

    // MARK: - Analyzing View

    private var analyzingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Analyzing bottle...")
                .font(.title3.bold())
                .foregroundColor(.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 56)
        .background(Color.surfaceContainerLow.cornerRadius(32))
    }

    private func errorStateView(message: String) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Label("Analysis Failed", systemImage: "exclamationmark.triangle.fill")
                .font(.title3.bold())
                .foregroundColor(.red)

            Text(message)
                .font(.body)
                .foregroundColor(.primaryText)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 16) {
                Button {
                    showingSettings = true
                } label: {
                    Label("Gemini Settings", systemImage: "gearshape")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.primaryColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.surfaceContainerHigh)
                        .cornerRadius(32)
                }
                .buttonStyle(.plain)

                Button {
                    analyzeImage()
                } label: {
                    Label("Try Again", systemImage: "arrow.clockwise")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(LinearGradient.primaryButtonGradient)
                        .cornerRadius(32)
                }
                .buttonStyle(.plain)
                .disabled(isAnalyzing || capturedImage == nil)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(32)
        .background(Color.surfaceContainerLow.cornerRadius(32))
    }

    // MARK: - Analysis Result View

    private func analysisResultView(_ result: BottleAnalysisResult) -> some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("ANALYSIS COMPLETE")
                .font(.largeTitle.bold())
                .foregroundColor(.primaryText)
                .textCase(.uppercase)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 24) {
                ResultField(label: "NAME", value: result.name)
                ResultField(label: "TYPE", value: result.alcoholType.capitalized)
                ResultField(label: "PRICE RANGE", value: result.priceRange)

                VStack(alignment: .leading, spacing: 12) {
                    Text("TASTING NOTES")
                        .font(.title3.bold())
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                        .padding(.bottom, 4)
                    Text(result.tastingNotes)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("PAIRING NOTES")
                        .font(.title3.bold())
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                        .padding(.bottom, 4)
                    Text(result.pairingNotes)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack {
                    Text("CONFIDENCE")
                        .font(.caption.bold())
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                    Spacer()
                    Text(result.confidenceNote)
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("SOURCE")
                        .font(.caption.bold())
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                    Text(result.sourceNote)
                        .font(.footnote)
                        .foregroundColor(.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(32)
            .background(Color.surfaceContainerHigh.cornerRadius(32))
        }
        .padding(24)
        .background(Color.surfaceContainerLow.cornerRadius(32))
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
            }

            try modelContext.save()
        } catch {
            errorMessage = "Unable to save this scan to history: \(error.localizedDescription)"
            showingError = true
        }
    }

    private func markBottleOwned() {
        guard let result = analysisResult,
              let image = capturedImage else { return }

        do {
            let bottle: BottleEntry
            if let persistedBottle {
                bottle = persistedBottle
            } else {
                let imageData = ImageProcessor.prepareForStorage(image)
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
            }

            bottle.inCollection = true
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Unable to mark this bottle as owned: \(error.localizedDescription)"
            showingError = true
        }
    }
}

// MARK: - ResultField View

struct ResultField: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption2.bold())
                .foregroundColor(.secondaryText)
                .textCase(.uppercase)
                .tracking(1.2)
            Text(value)
                .font(.body)
                .foregroundColor(.primaryText)
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
