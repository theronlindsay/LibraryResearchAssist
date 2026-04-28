enum SearchScope: String, CaseIterable, Identifiable {
    case assist = "Grounded Assist"
    case catalog = "Catalog Search"

    var id: String { rawValue }
}
