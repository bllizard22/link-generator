import SwiftUI

struct SelectionNavLink: View {
    @Binding var parameters: [String: Parameter]
    var name: String

    var body: some View {
        NavigationLink {
            SelectionListView(parameters: $parameters)
                .navigationTitle(name)
        } label: {
            HStack {
                Text(name)
                if parameters.contains(where: { $0.value.isSelected }) {
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                }
            }
        }
    }
}

struct SelectionListView: View {
    @Binding var parameters: [String: Parameter]

    var body: some View {
        List(Array(parameters.values)) { parameter in
            Button {
                let updated = Parameter(
                    name: parameter.name,
                    searchID: parameter.searchID,
                    isSelected: !parameter.isSelected
                )
                parameters[parameter.searchID] = updated
            } label: {
                HStack {
                    Text(parameter.name)
                    Spacer()
                    Image(
                        systemName: parameter.isSelected
                        ? "checkmark.circle.fill"
                        : "circle"
                    )
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color.cyan)
                }
            }
            .foregroundColor(Color.primary)
        }
    }
}
