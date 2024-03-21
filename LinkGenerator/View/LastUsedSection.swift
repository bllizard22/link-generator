import SwiftUI

struct LastUsedSection: View {

    @Environment(\.openURL) private var openURL
    @Binding var model: CreateLinkView.ViewModel

    var body: some View {
        Section {
            if let resultURL = model.makeResult() {
                VStack(alignment: .leading, spacing: 8) {
                    Text(makeFiltersLine(model))

                    let companies = model.parameters.companies.toString(isSelected: true)
                    let titles = model.parameters.titles.toString(isSelected: true)
                    let countries = model.parameters.countries.toString(isSelected: true)
                    let cities = model.parameters.cities.toString(isSelected: true)

                    if !model.searchPhrase.isEmpty {
                        Text("Keywords: \(model.searchPhrase)")
                    }
                    if !companies.isEmpty {
                        Text("Company: " + companies).lineLimit(1)
                    }
                    if !titles.isEmpty {
                        Text("Title: " + titles).lineLimit(1)
                    }
                    if !countries.isEmpty {
                        Text("Country: " + countries).lineLimit(1)
                    }
                    if !cities.isEmpty {
                        Text("City: " + cities).lineLimit(1)
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

    // MARK: - Private Methods

    private func makeFiltersLine(_ model: CreateLinkView.ViewModel) -> String {
        var output = [String]()
        output.append(model.linkType.rawValue)
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
