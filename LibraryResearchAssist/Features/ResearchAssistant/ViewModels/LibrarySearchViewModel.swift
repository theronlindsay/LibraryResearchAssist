import Combine
import Foundation

@MainActor
final class LibrarySearchViewModel: ObservableObject {
    @Published var queryText = ""
    @Published var latestQuery = ""
    @Published var queryUsed = ""
    @Published var assistRecommendations: [LibraryCatalogItem] = []
    @Published var assistAllResults: [LibraryCatalogItem] = []
    @Published var catalogResults: [LibraryCatalogItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: LibrarySearchService

    init(service: LibrarySearchService = LibrarySearchService()) {
        self.service = service
    }

    func runAssistSearch() async {
        let query = normalizedQuery
        guard !query.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await service.assistSearch(query: query)
            latestQuery = query
            queryUsed = response.queryUsed
            assistRecommendations = response.recommendations
            assistAllResults = response.allResults
        } catch {
            errorMessage = error.localizedDescription
            assistRecommendations = []
            assistAllResults = []
        }

        isLoading = false
    }

    func runCatalogSearch() async {
        let query = normalizedQuery
        guard !query.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        do {
            catalogResults = try await service.catalogSearch(query: query)
            latestQuery = query
        } catch {
            errorMessage = error.localizedDescription
            catalogResults = []
        }

        isLoading = false
    }

    private var normalizedQuery: String {
        queryText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
