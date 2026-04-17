import SwiftUI
import AVFoundation
import Combine

final class CameraPreviewService: ObservableObject {
    let session = AVCaptureSession()
    @Published var isAuthorized = false

    private let sessionQueue = DispatchQueue(label: "CameraSessionQueue")
    private var didConfigureSession = false

    func configureAndStartSession() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            configureSessionIfNeededAndStart()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.isAuthorized = granted
                }
                if granted {
                    self.configureSessionIfNeededAndStart()
                }
            }
        default:
            isAuthorized = false
        }
    }

    func stopSession() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    private func configureSessionIfNeededAndStart() {
        sessionQueue.async {
            if !self.didConfigureSession {
                self.session.beginConfiguration()

                guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                      let input = try? AVCaptureDeviceInput(device: camera),
                      self.session.canAddInput(input) else {
                    self.session.commitConfiguration()
                    return
                }

                self.session.addInput(input)
                self.session.commitConfiguration()
                self.didConfigureSession = true
            }

            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.videoPreviewLayer.session = session
    }
}

final class PreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected AVCaptureVideoPreviewLayer")
        }
        return layer
    }
}
