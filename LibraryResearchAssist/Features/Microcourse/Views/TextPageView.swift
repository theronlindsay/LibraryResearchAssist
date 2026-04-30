import SwiftUI

struct TextPageView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let page: CoursePage

    private var titleFont: Font {
        horizontalSizeClass == .regular ? .title : .title2
    }

    private var bodyFont: Font {
        horizontalSizeClass == .regular ? .title3 : .body
    }
    
    let onCustomAction: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(page.title)
                    .font(titleFont)
                    .bold()

                Text(page.bodyText)
                    .font(bodyFont)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                if let action = page.pageAction,
                   action.actionType == .custom,
                   let id = action.customActionID {
                    onCustomAction(id)
                }
            } label: {
                Label(
                    page.pageAction?.title ?? "",
                    systemImage: page.pageAction?.systemImage ?? "sparkles"
                )
            }
        }
    }
}

#Preview("Text Page") {
    TextPageView(
        page: CoursePage(
            title: "Preview: Welcome",
            pageType: .text,
            bodyText: "This is a preview of a text lesson page."
        ), onCustomAction: { actionID in
            print("Preview custom action: \(actionID)")
        }
    )
    .padding()
}
