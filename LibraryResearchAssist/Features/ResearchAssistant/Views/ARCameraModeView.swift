import SwiftUI

struct ARCameraModeView: View {
    @StateObject private var cameraService = CameraPreviewService()

    // Scan result state
    @State private var scannedCode: String = ""
    @State private var showScanModal: Bool = false

    private var isRunningInPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    var body: some View {
        ZStack {

            // Camera feed
            if isRunningInPreview {
                SimulatedCameraFeedView()
            } else if cameraService.isAuthorized {
                CameraPreviewView(session: cameraService.session)
                    .ignoresSafeArea(edges: .all)
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

            // 🔥 LIVE RESULT OVERLAY (NEW UX)
            VStack {
                if !scannedCode.isEmpty {
                    VStack(spacing: 8) {
                        Text("📦 Barcode Detected")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))

                        Text(scannedCode)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.top, 50)
                }

                Spacer()
            }
        }

        // MARK: - Live scan callback
        .onAppear {
            cameraService.onScanWithSnapshot = { code in
                print("📦 LIVE SCAN:", code)

                DispatchQueue.main.async {
                    scannedCode = code
                    showScanModal = true
                }
            }

            cameraService.configureAndStartSession()
        }

        .onDisappear {
            cameraService.stopSession()
        }

        // MARK: - Modal
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

// Modal View (unchanged)
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

// Preview fallback (unchanged)
private struct SimulatedCameraFeedView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color.gray.opacity(0.7), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack {
                Image(systemName: "camera.viewfinder")
                    .font(.largeTitle)
                    .foregroundStyle(.white)

                Text("Simulated Camera Feed")
                    .foregroundStyle(.white)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ARCameraModeView()
}
