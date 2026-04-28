import SwiftUI
import UIKit

struct SearchScreenScaffold<Content: View>: View {
    let title: String
    let placeholder: String
    let isLoading: Bool
    @Binding var queryText: String
    let onSubmit: @Sendable () async -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(title)
                    .font(.title2.weight(.bold))
                    .padding(.top, 8)

                content()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.bottom, 100)
        }
        .scrollDismissesKeyboard(.immediately)
        .overlay {
            if isLoading {
                ProgressView("Loading…")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: Capsule())
                    .shadow(color: .black.opacity(0.08), radius: 20, y: 10)
            }
        }
        .safeAreaInset(edge: .bottom) {
            floatingComposer
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
        }
    }

    private var floatingComposer: some View {
        HStack(alignment: .bottom, spacing: 12) {
            TextField(placeholder, text: $queryText, axis: .vertical)
                .font(.body)
                .foregroundStyle(.primary)
                .lineLimit(1 ... 5)
                .submitLabel(.send)
                .onSubmit {
                    submitSearch()
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                        }
                )
                .shadow(color: .black.opacity(0.12), radius: 24, y: 14)

            Button {
                submitSearch()
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.accentColor.opacity(0.95),
                                        Color.accentColor.opacity(0.72)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay {
                        Circle()
                            .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                    }
                    .shadow(color: Color.accentColor.opacity(0.28), radius: 18, y: 10)
            }
            .disabled(queryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
            .opacity(queryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading ? 0.5 : 1)
        }
    }

    private func submitSearch() {
        guard !queryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !isLoading else {
            return
        }

        dismissKeyboard()
        Task {
            await onSubmit()
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

struct SearchStatusView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.body)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
