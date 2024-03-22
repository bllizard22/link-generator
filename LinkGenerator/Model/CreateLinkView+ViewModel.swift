import Foundation

extension CreateLinkView {

    struct ViewModel: Codable, Identifiable {
        var id: ObjectIdentifier {
            return .init(Self.self)
        }

        var parameters = ParametersModel()

        var timeUnit = TimeUnit.day
        var timeAmount = 0
        var searchPhrase = ""

        var sorting = Sorting.recent
        var linkType = LinkType.url
        var isEasyApply = false
        var isFewApplicants = false

        func makeResult() -> URL? {
            let timeFactor = Int(timeUnit.queryID) ?? 0

            let queries = [
                URLQueryItem(
                    name: "f_T",
                    value: parameters.titles.toEncodedString()
                ),
                URLQueryItem(
                    name: "f_C",
                    value: parameters.companies.toEncodedString()
                ),
                URLQueryItem(
                    name: "f_CR",
                    value: parameters.countries.toEncodedString()
                ),
                URLQueryItem(
                    name: "f_PP",
                    value: parameters.cities.toEncodedString()
                ),
                URLQueryItem(
                    name: "f_TPR",
                    value: "r\(timeFactor * (timeAmount + 1))"
                ),
                URLQueryItem(
                    name: "geoId",
                    value: "92000000"
                ),
                URLQueryItem(
                    name: "keywords",
                    value: searchPhrase.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                ),
                URLQueryItem(
                    name: "location",
                    value: "Worldwide"
                ),
                URLQueryItem(
                    name: "f_AL",
                    value: isEasyApply ? "true" : ""
                ),
                URLQueryItem(
                    name: "f_EA",
                    value: isFewApplicants ? "true" : ""
                ),
                URLQueryItem(
                    name: "sortBy",
                    value: sorting.queryID
                )
            ].filter { $0.value != "" }
            
            var comps = URLComponents()
            comps.scheme = linkType == .url ? "https" : "linkedin"
            comps.host = linkType == .url ? "www.linkedin.com" : "jobs"
            comps.path = linkType == .url ? "/jobs/search/" : "/search/"
            comps.percentEncodedQueryItems = queries

            return comps.url
        }

        // MARK: - Preview Stub

        static func makeStubForPreview() -> Self {
            ViewModel(
                parameters: ParametersModel(
                    companies: [
                        "1": .init(name: "Revolut", searchID: "1"),
                        "2": .init(name: "Wise", searchID: "2", isSelected: true)
                    ],
                    titles: ["1": .init(name: "Software Engineer", searchID: "1")],
                    countries: ["1": .init(name: "Ireland", searchID: "1")],
                    cities: ["1": .init(name: "Dublin", searchID: "1")]
                ),
                timeUnit: .hour,
                timeAmount: 3,
                searchPhrase: "Some keys",
                sorting: .recent,
                linkType: .url,
                isEasyApply: false,
                isFewApplicants: true
            )
        }
    }
}
