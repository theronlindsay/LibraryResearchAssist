import SwiftUI

// Reusable no-navbar component for embedding AI Search and AR modes anywhere.
struct AIAssistantAndARView: View {
    @State private var selectedMode: ResearchMode

    init(initialMode: ResearchMode = .ai) {
        _selectedMode = State(initialValue: initialMode)
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Mode", selection: $selectedMode) {
                ForEach(ResearchMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            switch selectedMode {
            case .ai:
                SearchModeView()
            case .ar:
                ARCameraModeView()
            }
        }
    }
}

#Preview("AI Mode") {
    AIAssistantAndARView(initialMode: .ai)
}

#Preview("AR Mode") {
    AIAssistantAndARView(initialMode: .ar)
}
