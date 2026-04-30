import SwiftUI

struct MicrocourseContainerView: View {

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let course: Microcourse

    @State private var currentIndex = 0
    @State private var isAssistantVisible = false

    @State private var showARMap = false
    @State private var showResearchAssistant = false
    @State private var showBonus = false

    private var isLargeScreen: Bool {
        horizontalSizeClass == .regular
    }

    var body: some View {
        GeometryReader { geometry in

            let page = course.pages[currentIndex]
            let horizontalPadding: CGFloat = 16
            let buttonAreaHeight: CGFloat = isLargeScreen ? 152 : 128

            let popupMaxHeight = max(
                220,
                geometry.size.height - buttonAreaHeight - 24
            )

            let isLargePopupDevice = geometry.size.width >= 700
            let targetIPhoneWidth: CGFloat = 390
            let targetIPhoneHeight: CGFloat = 760

            let popupWidth = isLargePopupDevice
                ? min(targetIPhoneWidth, geometry.size.width - (horizontalPadding * 2))
                : geometry.size.width - (horizontalPadding * 2)

            let popupHeight = isLargePopupDevice
                ? min(targetIPhoneHeight, popupMaxHeight)
                : popupMaxHeight

            ZStack(alignment: .bottomTrailing) {

                // =========================
                // MAIN PAGE STACK (UNCHANGED)
                // =========================
                VStack(spacing: 16) {

                    ProgressView(
                        value: Double(currentIndex + 1),
                        total: Double(course.pages.count)
                    )
                    .padding(.top, 8)
                    .scaleEffect(isLargeScreen ? 1.15 : 1.0)

                    Text("Page \(currentIndex + 1) of \(course.pages.count)")
                        .font(isLargeScreen ? .body : .caption)
                        .foregroundStyle(.secondary)

                    CoursePageFactory.makePageView(
                        for: page,
                        onCustomAction: { id in

                            switch id {

                            case "openARMapExperience":
                                showARMap = true

                            case "launchResearchAssistant":
                                showResearchAssistant = true

                            case "showBonusContent", "playMedia":
                                showBonus = true

                            default:
                                break
                            }
                        }
                    )
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 8)
                .padding(.bottom, buttonAreaHeight)

                // =========================
                // ASSISTANT OVERLAY (UNCHANGED)
                // =========================
                AIAssistantAndARView(
                    initialMode: .assist,
                    showsModePicker: true,
                    isActive: isAssistantVisible
                )
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(uiColor: .separator), lineWidth: 1)
                }
                .shadow(radius: 12)
                .frame(width: popupWidth, height: popupHeight)
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, buttonAreaHeight)
                .opacity(isAssistantVisible ? 1 : 0)
                .offset(y: isAssistantVisible ? 0 : 24)
                .allowsHitTesting(isAssistantVisible)
                .accessibilityHidden(!isAssistantVisible)

                // =========================
                // NAV BUTTONS (UNCHANGED)
                // =========================
                HStack(alignment: .bottom) {

                    Button("Back") {
                        currentIndex = max(0, currentIndex - 1)
                    }
                    .font(isLargeScreen ? .title3 : .body)
                    .disabled(currentIndex == 0)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 12) {

                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isAssistantVisible.toggle()
                            }
                        } label: {
                            Image(systemName: isAssistantVisible ? "message.fill" : "message")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 6)
                        }

                        Button(currentIndex == course.pages.count - 1 ? "Done" : "Next") {
                            if currentIndex < course.pages.count - 1 {
                                currentIndex += 1
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, 16)
            }
        }

        .navigationTitle(course.title)
        .navigationBarTitleDisplayMode(isLargeScreen ? .large : .inline)

        // =========================
        // FULL SCREEN ROUTING (NEW ONLY)
        // =========================
        .fullScreenCover(isPresented: $showARMap) {
            ARMapExpView()
        }
        .sheet(isPresented: $showBonus) {
            Text("Bonus Content")
        }
    }
}
