import SwiftUI
import AVFoundation
import Combine
import Vision

final class CameraPreviewService: NSObject, ObservableObject {

    //Public
    let session = AVCaptureSession()
    @Published var isAuthorized = false

    // Returns barcode + image AFTER button press
    var onScanWithSnapshot: ((String, UIImage) -> Void)?

    // MARK: - Private
    private let sessionQueue = DispatchQueue(label: "CameraSessionQueue")
    private var didConfigureSession = false

    private let photoOutput = AVCapturePhotoOutput()

    //Authorization + Start
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

    //Manual photo capture
    func capturePhotoForScanning() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings,
                                 delegate: PhotoCaptureDelegate { [weak self] image in
            guard let self = self, let image = image else { return }
            self.detectBarcode(in: image)
        })
    }

    //Session Setup
    private func configureSessionIfNeededAndStart() {
        sessionQueue.async {
            if !self.didConfigureSession {
                self.session.beginConfiguration()

                // Camera input
                guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                           for: .video,
                                                           position: .back),
                      let input = try? AVCaptureDeviceInput(device: camera),
                      self.session.canAddInput(input) else {
                    self.session.commitConfiguration()
                    return
                }

                self.session.addInput(input)

                // Photo output only
                if self.session.canAddOutput(self.photoOutput) {
                    self.session.addOutput(self.photoOutput)
                }

                self.session.commitConfiguration()
                self.didConfigureSession = true
            }

            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    // Barcode Detection
    private func detectBarcode(in image: UIImage) {
        guard let cgImage = image.cgImage else { return }

        let request = VNDetectBarcodesRequest { [weak self] request, error in
            guard let self = self else { return }

            if let results = request.results as? [VNBarcodeObservation],
               let first = results.first,
               let payload = first.payloadStringValue {

                DispatchQueue.main.async {
                    self.onScanWithSnapshot?(payload, image)
                }
            }
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
}

//Photo Capture Delegate
final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {

    private let completion: (UIImage?) -> Void

    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
    }

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {

        guard error == nil,
              let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            completion(nil)
            return
        }

        completion(image)
    }
}

//Preview View
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

//UIKit Layer
final class PreviewView: UIView {

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected AVCaptureVideoPreviewLayer")
        }
        return layer
    }
}
