import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var liveCamera = LiveCameraModel()
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingSettings = false
    @State private var imageSource: ImageSource = .camera
    @State private var showInventory = false
    @State private var showBottleReview = false

    var body: some View {
        NavigationStack {
            CameraHomeView(
                camera: liveCamera,
                onOpenCamera: {
                    imageSource = .camera
                    liveCamera.capturePhoto { image in
                        Task { @MainActor in
                            selectedImage = image
                        }
                    }
                },
                onOpenPhotos: {
                    imageSource = .photoLibrary
                    showingImagePicker = true
                },
                onOpenInventory: {
                    showInventory = true
                }
            )
            .navigationTitle("BottleScout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .navigationDestination(isPresented: $showInventory) {
                InventoryListView()
            }
            .navigationDestination(isPresented: $showBottleReview) {
                if let image = selectedImage {
                    AddBottleView(initialImage: image, initialImageSource: imageSource)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                if imageSource == .camera {
                    CameraView(image: $selectedImage, sourceType: .camera)
                } else {
                    ImagePickerView(image: $selectedImage)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .onChange(of: selectedImage) { _, newValue in
                if newValue != nil {
                    showBottleReview = true
                }
            }
            .onAppear {
                liveCamera.requestAccessAndConfigureIfNeeded()
                liveCamera.start()
            }
            .onDisappear {
                liveCamera.stop()
            }
        }
    }
}

private struct CameraHomeView: View {
    @ObservedObject var camera: LiveCameraModel
    let onOpenCamera: () -> Void
    let onOpenPhotos: () -> Void
    let onOpenInventory: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.04))
                .overlay {
                    Group {
                        if camera.authorizationDenied {
                            cameraPermissionView
                        } else if let setupError = camera.setupError {
                            cameraErrorView(setupError)
                        } else {
                            LiveCameraPreview(session: camera.session)
                                .overlay(alignment: .center) {
                                    RoundedRectangle(cornerRadius: 22)
                                        .stroke(Color.white.opacity(0.7), lineWidth: 3)
                                        .frame(width: 180, height: 240)
                                }
                                .overlay(alignment: .bottom) {
                                    Text("Capture a bottle label to start")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                        .padding(.bottom, 28)
                                        .shadow(radius: 8)
                                }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal)
                .padding(.bottom, 96)

            VStack {
                Spacer()
                HStack {
                    Button(action: onOpenPhotos) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                            .frame(width: 52, height: 52)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }

                    Spacer()

                    Button(action: onOpenCamera) {
                        ZStack {
                            Circle()
                                .fill(Color.accentColor)
                                .frame(width: 74, height: 74)
                            Image(systemName: "camera.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                        }
                    }
                    .accessibilityLabel("Capture Bottle")

                    Spacer()

                    Button(action: onOpenInventory) {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.title2)
                            .frame(width: 52, height: 52)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                }
                .padding(.horizontal, 26)
                .padding(.bottom, 24)
            }
        }
    }

    private var cameraPermissionView: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 58))
                .foregroundStyle(.secondary)
            Text("Enable camera access in Settings to scan bottles.")
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
        }
        .background(Color.gray.opacity(0.12))
    }

    private func cameraErrorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(message)
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
        }
        .background(Color.gray.opacity(0.12))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: BottleEntry.self, inMemory: true)
}
