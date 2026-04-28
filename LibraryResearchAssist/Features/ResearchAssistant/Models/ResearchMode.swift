enum ResearchMode: String, CaseIterable, Identifiable {
    case assist = "Assist"
    case catalog = "Catalog"
    case ar = "AR"

    var id: String { rawValue }
}
