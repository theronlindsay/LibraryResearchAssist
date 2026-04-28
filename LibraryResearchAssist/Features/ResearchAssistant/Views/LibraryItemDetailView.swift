import SwiftUI
import UIKit

struct LibraryItemDetailView: View {
    let item: LibraryCatalogItem
    let showsRecommendationReason: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var isAdditionalDataExpanded = false
    @State private var isIdentifiersExpanded = false

    init(item: LibraryCatalogItem, showsRecommendationReason: Bool = true) {
        self.item = item
        self.showsRecommendationReason = showsRecommendationReason
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(item.title)
                            .font(.title.weight(.bold))

                        if let subtitle = item.subtitle, !subtitle.isEmpty {
                            Text(subtitle)
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }

                        if !item.authors.isEmpty {
                            Label(item.authors.joined(separator: ", "), systemImage: "person.2")
                                .foregroundStyle(.secondary)
                        }

                        if let score = item.score, !score.isEmpty {
                            Label("Score: \(score)", systemImage: "chart.bar")
                                .foregroundStyle(.secondary)
                        }
                    }

                    if showsRecommendationReason,
                       let rankingReason = item.rankingReason,
                       !rankingReason.isEmpty {
                        DetailSection(title: "Why it was recommended") {
                            CopyableValueRow(label: "Reason", value: rankingReason)
                        }
                    }

                    if let summary = item.summary, !summary.isEmpty {
                        DetailSection(title: "Summary") {
                            CopyableValueRow(label: "Summary", value: summary)
                        }
                    }

                    if let destinationURL = item.destinationURL {
                        Link(destination: destinationURL) {
                            Label("Open Catalog Record", systemImage: "arrow.up.right.square")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    if !item.metadata.isEmpty {
                        DetailSection(title: "Catalog details") {
                            MetadataListView(rows: item.metadata)
                        }
                    }

                    if !item.identifiers.isEmpty {
                        DisclosureDetailSection(
                            title: "Identifiers",
                            isExpanded: $isIdentifiersExpanded
                        ) {
                            IdentifierListView(rows: item.identifiers)
                        }
                    }

                    if !item.rawDetails.isEmpty {
                        DisclosureDetailSection(
                            title: "Additional data",
                            isExpanded: $isAdditionalDataExpanded
                        ) {
                            MetadataListView(rows: item.rawDetails)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)

            content()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

private struct DisclosureDetailSection<Content: View>: View {
    let title: String
    @Binding var isExpanded: Bool
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            DisclosureGroup(title, isExpanded: $isExpanded) {
                content()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 12)
            }
            .font(.headline)
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

private struct MetadataListView: View {
    let rows: [LibraryCatalogItem.MetadataRow]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                CopyableValueRow(label: row.label, value: row.value)
            }
        }
    }
}

private struct IdentifierListView: View {
    let rows: [LibraryCatalogItem.MetadataRow]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                CopyableValueRow(
                    label: "Identifier",
                    value: "\(row.label): \(row.value)"
                )
            }
        }
    }
}

private struct CopyableValueRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                Text(value)
                    .font(.body)
            }

            Spacer(minLength: 0)

            Button {
                UIPasteboard.general.string = value
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.body.weight(.semibold))
            }
            .buttonStyle(.borderless)
            .accessibilityLabel("Copy \(label)")
        }
    }
}
