struct ParametersModelDTO: Codable {
    var companies: [DTO]?
    var titles: [DTO]?
    var countries: [DTO]?
    var cities: [DTO]?
}

struct DTO: Codable {

    var name: String
    var searchID: Int

    enum CodingKeys: String, CodingKey {
        case name
        case searchID = "search_id"
    }
}

struct ParametersModel: Codable {
    var companies: [String: Parameter]
    var titles: [String: Parameter]
    var countries: [String: Parameter]
    var cities: [String: Parameter]

    init(
        companies: [String: Parameter] = [:],
        titles: [String: Parameter] = [:],
        countries: [String: Parameter] = [:],
        cities: [String: Parameter] = [:]
    ) {
        self.companies = companies
        self.titles = titles
        self.countries = countries
        self.cities = cities
    }

    init?(from dto: ParametersModelDTO) {
        self.companies = Self.makeDict(from: dto.companies ?? [])
        self.titles = Self.makeDict(from: dto.titles ?? [])
        self.countries = Self.makeDict(from: dto.countries ?? [])
        self.cities = Self.makeDict(from: dto.cities ?? [])
    }

    private static func makeDict(from dto: [DTO]) -> [String: Parameter] {
        dto.reduce(into: [String: Parameter]()) { (output, item) in
            output[String(item.searchID)] = .init(name: item.name, searchID: String(item.searchID))
        }
    }
}

struct Parameter: Equatable, Hashable, Codable, Identifiable {
    var id: String { searchID }

    var name: String
    var searchID: String
    var isSelected = false
}
