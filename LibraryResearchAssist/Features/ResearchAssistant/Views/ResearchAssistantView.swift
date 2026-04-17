import SwiftUI

struct ResearchAssistantView: View {
    var body: some View {
        AIAssistantAndARView()
            .navigationTitle("Research Assistant")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Research Assistant") {
    NavigationStack {
        ResearchAssistantView()
    }
}
