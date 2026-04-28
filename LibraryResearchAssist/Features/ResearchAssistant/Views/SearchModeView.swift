import SwiftUI

struct SearchModeView: View {
    let scope: SearchScope
    @StateObject private var viewModel = LibrarySearchViewModel()

    var body: some View {
        Group {
            switch scope {
            case .assist:
                AssistedSearchView(viewModel: viewModel)
            case .catalog:
                CatalogSearchView(viewModel: viewModel)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Search Mode") {
    SearchModeView(scope: .assist)
}
