enum ResearchMode: String, CaseIterable, Identifiable {
    case ai = "AI Search"
    case ar = "AR Mode"

    var id: String { rawValue }
}
