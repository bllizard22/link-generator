import SwiftUI

struct ContentView_Previews: PreviewProvider {
    @State static var model = CreateLinkView.ViewModel.makeStubForPreview()

    static var previews: some View {
        CreateLinkView(viewModel: $model)
    }
}

@available(iOS 16, *)
struct CreateLinkView: View {

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

                    Section {
                        SelectionNavLink(parameters: $viewModel.parameters.companies, name: "Company")
                        SelectionNavLink(parameters: $viewModel.parameters.titles, name: "Job Title")
                        SelectionNavLink(parameters: $viewModel.parameters.countries, name: "Country")
                        SelectionNavLink(parameters: $viewModel.parameters.cities, name: "City")
                    }

                    SortingSection(viewModel: $viewModel)

                }.padding(.bottom, 80)

                if let resultURL = viewModel.makeResult() {
                    ButtonGroup(viewModel: $viewModel, resultURL: resultURL)
                }
            }
        }
        .navigationTitle("Create link")
    }
}
