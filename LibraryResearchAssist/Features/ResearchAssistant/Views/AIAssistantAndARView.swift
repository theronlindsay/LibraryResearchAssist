import SwiftUI

// Reusable no-navbar component for embedding AI Search and AR modes anywhere.
struct AIAssistantAndARView: View {
    @State private var selectedMode: ResearchMode
    let showsModePicker: Bool
    let isActive: Bool

    init(
        initialMode: ResearchMode = .assist,
        showsModePicker: Bool = false,
        isActive: Bool = true
    ) {
        _selectedMode = State(initialValue: initialMode)
        self.showsModePicker = showsModePicker
        self.isActive = isActive
    }

    var body: some View {
        VStack(spacing: 0) {
            if showsModePicker {
                Picker("Mode", selection: $selectedMode) {
                    ForEach(ResearchMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
            }

            switch selectedMode {
            case .assist:
                SearchModeView(scope: .assist)
            case .catalog:
                SearchModeView(scope: .catalog)
            case .ar:
                ARCameraModeView(isActive: isActive)
            }
        }
    }
}

#Preview("Assist Mode") {
    AIAssistantAndARView(initialMode: .assist)
}

#Preview("Catalog Mode") {
    AIAssistantAndARView(initialMode: .catalog)
}
