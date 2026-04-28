import SwiftUI

struct ARCameraModeView: View {
    let isActive: Bool
    @StateObject private var cameraService = CameraPreviewService()
    private let searchService = LibrarySearchService()

    // Scan result state
    @State private var scannedCode: String = ""
    @State private var selectedItem: LibraryCatalogItem?
    @State private var isSearching = false
    @State private var searchError: String?

    private var isRunningInPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    init(isActive: Bool = true) {
        self.isActive = isActive
    }

    var body: some View {
        ZStack {
            if isRunningInPreview {
                SimulatedCameraFeedView()
            } else if cameraService.availabilityState == .multitaskingRestricted {
                fullscreenRequiredView
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

            VStack {
                if !scannedCode.isEmpty {
                    VStack(spacing: 8) {
                        Text(isSearching ? "Searching Catalog" : "Barcode Detected")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))

                        Text(scannedCode)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        if isSearching {
                            ProgressView()
                                .tint(.white)
                        }

                        if let searchError, !searchError.isEmpty {
                            Text(searchError)
                                .font(.footnote)
                                .foregroundStyle(.red.opacity(0.95))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.top, 50)
                }

                Spacer()
            }
        }
        .onAppear {
            updateCameraActivity(shouldRun: isActive)
        }
        .onChange(of: isActive) { _, newValue in
            updateCameraActivity(shouldRun: newValue)
        }
        .onChange(of: cameraService.availabilityState) { _, newValue in
            if newValue == .ready, isActive {
                cameraService.configureAndStartSession()
            }
        }
        .onAppear {
            cameraService.onScanWithSnapshot = { code in
                print("📦 LIVE SCAN:", code)

                Task { @MainActor in
                    scannedCode = code
                    searchError = nil
                }

                Task {
                    await searchForBarcode(code)
                }
            }
        }
        .onDisappear {
            cameraService.stopSession()
            resetScannerState()
        }
        .fullScreenCover(item: $selectedItem) { item in
            LibraryItemDetailView(item: item, showsRecommendationReason: false)
        }
    }

    @MainActor
    private func searchForBarcode(_ code: String) async {
        guard !isSearching else { return }

        isSearching = true
        searchError = nil

        do {
            let results = try await searchService.barcodeSearch(barcode: code)
            if let firstResult = results.first {
                selectedItem = firstResult
            } else {
                searchError = "article not found in catalog"
            }
        } catch {
            searchError = "article not found in catalog"
        }

        isSearching = false
    }

    @MainActor
    private func resetScannerState() {
        scannedCode = ""
        selectedItem = nil
        isSearching = false
        searchError = nil
    }

    private func updateCameraActivity(shouldRun: Bool) {
        if shouldRun {
            cameraService.configureAndStartSession()
        } else {
            cameraService.stopSession()
            resetScannerState()
        }
    }

    private var fullscreenRequiredView: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.up.left.and.arrow.down.right")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("Barcode scanning requires fullscreen for the camera view to work. This is yet another example of Apple arbitrarily restricting what you can do with a device you paid for")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
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
