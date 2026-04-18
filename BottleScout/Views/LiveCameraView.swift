@preconcurrency import AVFoundation
import SwiftUI
import UIKit

final class LiveCameraModel: NSObject, ObservableObject, @unchecked Sendable {
    let session = AVCaptureSession()

    @Published var authorizationDenied = false
    @Published var setupError: String?

    private let sessionQueue = DispatchQueue(label: "BottleScout.LiveCamera.Session")
    private let photoOutput = AVCapturePhotoOutput()
    private var captureCompletion: (@Sendable (UIImage?) -> Void)?
    private var isConfigured = false

    override init() {
        super.init()
        requestAccessAndConfigureIfNeeded()
    }

    func requestAccessAndConfigureIfNeeded() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            authorizationDenied = false
            configureIfNeeded()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async { [weak self] in
                    self?.authorizationDenied = !granted
                }
                if granted {
                    self?.configureIfNeeded()
                }
            }
        default:
            authorizationDenied = true
        }
    }

    func start() {
        sessionQueue.async { [weak self] in
            guard let self, self.isConfigured, !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }

    func capturePhoto(completion: @escaping @Sendable (UIImage?) -> Void) {
        sessionQueue.async { [weak self] in
            guard let self, self.isConfigured else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            self.captureCompletion = completion
            let settings = AVCapturePhotoSettings()
            settings.flashMode = .off
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    private func configureIfNeeded() {
        sessionQueue.async { [weak self] in
            guard let self, !self.isConfigured else { return }

            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            defer {
                self.session.commitConfiguration()
            }

            guard
                let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                let input = try? AVCaptureDeviceInput(device: device)
            else {
                DispatchQueue.main.async {
                    self.setupError = "Back camera is unavailable."
                }
                return
            }

            guard self.session.canAddInput(input) else {
                DispatchQueue.main.async {
                    self.setupError = "Unable to attach the camera input."
                }
                return
            }

            guard self.session.canAddOutput(self.photoOutput) else {
                DispatchQueue.main.async {
                    self.setupError = "Unable to attach the photo output."
                }
                return
            }

            self.session.addInput(input)
            self.session.addOutput(self.photoOutput)
            self.photoOutput.isHighResolutionCaptureEnabled = true
            self.isConfigured = true
        }
    }
}

extension LiveCameraModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let completion = captureCompletion
        captureCompletion = nil

        guard
            error == nil,
            let data = photo.fileDataRepresentation(),
            let image = UIImage(data: data)
        else {
            DispatchQueue.main.async {
                completion?(nil)
            }
            return
        }

        DispatchQueue.main.async {
            completion?(image)
        }
    }
}

struct LiveCameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.previewLayer.session = session
    }
}

final class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}
