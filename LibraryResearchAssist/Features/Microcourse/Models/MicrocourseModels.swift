import Foundation

enum CoursePageType: String, Codable {
    case text
    case checklist
    case media
}

enum ActionType: String, Codable {
    case none
    case playMedia
    case favorite
    case openResource
    case custom
}

struct PageAction: Codable {
    let title: String
    let systemImage: String?
    let actionType: ActionType
    let customActionID: String?

    init(
        title: String,
        systemImage: String? = nil,
        actionType: ActionType,
        customActionID: String? = nil
    ) {
        self.title = title
        self.systemImage = systemImage
        self.actionType = actionType
        self.customActionID = customActionID
    }
}

struct CoursePage: Identifiable, Codable {
    let id: UUID
    let title: String
    let pageType: CoursePageType
    let bodyText: String
    let checklistItems: [String]
    let pageAction: PageAction?

    init(
        id: UUID = UUID(),
        title: String,
        pageType: CoursePageType,
        bodyText: String,
        checklistItems: [String] = [],
        pageAction: PageAction? = nil
    ) {
        self.id = id
        self.title = title
        self.pageType = pageType
        self.bodyText = bodyText
        self.checklistItems = checklistItems
        self.pageAction = pageAction
    }
}

struct Microcourse: Identifiable, Codable {
    let id: UUID
    let title: String
    let pages: [CoursePage]

    init(
        id: UUID = UUID(),
        title: String,
        pages: [CoursePage]
    ) {
        self.id = id
        self.title = title
        self.pages = pages
    }
}

extension Microcourse {
    static let sampleCourse = Microcourse(
        title: "Library Research Microcourse",
        pages: [
            CoursePage(
                title: "Welcome",
                pageType: .text,
                bodyText: "This course teaches a repeatable process to quickly find and validate sources."
            ),

            CoursePage(
                title: "Search Strategy Checklist",
                pageType: .checklist,
                bodyText: "Use this sequence before running a catalog search:",
                checklistItems: [
                    "Clarify your research question",
                    "List 3-5 keyword variations",
                    "Identify date range and source type",
                    "Define inclusion and exclusion criteria"
                ],
                pageAction: PageAction(
                    title: "Open AR Exploration",
                    systemImage: "star.fill",
                    actionType: .custom,
                    customActionID: "openARMapExperience"
                )
            ),

            CoursePage(
                title: "Media Placeholder",
                pageType: .media,
                bodyText: "Future page type for interactive demos.",
                pageAction: PageAction(
                    title: "Play Video",
                    systemImage: "play.fill",
                    actionType: .playMedia
                )
            )
        ]
    )
}
