import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var liveCamera = LiveCameraModel()
    @State private var selectedImage: UIImage?
    @State private var bottleReviewImage: UIImage?
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
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
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
                if let image = bottleReviewImage {
                    AddBottleView(initialImage: image, initialImageSource: imageSource)
                }
            }
            .onChange(of: showBottleReview) { _, shown in
                if !shown { bottleReviewImage = nil }
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
                if let newValue {
                    bottleReviewImage = newValue
                    selectedImage = nil
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
            Color.black.ignoresSafeArea()

            cameraLayer
                .ignoresSafeArea(edges: .bottom)

            VStack {
                Spacer()
                actionBar
            }
        }
    }

    @ViewBuilder
    private var cameraLayer: some View {
        if camera.authorizationDenied {
            cameraMessage(
                systemImage: "camera.viewfinder",
                title: "Camera Access Needed",
                message: "Enable camera access in Settings to scan bottles."
            )
        } else if let setupError = camera.setupError {
            cameraMessage(
                systemImage: "exclamationmark.triangle",
                title: "Camera Unavailable",
                message: setupError
            )
        } else {
            LiveCameraPreview(session: camera.session)
                .overlay(alignment: .center) {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.75), lineWidth: 2)
                        .frame(width: 220, height: 300)
                        .shadow(color: .black.opacity(0.35), radius: 10)
                }
                .overlay(alignment: .top) {
                    Text("Align the label inside the frame")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                        .environment(\.colorScheme, .dark)
                        .padding(.top, 12)
                }
        }
    }

    private var actionBar: some View {
        HStack(spacing: 32) {
            circularButton(systemImage: "photo.on.rectangle", label: "Photos", action: onOpenPhotos)

            Button(action: onOpenCamera) {
                ZStack {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.9), lineWidth: 4)
                        .frame(width: 80, height: 80)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 66, height: 66)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Capture Bottle")

            circularButton(systemImage: "list.bullet.rectangle", label: "Inventory", action: onOpenInventory)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [.black.opacity(0), .black.opacity(0.75)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
        )
    }

    private func circularButton(systemImage: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(Color.white.opacity(0.18), in: Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private func cameraMessage(systemImage: String, title: String, message: String) -> some View {
        VStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 52))
                .foregroundStyle(.white.opacity(0.7))
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: BottleEntry.self, inMemory: true)
}
