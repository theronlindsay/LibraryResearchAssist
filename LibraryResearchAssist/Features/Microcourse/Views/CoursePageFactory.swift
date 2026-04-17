import SwiftUI

struct CoursePageFactory {
    @ViewBuilder
    static func makePageView(for page: CoursePage) -> some View {
        switch page.pageType {
        case .text:
            TextPageView(page: page)
        case .checklist:
            ChecklistPageView(page: page)
        case .media:
            MediaPlaceholderPageView(page: page)
        }
    }
}
