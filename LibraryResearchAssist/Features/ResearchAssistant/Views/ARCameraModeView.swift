import SwiftUI

struct ARCameraModeView: View {
    @StateObject private var cameraService = CameraPreviewService()

    // Scan result state
    @State private var scannedCode: String = ""
    @State private var capturedImage: UIImage?

    @State private var showScanModal: Bool = false

    private var isRunningInPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    var body: some View {
        ZStack {
            if isRunningInPreview {
                SimulatedCameraFeedView()
            } else if cameraService.isAuthorized {
                CameraPreviewView(session: cameraService.session)
                    .ignoresSafeArea(edges: .bottom)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "camera.fill")
                        .font(.largeTitle)
                    Text("Camera permission is required for AR Mode.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }

            // Button overlay
            VStack {
                Spacer()

                Button(action: {
                    cameraService.capturePhotoForScanning()
                }) {
                    Text("Scan Barcode")
                        .font(.headline)
                        .padding()
                        .frame(width: 160) // optional fixed width
                        .background(Color.white)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            cameraService.onScanWithSnapshot = { code, image in
                scannedCode = code
                capturedImage = image

                //trigger modal
                showScanModal = true
            }

            cameraService.configureAndStartSession()
        }
        .onDisappear {
            cameraService.stopSession()
        }

        //Modal presentation
        .sheet(isPresented: $showScanModal) {
            ScanResultModalView(
                scannedCode: scannedCode,
                onDismiss: {
                    showScanModal = false
                }
            )
        }
    }
}

//Modal View
struct ScanResultModalView: View {
    let scannedCode: String
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Barcode Scanned!")
                .font(.title)
                .bold()

            VStack(spacing: 8) {
                Text("Result:")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text(scannedCode)
                    .font(.body)
                    .multilineTextAlignment(.center)
            }
            .padding()

            Button("Dismiss") {
                onDismiss()
            }
            .padding()
        }
        .padding()
    }
}

private struct SimulatedCameraFeedView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color.gray.opacity(0.7), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            ForEach(0..<6, id: \.self) { index in
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    .frame(width: 240 + CGFloat(index * 26), height: 140 + CGFloat(index * 22))
            }

            VStack(spacing: 8) {
                Image(systemName: "camera.viewfinder")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                Text("Simulated Camera Feed")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("Xcode Preview placeholder")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(20)
            .background(Color.black.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview("AR Mode") {
    ARCameraModeView()
}
