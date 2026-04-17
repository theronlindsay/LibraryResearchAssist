import SwiftUI

struct HomeScreenView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 20)

            VStack(spacing: 24) {
                Text("Albertson's Library")
                    .font(.largeTitle)
                    .bold()

                Text("Choose a feature to start")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                VStack(spacing: 16) {
                    NavigationLink {
                        MicrocourseContainerView(course: .sampleCourse)
                    } label: {
                        FeatureCardView(
                            title: "Library Research Microcourse",
                            subtitle: "Start the Albertson's Library Research Microcourse",
                            icon: "book"
                        )
                    }

                    NavigationLink {
                        ResearchAssistantView()
                    } label: {
                        FeatureCardView(
                            title: "Research Assistant",
                            subtitle: "Search for more books or find more of a book you found.",
                            icon: "magnifyingglass.circle"
                        )
                    }
                }
                .frame(maxWidth: 620)
            }

            Spacer(minLength: 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
}

struct FeatureCardView: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .frame(width: 56, height: 56)
                .foregroundStyle(.white)
                .background(Color.blue)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, minHeight: 110)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview("Home") {
    NavigationStack {
        HomeScreenView()
    }
}
