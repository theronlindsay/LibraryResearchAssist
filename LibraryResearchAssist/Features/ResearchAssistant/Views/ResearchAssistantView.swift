import SwiftUI

struct ResearchAssistantView: View {
    @State private var selectedMode: ResearchMode = .assist

    var body: some View {
        Group {
            switch selectedMode {
            case .assist:
                SearchModeView(scope: .assist)
            case .catalog:
                SearchModeView(scope: .catalog)
            case .ar:
                ARCameraModeView(isActive: true)
            }
        }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("Mode", selection: $selectedMode) {
                        ForEach(ResearchMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 360)
                }
            }
    }
}

#Preview("Research Assistant") {
    NavigationStack {
        ResearchAssistantView()
    }
}
