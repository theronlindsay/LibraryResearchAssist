import SwiftUI

struct ARCameraModeView: View {
    @StateObject private var cameraService = CameraPreviewService()

    @State private var scannedCode: String = ""
    @State private var capturedImage: UIImage?

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

            VStack {
                Spacer()

                if !scannedCode.isEmpty {
                    VStack(spacing: 8) {
                        Text("Scanned Code:")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))

                        Text(scannedCode)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.bottom, 10)
                }

                Button(action: {
                    cameraService.capturePhotoForScanning()
                }) {
                    Text("Scan Barcode")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            cameraService.onScanWithSnapshot = { code, image in
                scannedCode = code
                capturedImage = image
            }

            cameraService.configureAndStartSession()
        }
        .onDisappear {
            cameraService.stopSession()
        }
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
