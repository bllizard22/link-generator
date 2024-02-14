import SwiftUI

//struct MainScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainScreenView()
//    }
//}

final class ParametersManager {
    var companies: [SelectionDTO] = []

    func fetch() async {
        do {
            let data = try await readTest()
            self.companies = data.companies
        } catch {
            assertionFailure("Data manager error: \(error)")
        }
    }

    private func readTest() async throws -> CompaniesDTO {
        guard let url = URL(
            string: "https://raw.githubusercontent.com/bllizard22/link-generator/main/Identificators/companies.json"
        ) else {
            throw NSError()
        }

        let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
        let test = try JSONDecoder().decode(CompaniesDTO.self, from: data)

        return test
    }
}

struct MainScreenView: View {

    @Environment(\.openURL) private var openURL
    @State var model = ContentView.ViewModel.readFromStorage()
    @State var sellComp: SelectionDTO = .init(name: "", searchID: -1)
    @State var companies: [SelectionDTO] = []

    var dataManager = ParametersManager()

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
                Section {
                        if let resultURL = model.makeResult() {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(makeFiltersLine(model))
                                
                                if !model.searchPhrase.isEmpty {
                                    Text("Keywords: \(model.searchPhrase)")
                                }
                                if !model.titles.isEmpty {
                                    Text("Title: " + model.titles.toString())
                                        .lineLimit(3)
                                        .truncationMode(.tail)
                                }
                                if !model.companies.isEmpty {
                                    Text("Company: " + model.companies.toString())
                                        .lineLimit(3)
                                        .truncationMode(.tail)
                                }
                                if !model.countries.isEmpty {
                                    Text("Country: " + model.countries.toString())
                                        .lineLimit(3)
                                        .truncationMode(.tail)
                                }
                                if !model.cities.isEmpty {
                                    Text("City: " + model.cities.toString())
                                        .lineLimit(3)
                                        .truncationMode(.tail)
                                }

                                if !companies.isEmpty {
                                    Text("Comps: " + companies.compactMap { $0.name }.joined(separator: ", ") )

                                    Picker("", selection: $sellComp) {
                                        ForEach(companies, id: \.id) {
                                            Text($0.name).tag($0)
                                        }
                                    }
                                    Text(sellComp.name)
                                }
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
            }
        }
        .task {
            await dataManager.fetch()
            self.companies = dataManager.companies
            if let last = companies.last {
                sellComp = last
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

struct CompaniesDTO: Codable {
    var companies: [SelectionDTO]
}

struct SelectionDTO: Codable, Hashable, Identifiable {
    var id: String { name + String(searchID) }

    var name: String
    var searchID: Int

    enum CodingKeys: String, CodingKey {
        case name
        case searchID = "search_id"
    }
}
