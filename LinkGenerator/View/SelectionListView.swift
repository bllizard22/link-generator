import SwiftUI

struct SelectionNavLink: View {
    @Binding var parameters: [String: Parameter]
    var name: String

    var body: some View {
        NavigationLink {
            SelectionListView(parameters: $parameters)
                .backgroundStyle(Color.primary)
                .navigationTitle(name)
        } label: {
            Text(name)
            Spacer()
            Text(name)
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
                    .foregroundColor(Color.gray)
                }
            }
            .foregroundColor(Color.primary)
        }
    }
}
