import SwiftUI

struct SearchModeView: View {
    @State private var promptText = ""
    @State private var latestSubmittedPrompt = ""

    var body: some View {
        VStack {
            Spacer()

            if latestSubmittedPrompt.isEmpty {
                Text("Enter a research prompt to begin.")
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 8) {
                    Text("Prompt queued")
                        .font(.headline)
                    Text(latestSubmittedPrompt)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }

            Spacer()
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 10) {
                TextField("Type a research prompt...", text: $promptText)
                    .textFieldStyle(.roundedBorder)

                Button("Send") {
                    submitPrompt()
                }
                .buttonStyle(.borderedProminent)
                .disabled(promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
    }

    private func submitPrompt() {
        // Placeholder only: future external API integration point.
        latestSubmittedPrompt = promptText.trimmingCharacters(in: .whitespacesAndNewlines)
        promptText = ""
    }
}

#Preview("Search Mode") {
    SearchModeView()
}
