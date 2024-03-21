protocol Selection: CaseIterable, Identifiable, Hashable, Codable {
    var rawValue: String { get }
    var queryID: String { get }
}

enum Sorting: String, Selection {
    case recent = "Recent"
    case relevant = "Relevant"

    var id: Self { self }
    var queryID: String {
        switch self {
            case .recent:
                "DD"
            case .relevant:
                "R"
        }
    }
}

enum TimeUnit: String, Selection {
    case any = "Any"
    case hour = "Hour"
    case day = "Day"
    case week = "Week"
    case month = "Month"

    var id: Self { self }
    var queryID: String {
        switch self {
            case .any:
                ""
            case .hour:
                "3600"
            case .day:
                "86400"
            case .week:
                "604800"
            case .month:
                "2628000"
        }
    }
}

enum LinkType: String, CaseIterable, Identifiable, Codable {
    case deeplink = "Deeplink"
    case url = "URL"

    var id: Self { self }
}
