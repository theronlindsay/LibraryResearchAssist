import Foundation

struct LibraryCatalogItem: Identifiable, Hashable {
    struct MetadataRow: Hashable {
        let label: String
        let value: String
    }

    let id: String
    let title: String
    let subtitle: String?
    let authors: [String]
    let summary: String?
    let rankingReason: String?
    let score: String?
    let metadata: [MetadataRow]
    let identifiers: [MetadataRow]
    let rawDetails: [MetadataRow]
    let destinationURL: URL?

    init(
        id: String = UUID().uuidString,
        title: String,
        subtitle: String? = nil,
        authors: [String] = [],
        summary: String? = nil,
        rankingReason: String? = nil,
        score: String? = nil,
        metadata: [MetadataRow] = [],
        identifiers: [MetadataRow] = [],
        rawDetails: [MetadataRow] = [],
        destinationURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.authors = authors
        self.summary = summary
        self.rankingReason = rankingReason
        self.score = score
        self.metadata = metadata
        self.identifiers = identifiers
        self.rawDetails = rawDetails
        self.destinationURL = destinationURL
    }
}

extension LibraryCatalogItem {
    init?(jsonObject: Any, index: Int) {
        guard let normalized = JSONValueNormalizer.dictionary(from: jsonObject) else {
            return nil
        }

        let title = normalized.firstString(forKeys: [
            "title", "name", "record_title", "display_title", "label"
        ]) ?? "Untitled Item"

        let subtitle = normalized.firstSubtitleString(forKeys: [
            "subtitle", "journal", "publication", "container_title"
        ]) ?? normalized.firstPublicationYear(forKeys: [
            "publicationYear", "publication_year", "year", "published"
        ])

        let authors = normalized.firstStringArray(forKeys: [
            "authors", "author", "creators", "creator", "contributors"
        ])

        let summary = normalized.firstString(forKeys: [
            "summary", "description", "abstract", "snippet", "content", "fitSummary", "fit_summary"
        ])

        let rankingReason = normalized.firstString(forKeys: [
            "reason", "rationale", "why_recommended", "whyRecommended", "explanation", "contextNotes", "context_notes"
        ])

        let score = normalized.firstString(forKeys: [
            "score", "rank", "relevance", "ranking_score", "confidence"
        ])

        let id = normalized.firstString(forKeys: [
            "id", "recordId", "record_id", "identifier", "uuid"
        ]) ?? "\(index)-\(title)"

        let urlString = normalized.firstString(forKeys: [
            "url", "link", "permalink", "href", "catalog_url", "listingUrl", "listing_url"
        ])

        let destinationURL = urlString.flatMap(URL.init(string:))

        let reservedKeys: Set<String> = [
            "title", "name", "record_title", "display_title", "label",
            "subtitle", "journal", "publication", "container_title",
            "authors", "author", "creators", "creator", "contributors",
            "summary", "description", "abstract", "snippet", "content",
            "reason", "rationale", "why_recommended", "whyRecommended", "explanation", "contextNotes", "context_notes",
            "score", "rank", "relevance", "ranking_score", "confidence",
            "id", "recordId", "record_id", "identifier", "uuid",
            "url", "link", "permalink", "href", "catalog_url", "listingUrl", "listing_url",
            "identifiers", "identifierDetails", "identifier_details"
        ]

        let metadata = normalized.metadataRows(
            forKeys: [
                "type", "year", "publication_year", "publicationYear", "published",
                "publisher", "call_number", "location", "availability",
                "isbn", "issn", "subject", "subjects", "language", "sourceTypes", "source_types", "primaryIsbn", "primary_isbn"
            ]
        )

        let identifiers = normalized.identifierRows()

        let rawDetails = normalized
            .filter { !reservedKeys.contains($0.key) }
            .compactMap { entry -> LibraryCatalogItem.MetadataRow? in
                let key = entry.key
                let value = entry.value

                let formatted: String?
                if JSONValueNormalizer.isDateLikeKey(key) {
                    formatted = JSONValueNormalizer.numericOnlyDateString(from: value)
                } else {
                    formatted = JSONValueNormalizer.render(value)
                }

                guard let formatted else {
                    return nil
                }

                return LibraryCatalogItem.MetadataRow(
                    label: key.replacingOccurrences(of: "_", with: " ").capitalized,
                    value: formatted
                )
            }
            .sorted { $0.label < $1.label }

        self.init(
            id: id,
            title: title,
            subtitle: subtitle,
            authors: authors,
            summary: summary,
            rankingReason: rankingReason,
            score: score,
            metadata: metadata,
            identifiers: identifiers,
            rawDetails: rawDetails,
            destinationURL: destinationURL
        )
    }
}

enum JSONValueNormalizer {
    nonisolated static func dictionary(from object: Any) -> [String: Any]? {
        if let dictionary = object as? [String: Any] {
            return dictionary
        }

        if let wrapped = object as? [Any], wrapped.count == 1 {
            return wrapped.first.flatMap(dictionary(from:))
        }

        return nil
    }

    nonisolated static func render(_ value: Any) -> String? {
        if let string = value as? String {
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }

        if let number = value as? NSNumber {
            return number.stringValue
        }

        if let array = value as? [Any] {
            let rendered = array.compactMap(render)
            return rendered.isEmpty ? nil : rendered.joined(separator: ", ")
        }

        if let dictionary = value as? [String: Any] {
            let rendered = dictionary
                .sorted { $0.key < $1.key }
                .compactMap { entry -> String? in
                    guard let renderedValue = render(entry.value) else {
                        return nil
                    }

                    return "\(entry.key): \(renderedValue)"
                }

            return rendered.isEmpty ? nil : rendered.joined(separator: " | ")
        }

        return nil
    }

    nonisolated static func normalizedYear(from value: Any) -> String? {
        guard let rendered = render(value) else {
            return nil
        }

        let trimmed = rendered.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return nil
        }

        let pattern = #"\b(1[0-9]{3}|20[0-9]{2}|2100)\b"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return trimmed
        }

        let nsRange = NSRange(trimmed.startIndex..<trimmed.endIndex, in: trimmed)
        guard let match = regex.firstMatch(in: trimmed, range: nsRange),
              let range = Range(match.range(at: 1), in: trimmed) else {
            return trimmed
        }

        return String(trimmed[range])
    }

    nonisolated static func numericOnlyDateString(from value: Any) -> String? {
        guard let rendered = render(value) else {
            return nil
        }

        let digitsOnly = rendered.filter(\.isNumber)
        return digitsOnly.isEmpty ? nil : digitsOnly
    }

    nonisolated static func normalizedYearLikeDisplayString(from value: Any) -> String? {
        guard let rendered = render(value) else {
            return nil
        }

        let trimmed = rendered.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return nil
        }

        let yearOnlyPattern = #"^[\[\(\s]*c?[\s]*((?:1[0-9]{3}|20[0-9]{2}|2100))[\]\)\s\.\?,;:]*$"#
        guard let regex = try? NSRegularExpression(pattern: yearOnlyPattern) else {
            return trimmed
        }

        let nsRange = NSRange(trimmed.startIndex..<trimmed.endIndex, in: trimmed)
        guard let match = regex.firstMatch(in: trimmed, range: nsRange),
              let range = Range(match.range(at: 1), in: trimmed) else {
            return trimmed
        }

        return String(trimmed[range])
    }

    nonisolated static func isDateLikeKey(_ key: String) -> Bool {
        let normalizedKey = key.lowercased()
        return normalizedKey.contains("publication") ||
            normalizedKey.contains("published") ||
            normalizedKey == "year" ||
            normalizedKey.contains("date")
    }
}

extension Dictionary where Key == String, Value == Any {
    func firstString(forKeys keys: [String]) -> String? {
        let matches: [String] = keys.compactMap { key -> String? in
            guard let value = self[key] else {
                return nil
            }

            return JSONValueNormalizer.render(value)
        }

        return matches.first
    }

    func firstSubtitleString(forKeys keys: [String]) -> String? {
        let matches: [String] = keys.compactMap { key -> String? in
            guard let value = self[key] else {
                return nil
            }

            return JSONValueNormalizer.normalizedYearLikeDisplayString(from: value)
        }

        return matches.first
    }

    func firstStringArray(forKeys keys: [String]) -> [String] {
        for key in keys {
            guard let value = self[key] else {
                continue
            }

            if let strings = value as? [String] {
                let cleaned = strings.map {
                    $0.trimmingCharacters(in: .whitespacesAndNewlines)
                }.filter { !$0.isEmpty }

                if !cleaned.isEmpty {
                    return cleaned
                }
            }

            if let rendered = JSONValueNormalizer.render(value) {
                let split = rendered
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }

                if !split.isEmpty {
                    return split
                }
            }
        }

        return []
    }

    func firstPublicationYear(forKeys keys: [String]) -> String? {
        let matches: [String] = keys.compactMap { key -> String? in
            guard let value = self[key] else {
                return nil
            }

            return JSONValueNormalizer.normalizedYear(from: value)
        }

        return matches.first
    }

    func metadataRows(forKeys keys: [String]) -> [LibraryCatalogItem.MetadataRow] {
        keys.compactMap { key -> LibraryCatalogItem.MetadataRow? in
            guard let value = self[key] else {
                return nil
            }

            let rendered: String?
            if JSONValueNormalizer.isDateLikeKey(key) {
                rendered = JSONValueNormalizer.numericOnlyDateString(from: value)
            } else {
                rendered = JSONValueNormalizer.render(value)
            }

            guard let rendered else { return nil }

            return LibraryCatalogItem.MetadataRow(
                label: key.replacingOccurrences(of: "_", with: " ").capitalized,
                value: rendered
            )
        }
    }

    func identifierRows() -> [LibraryCatalogItem.MetadataRow] {
        var rows: [LibraryCatalogItem.MetadataRow] = []

        if let details = self["identifierDetails"] as? [Any] {
            let parsedDetailRows: [LibraryCatalogItem.MetadataRow] = details.compactMap { detail -> LibraryCatalogItem.MetadataRow? in
                guard let dictionary = JSONValueNormalizer.dictionary(from: detail),
                      let value = dictionary.firstString(forKeys: ["value"]) else {
                    return nil
                }

                let type = dictionary.firstString(forKeys: [
                    "identifierType", "identifier_type", "identifierTypeId", "identifier_type_id"
                ]) ?? "Identifier"

                return LibraryCatalogItem.MetadataRow(label: type, value: value)
            }

            if !parsedDetailRows.isEmpty {
                rows.append(contentsOf: parsedDetailRows)
            }
        }

        if rows.isEmpty, let identifiers = self["identifiers"] as? [Any] {
            let fallbackRows: [LibraryCatalogItem.MetadataRow] = identifiers.compactMap { identifier -> LibraryCatalogItem.MetadataRow? in
                guard let value = JSONValueNormalizer.render(identifier) else {
                    return nil
                }

                return LibraryCatalogItem.MetadataRow(label: "Identifier", value: value)
            }

            rows.append(contentsOf: fallbackRows)
        }

        return rows
    }
}
