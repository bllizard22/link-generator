import SwiftUI

struct ContentView_Previews: PreviewProvider {
    @State static var model = ContentView.ViewModel.makeStubForPreview()

    static var previews: some View {
        ContentView(viewModel: $model)
    }
}

@available(iOS 16, *)
struct ContentView: View {

    @Environment(\.openURL) var openURL

    @Binding var viewModel: ViewModel

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

                    NavigationLink {
                        SelectionListView(viewModel: $viewModel)
                        .backgroundStyle(Color.primary)
                        .navigationTitle("Country")
                    } label: {
                        Text("Select Companies")
                    }

                    Text(
                        "Comps: " + viewModel.parameters.companies.values
                        .compactMap { $0.isSelected ? $0.name : nil }
                        .joined(separator: ", ")
                    )

                    sortingSection

                }.padding(.bottom, 80)
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
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
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

struct SelectionListView: View {
    @Binding var viewModel: ContentView.ViewModel

    var body: some View {
        List(Array(viewModel.parameters.companies.values)) { company in
            Button {
                let updated = Parameter(
                    name: company.name,
                    searchID: company.searchID,
                    isSelected: !company.isSelected
                )
                viewModel.parameters.companies[company.searchID] = updated
            } label: {
                HStack {
                    Text(company.name)
                    Spacer()
                    Image(
                        systemName: company.isSelected
                        ? "checkmark.circle.fill"
                        : "circle"
                    )
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color.gray)
                }
            }
            .foregroundColor(Color.primary)
        }
        .navigationTitle("Select Companies")
    }
}

private extension ContentView {

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
    struct ViewModel: Codable, Identifiable {
        var id: ObjectIdentifier {
            return .init(Self.self)
        }

        var parameters = ParametersModel()

        var timeUnit = TimeUnit.day
        var timeAmount = 0
        var searchPhrase = ""

        var sorting = Sorting.recent
        var isEasyApply = false
        var isFewApplicants = false

        var linkType: LinkType = .url

        static func readFromStorage() -> Self {
            guard let data = UserDefaults.standard.value(forKey: "LinkedInLastSearch") as? Data,
                  let model = try? JSONDecoder().decode(Self.self, from: data)
            else {
                return ViewModel()
            }

            return ViewModel(
                parameters: model.parameters,
                timeUnit: model.timeUnit,
                timeAmount: model.timeAmount,
                searchPhrase: model.searchPhrase,
                sorting: model.sorting,
                isEasyApply: model.isEasyApply,
                isFewApplicants: model.isFewApplicants,
                linkType: model.linkType
            )
        }

        func saveData() {
            guard let data = try? JSONEncoder().encode(self) else {
                assertionFailure("Should always succeed")
                return
            }

            UserDefaults.standard.setValue(data, forKey: "LinkedInLastSearch")
        }

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
                isEasyApply: false,
                isFewApplicants: true,
                linkType: .url
            )
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

protocol Selection: CaseIterable, Identifiable, Hashable, Codable {
    var rawValue: String { get }
    var queryID: String { get }
}

enum LinkType: Codable {
    case deeplink
    case url
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

// MARK: - Set and Dict helpers

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

extension Dictionary where Key == String, Value == Parameter {
    func toEncodedString() -> String {
        self.map { "\($0.value.searchID)" }.joined(separator: "%2C")
    }

    func toString() -> String {
        self.map { $0.value.name }
            .sorted(by: { $0.lowercased() < $1.lowercased() })
            .joined(separator: ", ")
    }
}
