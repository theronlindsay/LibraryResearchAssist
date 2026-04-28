import SwiftUI

struct AssistedSearchView: View {
    @ObservedObject var viewModel: LibrarySearchViewModel

    var body: some View {
        SearchScreenScaffold(
            title: "Grounded Search Assist",
            placeholder: "Ask for sources, books, or related materials...",
            isLoading: viewModel.isLoading,
            queryText: $viewModel.queryText,
            onSubmit: {
                await viewModel.runAssistSearch()
            }
        ) {
            VStack(alignment: .leading, spacing: 16) {
                if viewModel.latestQuery.isEmpty {
                    SearchTooltipView(
                        title: "What Assist Does",
                        message: "Grounded Search Assist rewrites your prompt into a library-ready query, ranks the best matches, and shows both recommendations and the full result set."
                    )
                }

                if !viewModel.latestQuery.isEmpty {
                    QuerySummaryView(
                        label: "Prompt",
                        value: viewModel.latestQuery
                    )
                }

                if !viewModel.queryUsed.isEmpty {
                    QuerySummaryView(
                        label: "Query Used",
                        value: viewModel.queryUsed
                    )
                }

                if let errorMessage = viewModel.errorMessage {
                    SearchStatusView(message: errorMessage)
                }

                if viewModel.assistRecommendations.isEmpty,
                   viewModel.assistAllResults.isEmpty,
                   viewModel.errorMessage == nil,
                   !viewModel.latestQuery.isEmpty,
                   !viewModel.isLoading {
                    SearchStatusView(message: "No recommendations came back for that prompt.")
                } else if !viewModel.errorMessage.isNilOrEmpty {
                    EmptyView()
                } else {
                    if !viewModel.assistRecommendations.isEmpty {
                        CatalogResultsSectionView(
                            title: "Recommendations",
                            subtitle: "Ranked suggestions from the grounded assist workflow.",
                            items: viewModel.assistRecommendations
                        )
                    }

                    if !viewModel.assistAllResults.isEmpty {
                        CatalogResultsSectionView(
                            title: "All Results",
                            subtitle: "Every normalized catalog result returned for the query.",
                            items: viewModel.assistAllResults
                        )
                    }
                }
            }
        }
    }
}

struct QuerySummaryView: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            Text(value)
                .font(.headline)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct SearchTooltipView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: "info.circle")
                .font(.headline)
                .foregroundStyle(.primary)

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        switch self {
        case .none:
            return true
        case let .some(value):
            return value.isEmpty
        }
    }
}
