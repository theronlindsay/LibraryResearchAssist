import SwiftUI

struct ChecklistPageView: View {
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

                ForEach(page.checklistItems, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle")
                            .foregroundStyle(.green)
                        Text(item)
                            .font(bodyFont)
                    }
                }
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
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview("Checklist Page") {
    ChecklistPageView(
        page: CoursePage(
            title: "Preview: Checklist",
            pageType: .checklist,
            bodyText: "Checklist preview for lesson flow:",
            checklistItems: [
                "Choose keywords",
                "Set date filters",
                "Review abstracts"
            ]
        ),
        onCustomAction: { actionID in
            print("Preview custom action: \(actionID)")
        }
    )
    .padding()
}
