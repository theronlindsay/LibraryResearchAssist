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
            
            if let action = page.pageAction {
                Button {
                    if let id = action.customActionID {
                        onCustomAction(id)
                    } else if action.actionType != .none {
                        onCustomAction(action.actionType.rawValue)
                    }
                } label: {
                    Label(
                        action.title,
                        systemImage: action.systemImage ?? "sparkles"
                    )
                }
                .buttonStyle(.bordered)
                .padding(.top, 8)
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
