import SwiftUI

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(storage: [.readFromStorage()]
//    }
//}

@available(iOS 16, *)
struct ContentView: View {

    @Binding var viewModel: ViewModel
    @Environment(\.openURL) var openURL

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Form {
                    Section {
                        TextField("", text: $viewModel.searchPhrase)
                    } header: {
                        Text("Search Keywords")
                    } footer: {
                        Text("You can use 'AND', 'OR', 'NOT', '(' and ')'")
                    }

                    locationSection
                    sortingSection
                }
                if let resultURL = viewModel.makeResult() {
                    HStack {
                        Button {
                            openURL(resultURL)
                            viewModel.saveData()
                        } label: {
                            Text("Open")
                                .fontWeight(Font.Weight.semibold)
                                .foregroundStyle(Color.white)
                        }
                        .ignoresSafeArea()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.cyan)
                        .cornerRadius(12)
                        Button {
                            #if os(iOS)
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            #endif
                            viewModel.saveData()
                        } label: {
                            Text("Save")
                                .fontWeight(Font.Weight.semibold)
                                .foregroundStyle(Color.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.cyan)
                        .cornerRadius(12)
                        .ignoresSafeArea()
                    }
                    .padding()
                    .ignoresSafeArea()
                }
            }
        }
        .navigationTitle("Create link")
    }
}

private extension ContentView {
    var locationSection: some View {
        Section(
            "Parameters",
            content: {
                ForEach(ParametersNavigation.allCases) { parameter in
                    switch parameter {
                        case .title:
                            NavigationLink {
                                SelectionList(model: $viewModel.titles).navigationTitle(parameter.rawValue)
                            } label: {
                                Text(parameter.rawValue)
                            }
                        case .company:
                            NavigationLink {
                                SelectionList(model: $viewModel.companies).navigationTitle(parameter.rawValue)
                            } label: {
                                Text(parameter.rawValue)
                            }
                        case .countries:
                            NavigationLink {
                                SelectionList(model: $viewModel.countries).navigationTitle(parameter.rawValue)
                            } label: {
                                Text(parameter.rawValue)
                            }
                        case .cities:
                            NavigationLink {
                                SelectionList(model: $viewModel.cities).navigationTitle(parameter.rawValue)
                            } label: {
                                Text(parameter.rawValue)
                            }
                    }
                }
            }
        )
    }

    var sortingSection: some View {
        Section(
            "Sorting",
            content: {
                Picker("", selection: $viewModel.timeUnit) {
                    ForEach(TimeUnit.allCases) {
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 6)

                if viewModel.timeUnit != .any {
                    Picker("Period", selection: $viewModel.timeAmount) {
                        ForEach(1..<25) {
                            Text("\($0)")
                        }
                    }
                }

                Picker(selection: $viewModel.sorting) {
                    ForEach(Sorting.allCases) {
                        Text($0.rawValue)
                    }
                } label: {
                    Text("Sort by")
                }

                Toggle("EasyApply", isOn: $viewModel.isEasyApply)
                Toggle("Under 10 applications", isOn: $viewModel.isFewApplicants)
            }
        )
    }
}

// MARK: - ViewModel

extension ContentView {
    struct Test: Codable {
        var fruit: String
        var size: String
        var color: String
    }

    struct ViewModel: Codable, Identifiable {
        var id: ObjectIdentifier {
            return .init(Self.self)
        }

        var titles = Set<Title>()
        var companies = Set<Company>()
        var countries = Set<Country>()
        var cities = Set<City>()

        var timeUnit = TimeUnit.day
        var timeAmount = 0
        var searchPhrase = ""

        var sorting = Sorting.recent
        var isEasyApply = false
        var isFewApplicants = false

        var linkType: LinkType = .url

        static func readTest() async throws -> Test {
            guard let url = URL(string: "https://filesamples.com/samples/code/json/sample1.json") else {
                throw NSError()
            }

            let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
            let test = try JSONDecoder().decode(Test.self, from: data)

            return test
        }

        static func readFromStorage() -> Self {
            guard let data = UserDefaults.standard.value(forKey: "LinkedInLastSearch") as? Data,
                  let model = try? JSONDecoder().decode(Self.self, from: data)
            else {
                return ViewModel()
            }

            return ViewModel(
                titles: model.titles,
                companies: model.companies,
                countries: model.countries,
                cities: model.cities,
                timeUnit: model.timeUnit,
                timeAmount: model.timeAmount,
                searchPhrase: model.searchPhrase,
                sorting: model.sorting,
                isEasyApply: model.isEasyApply,
                isFewApplicants: model.isFewApplicants,
                linkType: model.linkType
            )
        }

        func makeResult() -> URL? {
            let timeFactor = Int(timeUnit.queryID) ?? 0

            let queries = [
                URLQueryItem(
                    name: "f_T",
                    value: titles.toEncodedString()
                ),
                URLQueryItem(
                    name: "f_C",
                    value: companies.toEncodedString()
                ),
                URLQueryItem(
                    name: "f_CR",
                    value: countries.toEncodedString()
                ),
                URLQueryItem(
                    name: "f_PP",
                    value: cities.toEncodedString()
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

        func saveData() {
            guard let data = try? JSONEncoder().encode(self) else {
                assertionFailure("Should always succeed")
                return
            }

            UserDefaults.standard.setValue(data, forKey: "LinkedInLastSearch")
        }
    }
}

// MARK: - Selection

struct SelectionList<T: Selection>: View {

    @Binding var model: Set<T>

    var body: some View {
        List {
            ForEach(
                T.allCases.sorted(by: { $0.rawValue < $1.rawValue })
            ) { type in
                SelectionCell(model: $model, type: type)
            }
        }.backgroundStyle(Color.primary)
    }
}

struct SelectionCell<T: Selection>: View {

    @Binding var model: Set<T>

    @State var type: T
    @State private var isChecked: Bool = false

    var body: some View {
        Button {
            updateVal()
        } label: {
            HStack {
                Text(type.rawValue)
                Spacer()
                Image(
                    systemName: isChecked
                    ? "checkmark.circle.fill"
                    : "circle"
                )
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(Color.gray)
            }
        }
        .foregroundColor(Color.primary)
        .onAppear(perform: {
            isChecked = model.contains(type)
        })
    }

    func updateVal() {
        isChecked.toggle()
        if isChecked {
            model.insert(type)
        } else {
            model.remove(type)
        }
    }
}

// MARK: - Helpers

struct CheckboxStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Image(
                systemName: configuration.isOn
                ? "checkmark.circle.fill"
                : "circle"
            )
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(Color.gray)
        }
        .contentShape(Rectangle())
        .onTapGesture { configuration.isOn.toggle() }
    }
}

// MARK: - Data models

enum ParametersNavigation: String, CaseIterable, Identifiable {
    case title = "Job Title"
    case company = "Companies"
    case countries = "Countries"
    case cities = "Cities"

    var id: Self { self }
}

protocol Selection: CaseIterable, Identifiable, Hashable, Codable {
    var rawValue: String { get }
    var queryID: String { get }
}

enum LinkType: Codable {
    case deeplink
    case url
}

enum Country: String, Selection {
    case germany = "Germany"
    case netherlands = "Netherlands"
    case spain = "Spain"
    case portugal = "Portugal"
    case sweden = "Sweden"
    case finland = "Finland"
    case denmark = "Denmark"
    case norway = "Norway"

    case czechia = "Czechia"
    case poland = "Poland"
    case ireland = "Ireland"
    case uk = "UK"
    case france = "France"

    case uae = "UAE"

    var id: Self { self }
    var queryID: String {
        switch self {
            case .germany:
                "101282230"
            case .netherlands:
                "102890719"
            case .spain:
                "105646813"
            case .portugal:
                "100364837"
            case .sweden:
                "105117694"
            case .finland:
                "100456013"
            case .denmark:
                "104514075"
            case .norway:
                "103819153"
            case .czechia:
                "104508036"
            case .poland:
                "105072130"
            case .ireland:
                "104738515"
            case .uk:
                "101165590"
            case .france:
                "105015875"
            case .uae:
                "104305776"
        }
    }
}

enum City: String, Selection {
    case berlin = "Berlin"

    var id: Self { self }
    var queryID: String {
        switch self {
            case .berlin:
                "106967730"
        }
    }
}

enum Title: String, Selection {
    case iosDeveloper = "iOS Developer"
    case mobileDeveloper = "Mobile Developer"
    case softwareEngineer = "Software Engineer"
    case seniorSWE = "Senior Software Engineer"
    case leadSWE = "Lead Software Engineer"

    var id: Self { self }
    var queryID: String {
        switch self {
            case .iosDeveloper:
                "25204"
            case .mobileDeveloper:
                "7110"
            case .softwareEngineer:
                "9"
            case .seniorSWE:
                "39"
            case .leadSWE:
                "1176"
        }
    }
}

enum Company: String, Selection {
    case revolut = "Revolut"
    case n26 = "N26"
    case wise = "Wise"

    var id: Self { self }
    var queryID: String {
        switch self {
            case .revolut:
                "5356541"
            case .n26:
                "3116425"
            case .wise:
                "1769571"
        }
    }
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

extension Sequence where Element: Selection {
    func toEncodedString() -> String {
        self.map { $0.queryID }.joined(separator: "%2C")
    }

    func toString() -> String {
        self.map { $0.rawValue }
            .sorted(by: { $0.lowercased() < $1.lowercased() })
            .joined(separator: ", ")
    }
}
