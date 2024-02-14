import SwiftUI

struct MainScreenView_Previews: PreviewProvider {
    static var previews: some View {
        MainScreenView()
    }
}

struct MainScreenView: View {

    @Environment(\.openURL) private var openURL
    @State var model = ContentView.ViewModel.readFromStorage()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
#if os(macOS)
                        MacOSContentView()
#else
                        ContentView(viewModel: $model)
#endif
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
                                    Text("CIty: " + model.cities.toString())
                                        .lineLimit(3)
                                        .truncationMode(.tail)
                                }
                            }
                            HStack {
                                Button("Copy") {
#if os(iOS)
                                    UIPasteboard.general.string = resultURL.absoluteString
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
#endif
                                    Task {
                                        let data = try? await ContentView.ViewModel.readTest()
                                        print(data)
                                    }
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

struct SelectionDTO: Codable {
    var name: String
    var id: Int
}

//case revolut = "Revolut"
//case n26 = "N26"
//case wise = "Wise"
//
//var id: Self { self }
//var queryID: String {
//    switch self {
//        case .revolut:
//            "5356541"
//        case .n26:
//            "3116425"
//        case .wise:
//            "1769571"
//    }
//}
