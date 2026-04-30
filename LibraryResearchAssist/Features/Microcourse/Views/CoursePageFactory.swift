import SwiftUI

struct CoursePageFactory {
    @ViewBuilder
    static func makePageView(
        for page: CoursePage,
        onCustomAction: @escaping (String) -> Void
    ) -> some View {
        switch page.pageType {
        case .text:
            TextPageView(page: page, onCustomAction: onCustomAction)

        case .checklist:
            ChecklistPageView(page: page, onCustomAction: onCustomAction)

        case .media:
            MediaPlaceholderPageView(page: page, onCustomAction: onCustomAction)
        }
    }
}
