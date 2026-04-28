import SwiftUI

struct CatalogResultsView: View {
    let items: [LibraryCatalogItem]
    @State private var selectedItem: LibraryCatalogItem?

    var body: some View {
        LazyVStack(spacing: 14) {
            ForEach(items) { item in
                Button {
                    selectedItem = item
                } label: {
                    LibraryItemCardView(item: item)
                }
                .buttonStyle(.plain)
            }
        }
        .fullScreenCover(item: $selectedItem) { item in
            LibraryItemDetailView(item: item)
        }
    }
}

struct CatalogResultsSectionView: View {
    let title: String
    let subtitle: String?
    let items: [LibraryCatalogItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.weight(.semibold))

                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            CatalogResultsView(items: items)
        }
    }
}
