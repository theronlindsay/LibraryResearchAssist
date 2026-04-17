import Foundation

enum CoursePageType: String, Codable {
    case text
    case checklist
    case media
}

struct CoursePage: Identifiable, Codable {
    let id: UUID
    let title: String
    let pageType: CoursePageType
    let bodyText: String
    let checklistItems: [String]

    init(
        id: UUID = UUID(),
        title: String,
        pageType: CoursePageType,
        bodyText: String,
        checklistItems: [String] = []
    ) {
        self.id = id
        self.title = title
        self.pageType = pageType
        self.bodyText = bodyText
        self.checklistItems = checklistItems
    }
}

struct Microcourse: Identifiable, Codable {
    let id: UUID
    let title: String
    let pages: [CoursePage]

    init(id: UUID = UUID(), title: String, pages: [CoursePage]) {
        self.id = id
        self.title = title
        self.pages = pages
    }

    static let sampleCourse = Microcourse(
        title: "Library Research Microcourse",
        pages: [
            CoursePage(
                title: "Welcome",
                pageType: .text,
                bodyText: "This course teaches a repeatable process to quickly find and validate sources in your library system."
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
                ]
            ),
            CoursePage(
                title: "Media Placeholder",
                pageType: .media,
                bodyText: "Future page type for video, image walkthroughs, or interactive demos."
            )
        ]
    )
}
