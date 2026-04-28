import SwiftUI

struct CatalogSearchView: View {
    @ObservedObject var viewModel: LibrarySearchViewModel

    var body: some View {
        SearchScreenScaffold(
            title: "Catalog Search",
            placeholder: "Search the library catalog directly...",
            isLoading: viewModel.isLoading,
            queryText: $viewModel.queryText,
            onSubmit: {
                await viewModel.runCatalogSearch()
            }
        ) {
            VStack(alignment: .leading, spacing: 16) {
                if viewModel.latestQuery.isEmpty {
                    SearchTooltipView(
                        title: "What Catalog Search Does",
                        message: "Catalog Search sends your terms directly to the library catalog and returns the raw result list without recommendation ranking."
                    )
                }

                if !viewModel.latestQuery.isEmpty {
                    QuerySummaryView(
                        label: "Catalog Query",
                        value: viewModel.latestQuery
                    )
                }

                if let errorMessage = viewModel.errorMessage {
                    SearchStatusView(message: errorMessage)
                }

                if viewModel.catalogResults.isEmpty, viewModel.errorMessage == nil, !viewModel.latestQuery.isEmpty, !viewModel.isLoading {
                    SearchStatusView(message: "No catalog items matched that query.")
                } else {
                    CatalogResultsView(items: viewModel.catalogResults)
                }
            }
        }
    }
}
