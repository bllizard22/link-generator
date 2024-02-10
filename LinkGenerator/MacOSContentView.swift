import SwiftUI

struct MacOSContentView_Previews: PreviewProvider {
    static var previews: some View {
        MacOSContentView()
    }
}

@available(macOS 13, *)
struct MacOSContentView: View {

    @State private var viewModel = ViewModel.readFromStorage()
    @Environment(\.openURL) var openURL

    var body: some View {
        VStack {
            NavigationStack {
                Form {
                    Section {
                        TextField("", text: $viewModel.searchPhrase)
                    } header: {
                        Text("Keywords")
                    } footer: {
                        Text("You can use 'AND', 'OR', 'NOT', '(' and ')'")
                    }

                    locationSection
                    sortingSection
                }.padding()
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
                        #if os(macOS)
                            let pasteboard = NSPasteboard.general
                            pasteboard.clearContents()
                            pasteboard.setString(
                                resultURL.absoluteString,
                                forType: .string
                            )
                        #endif
                        viewModel.saveData()

                    } label: {
                        Text("Copy")
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
}

private extension MacOSContentView {
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
                Picker(selection: $viewModel.timeUnit) {
                    ForEach(TimeUnit.allCases) {
                        Text($0.rawValue)
                    }
                } label: {
                    Text("Time Period")
                }
                Picker("Period Duration", selection: $viewModel.timeAmount) {
                    ForEach(1..<25) {
                        Text("\($0)")
                    }
                }.disabled(viewModel.timeUnit == .any)

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

extension MacOSContentView {
    struct ViewModel: Codable {
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
