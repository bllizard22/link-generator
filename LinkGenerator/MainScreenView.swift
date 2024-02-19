import SwiftUI

struct MainScreenView_Previews: PreviewProvider {
    static var previews: some View {
        MainScreenView()
    }
}

class ParametersManager {
    var parameters: ParametersModel?

    private let urlBase = "https://raw.githubusercontent.com/bllizard22/link-generator/main/Identificators/"

    func fetch() async {
        do {
            let dto = try await fetchRemoteValues()
            DispatchQueue.main.async {
                self.parameters = ParametersModel(from: dto)
            }
        } catch {
            assertionFailure("Data manager error: \(error)")
        }
    }

    private func fetchRemoteValues() async throws -> ParametersModelDTO {
        guard let url = URL(
            string: urlBase + "parameters.json"
        ) else {
            throw NSError()
        }

        let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
        let parameters = try JSONDecoder().decode(ParametersModelDTO.self, from: data)

        return parameters
    }
}

struct MainScreenView: View {

    @Environment(\.openURL) private var openURL
    @State private var model = ContentView.ViewModel.readFromStorage()
    @State var isLoaded: Bool = false

    private var dataManager = ParametersManager()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        ContentView(viewModel: $model)
                    } label: {
                        Text("Create new link")
                    }
                }
                if isLoaded {
                    Section {
                        if let resultURL = model.makeResult() {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(makeFiltersLine(model))
                                
                                if !model.searchPhrase.isEmpty {
                                    Text("Keywords: \(model.searchPhrase)")
                                }
                                if !model.parameters.titles.isEmpty {
                                    Text("Title: " + model.parameters.titles.toString())
                                        .lineLimit(3)
                                        .truncationMode(.tail)
                                }
                                if !model.parameters.companies.isEmpty {
                                    Text("Company: " + model.parameters.companies.toString())
                                        .lineLimit(3)
                                        .truncationMode(.tail)
                                }
                                if !model.parameters.countries.isEmpty {
                                    Text("Country: " + model.parameters.countries.toString())
                                        .lineLimit(3)
                                        .truncationMode(.tail)
                                }
                                if !model.parameters.cities.isEmpty {
                                    Text("City: " + model.parameters.cities.toString())
                                        .lineLimit(3)
                                        .truncationMode(.tail)
                                }
                                
                                Text(
                                    "Manager: " + (dataManager.parameters?.companies ?? [:])
                                        .compactMap { $0.value.name }
                                        .joined(separator: ", ")
                                )
                                Text(
                                    "Model: " + model.parameters.companies.values
                                        .compactMap { $0.name }
                                        .joined(separator: ", ")
                                )
                                Text(
                                    "Sellected: " + model.parameters.companies.values
                                        .compactMap { $0.isSelected ? $0.name : nil }
                                        .joined(separator: ", ")
                                )
                            }
                            HStack {
                                Button("Copy") {
                                    UIPasteboard.general.string = resultURL.absoluteString
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                
                                Spacer()
                                
                                Button {
                                    openURL(resultURL)
                                } label: {
                                    Text("Open")
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            .padding(.horizontal, 30)
                        }
                    } header: {
                        Text("Last used")
                    }
                } else {
                    Text("Fetching data...")
                }
            }
        }
        .task {
            defer { self.isLoaded = true }

            await dataManager.fetch()
            guard let parameters = dataManager.parameters else {
                return
            }

            self.model.parameters.companies.merge(parameters.companies) { old, new in
                Parameter(name: new.name, searchID: new.searchID, isSelected: old.isSelected)
            }
            self.model.parameters.titles.merge(parameters.titles) { old, new in
                Parameter(name: new.name, searchID: new.searchID, isSelected: old.isSelected)
            }
            self.model.parameters.countries.merge(parameters.countries) { old, new in
                Parameter(name: new.name, searchID: new.searchID, isSelected: old.isSelected)
            }
            self.model.parameters.cities.merge(parameters.cities) { old, new in
                Parameter(name: new.name, searchID: new.searchID, isSelected: old.isSelected)
            }

        }
    }

    private func makeFiltersLine(_ model: ContentView.ViewModel) -> String {
        var output = [String]()
        output.append(model.sorting.rawValue)
        output.append(
            model.timeUnit != .any
            ? "\(model.timeAmount + 1) \(model.timeUnit.rawValue)"
            : model.timeUnit.rawValue
        )
        if model.isEasyApply { output.append("EasyApply") }
        if model.isFewApplicants { output.append("Under 10") }
        return output.joined(separator: " | ")
    }
}

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
