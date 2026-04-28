import Foundation

struct AssistSearchResponse {
    let queryUsed: String
    let recommendations: [LibraryCatalogItem]
    let allResults: [LibraryCatalogItem]
}

struct LibrarySearchService {
    enum SearchServiceError: LocalizedError {
        case missingBaseURL
        case missingAppKey
        case invalidResponse
        case requestFailed(Int)

        var errorDescription: String? {
            switch self {
            case .missingBaseURL:
                return "Set LibraryAPIBaseURL in Info.plist to connect the library search service."
            case .missingAppKey:
                return "Set x-app-key in Info.plist to authenticate library API requests."
            case .invalidResponse:
                return "The library service returned data in an unexpected format."
            case let .requestFailed(statusCode):
                return "The library service request failed with status \(statusCode)."
            }
        }
    }

    private let session: URLSession
    private let baseURL: URL?
    private let appKey: String?

    nonisolated init(
        session: URLSession = .shared,
        baseURL: URL? = LibrarySearchService.resolveBaseURL(),
        appKey: String? = LibrarySearchService.resolveAppKey()
    ) {
        self.session = session
        self.baseURL = baseURL
        self.appKey = appKey
    }

    func assistSearch(query: String) async throws -> AssistSearchResponse {
        let object = try await fetch(
            path: "/api/v1/assist",
            body: [
                "provider": "openai",
                "prompt": query.trimmingCharacters(in: .whitespacesAndNewlines),
                "physicalOnly": false
            ]
        )
        guard let payload = JSONValueNormalizer.dictionary(from: object) else {
            throw SearchServiceError.invalidResponse
        }

        let builtQuery = payload.firstString(forKeys: [
            "builtQuery", "built_query", "query_used", "query"
        ])
        let searchPlan = payload["searchPlan"].flatMap(JSONValueNormalizer.dictionary(from:))
        let rewrittenQuery = searchPlan?.firstString(forKeys: [
            "rewrittenQuery", "rewritten_query"
        ])

        let queryUsed = builtQuery ?? rewrittenQuery ?? query
        let allResults = extractItems(
            from: payload,
            candidateKeys: ["results", "items", "records", "documents"]
        )
        let recommendations = mergeAssistItems(from: payload, allResults: allResults)

        return AssistSearchResponse(
            queryUsed: queryUsed,
            recommendations: recommendations,
            allResults: allResults
        )
    }

    func catalogSearch(query: String) async throws -> [LibraryCatalogItem] {
        let object = try await fetch(
            path: "/api/v1/search",
            body: [
                "query": query.trimmingCharacters(in: .whitespacesAndNewlines),
                "availabilityOnly": true,
                "limit": 10
            ]
        )

        if let dictionary = JSONValueNormalizer.dictionary(from: object) {
            let extracted = extractItems(
                from: dictionary,
                candidateKeys: ["results", "items", "records", "documents"]
            )

            if !extracted.isEmpty {
                return extracted
            }
        }

        if let array = object as? [Any] {
            let mapped = array.enumerated().compactMap { index, entry in
                LibraryCatalogItem(jsonObject: entry, index: index)
            }

            if !mapped.isEmpty {
                return mapped
            }
        }

        throw SearchServiceError.invalidResponse
    }

    func barcodeSearch(barcode: String) async throws -> [LibraryCatalogItem] {
        let object = try await fetch(
            path: "/api/v1/search/barcode",
            body: [
                "barcode": barcode.trimmingCharacters(in: .whitespacesAndNewlines),
                "availabilityOnly": false,
                "limit": 10
            ]
        )

        if let dictionary = JSONValueNormalizer.dictionary(from: object) {
            if dictionary["results"] is [Any] {
                return extractItems(
                    from: dictionary,
                    candidateKeys: ["results", "items", "records", "documents"]
                )
            }

            let extracted = extractItems(
                from: dictionary,
                candidateKeys: ["results", "items", "records", "documents"]
            )

            if !extracted.isEmpty {
                return extracted
            }
        }

        if let array = object as? [Any] {
            let mapped = array.enumerated().compactMap { index, entry in
                LibraryCatalogItem(jsonObject: entry, index: index)
            }

            if !mapped.isEmpty {
                return mapped
            }
        }

        throw SearchServiceError.invalidResponse
    }

    private func fetch(path: String, body: [String: Any]) async throws -> Any {
        guard let baseURL else {
            throw SearchServiceError.missingBaseURL
        }
        guard let appKey, !appKey.isEmpty else {
            throw SearchServiceError.missingAppKey
        }

        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(appKey, forHTTPHeaderField: "x-app-key")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SearchServiceError.invalidResponse
        }

        guard 200 ..< 300 ~= httpResponse.statusCode else {
            throw SearchServiceError.requestFailed(httpResponse.statusCode)
        }

        return try JSONSerialization.jsonObject(with: data)
    }

    private func extractItems(
        from payload: [String: Any],
        candidateKeys: [String]
    ) -> [LibraryCatalogItem] {
        for key in candidateKeys {
            guard let array = payload[key] as? [Any] else {
                continue
            }

            let mapped = array.enumerated().compactMap { index, entry in
                LibraryCatalogItem(jsonObject: entry, index: index)
            }

            if !mapped.isEmpty {
                return mapped
            }
        }

        return []
    }

    private func mergeAssistItems(
        from payload: [String: Any],
        allResults: [LibraryCatalogItem]
    ) -> [LibraryCatalogItem] {
        let recommendationObjects = payload["recommendations"] as? [Any] ?? []

        let resultsByID: [String: LibraryCatalogItem] = Dictionary(
            uniqueKeysWithValues: allResults.map { item in
                (item.id, item)
            }
        )

        let mergedRecommendations = recommendationObjects.enumerated().compactMap { element -> LibraryCatalogItem? in
            let index = element.offset
            let entry = element.element

            guard let recommendation = JSONValueNormalizer.dictionary(from: entry) else {
                return nil
            }

            let recordID = recommendation.firstString(forKeys: ["recordId", "record_id", "id"])
            let resultItem = recordID.flatMap { id in
                resultsByID[id]
            }
            let listingURL: URL?
            if let listingURLString = recommendation.firstString(forKeys: ["listingUrl", "listing_url"]) {
                listingURL = URL(string: listingURLString)
            } else {
                listingURL = nil
            }

            return LibraryCatalogItem(
                id: recordID ?? resultItem?.id ?? "\(index)",
                title: recommendation.firstString(forKeys: ["title"]) ?? resultItem?.title ?? "Untitled Item",
                subtitle: resultItem?.subtitle,
                authors: resultItem?.authors ?? [],
                summary: recommendation.firstString(forKeys: ["fitSummary", "fit_summary"]) ?? resultItem?.summary,
                rankingReason: recommendation.firstString(forKeys: ["whyRecommended", "why_recommended"]) ?? resultItem?.rankingReason,
                score: recommendation.firstString(forKeys: ["confidence", "score", "rank"]) ?? resultItem?.score,
                metadata: resultItem?.metadata ?? [],
                rawDetails: resultItem?.rawDetails ?? [],
                destinationURL: resultItem?.destinationURL ?? listingURL
            )
        }

        if !mergedRecommendations.isEmpty {
            return mergedRecommendations
        }

        return allResults
    }

    nonisolated private static func resolveBaseURL() -> URL? {
        if let configured = Bundle.main.object(forInfoDictionaryKey: "LibraryAPIBaseURL") as? String {
            let trimmed = configured.trimmingCharacters(in: .whitespacesAndNewlines)

            if let url = URL(string: trimmed),
           !trimmed.isEmpty {
                return url
            }
        }

        return URL(string: "https://albertsons-library-ai-api.vercel.app")
    }

    nonisolated private static func resolveAppKey() -> String? {
        guard let configured = Bundle.main.object(forInfoDictionaryKey: "x-app-key") as? String else {
            return nil
        }

        let trimmed = configured.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
