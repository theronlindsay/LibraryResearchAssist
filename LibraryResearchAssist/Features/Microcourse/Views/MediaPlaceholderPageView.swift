import SwiftUI

struct MediaPlaceholderPageView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let page: CoursePage

    private var titleFont: Font {
        horizontalSizeClass == .regular ? .title : .title2
    }

    private var bodyFont: Font {
        horizontalSizeClass == .regular ? .title3 : .body
    }

    var body: some View {
        VStack(spacing: 12) {
            Text(page.title)
                .font(titleFont)
                .bold()

            RoundedRectangle(cornerRadius: 14)
                .fill(Color(uiColor: .tertiarySystemFill))
                .frame(height: 180)
                .overlay {
                    VStack(spacing: 8) {
                        Image(systemName: "play.rectangle")
                            .font(.title)
                        Text("Media/Interactive content placeholder")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

            Text(page.bodyText)
                .font(bodyFont)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview("Media Page") {
    MediaPlaceholderPageView(
        page: CoursePage(
            title: "Preview: Media",
            pageType: .media,
            bodyText: "Media preview area for future video and interactive blocks."
        )
    )
    .padding()
}
