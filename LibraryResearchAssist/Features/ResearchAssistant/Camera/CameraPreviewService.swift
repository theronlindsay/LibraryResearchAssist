import SwiftUI
import AVFoundation
import Vision
import Combine

final class CameraPreviewService: NSObject, ObservableObject {
    enum CameraAvailabilityState: Equatable {
        case ready
        case multitaskingRestricted
        case unavailable
    }

    // MARK: - Public
    let session = AVCaptureSession()
    @Published var isAuthorized = false
    @Published var availabilityState: CameraAvailabilityState = .ready

    // Final output to UI
    var onScanWithSnapshot: ((String) -> Void)?


    // MARK: - Private
    private let sessionQueue = DispatchQueue(label: "CameraSessionQueue")
    private var didConfigureSession = false

    private let videoOutput = AVCaptureVideoDataOutput()
    private var observersRegistered = false

    nonisolated(unsafe) private var lastScanTime: TimeInterval = 0
    private let scanCooldown: TimeInterval = 1.5

    override init() {
        super.init()
        registerSessionObserversIfNeeded()
    }

    // MARK: - Vision Request
    nonisolated private func makeDetectBarcodeRequest() -> VNDetectBarcodesRequest {
        let request = VNDetectBarcodesRequest { [weak self] request, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ Vision error:", error.localizedDescription)
                return
            }

            self.processClassification(for: request)
        }

        request.symbologies = [
            .ean13,
            .ean8,
            .upce,
            .code128,
            .code39,
            .code39Checksum,
            .code39FullASCII,
            .code93,
            .itf14,
            .codabar,
            .gs1DataBar,
            .gs1DataBarExpanded,
            .gs1DataBarLimited
        ]

        return request
    }

    // MARK: - Authorization
    func configureAndStartSession() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {

        case .authorized:
            isAuthorized = true
            availabilityState = .ready
            configureSessionIfNeededAndStart()

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.isAuthorized = granted
                    self.availabilityState = granted ? .ready : .unavailable
                }
                if granted {
                    self.configureSessionIfNeededAndStart()
                }
            }

        default:
            isAuthorized = false
            availabilityState = .unavailable
        }
    }

    func stopSession() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    // MARK: - Session Setup
    private func configureSessionIfNeededAndStart() {
        sessionQueue.async {

            if !self.didConfigureSession {
                self.session.beginConfiguration()

                self.session.sessionPreset = .hd1280x720

                // Allow camera capture while the app is running in a windowed iPad multitasking layout.
                if self.session.isMultitaskingCameraAccessSupported {
                    self.session.isMultitaskingCameraAccessEnabled = true
                }

                guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                           for: .video,
                                                           position: .back),
                      let input = try? AVCaptureDeviceInput(device: camera),
                      self.session.canAddInput(input) else {
                    print("❌ Camera setup failed")
                    self.session.commitConfiguration()
                    return
                }

                self.session.addInput(input)

                self.videoOutput.setSampleBufferDelegate(self,
                                                         queue: DispatchQueue(label: "VideoFrameQueue"))

                if self.session.canAddOutput(self.videoOutput) {
                    self.session.addOutput(self.videoOutput)
                }

                self.session.commitConfiguration()
                self.didConfigureSession = true
            }

            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    private func registerSessionObserversIfNeeded() {
        guard !observersRegistered else { return }
        observersRegistered = true

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSessionWasInterrupted(_:)),
            name: .AVCaptureSessionWasInterrupted,
            object: session
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSessionInterruptionEnded(_:)),
            name: .AVCaptureSessionInterruptionEnded,
            object: session
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSessionRuntimeError(_:)),
            name: .AVCaptureSessionRuntimeError,
            object: session
        )
    }

    @objc private func handleSessionWasInterrupted(_ notification: Notification) {
        guard let reasonValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as? Int,
              let reason = AVCaptureSession.InterruptionReason(rawValue: reasonValue) else {
            return
        }

        Task { @MainActor in
            switch reason {
            case .videoDeviceNotAvailableWithMultipleForegroundApps:
                availabilityState = .multitaskingRestricted
            default:
                availabilityState = .unavailable
            }
        }
    }

    @objc private func handleSessionInterruptionEnded(_ notification: Notification) {
        Task { @MainActor in
            availabilityState = .ready
        }
    }

    @objc private func handleSessionRuntimeError(_ notification: Notification) {
        Task { @MainActor in
            availabilityState = .unavailable
        }
    }

    // MARK: - Vision Processing
    nonisolated private func processClassification(for request: VNRequest) {

        guard let bestResult = request.results?.first as? VNBarcodeObservation,
              let payload = bestResult.payloadStringValue else {
            return
        }

        let now = Date().timeIntervalSince1970
        guard now - lastScanTime > scanCooldown else { return }
        lastScanTime = now

        print("✅ BARCODE:", payload)

        Task { @MainActor in
            self.onScanWithSnapshot?(payload)
        }
    }
}

// MARK: - Live Frame Delegate
extension CameraPreviewService: AVCaptureVideoDataOutputSampleBufferDelegate {

    nonisolated func captureOutput(_ output: AVCaptureOutput,
                                   didOutput sampleBuffer: CMSampleBuffer,
                                   from connection: AVCaptureConnection) {

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: .right,
            options: [:]
        )
        let request = makeDetectBarcodeRequest()

        do {
            try handler.perform([request])
        } catch {
            print("❌ Vision failed:", error)
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
