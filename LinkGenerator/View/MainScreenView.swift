import SwiftUI

struct MainScreenView_Previews: PreviewProvider {
    static var previews: some View {
        MainScreenView()
    }
}

struct MainScreenView: View {

    @State private var model = CreateLinkView.ViewModel.readFromStorage()
    @State var isLoaded: Bool = false

    private var dataManager = ParametersManager()

    var body: some View {
        NavigationStack {
            if isLoaded {
                List {
                    Section {
                        NavigationLink {
                            CreateLinkView(viewModel: $model)
                        } label: {
                            Text("Create new link")
                        }
                    }

                    LastUsedSection(model: $model)
                }
            } else {
                Text("Fetching data...")
                    .font(.largeTitle)
                    .padding(.top)
            }
        }
        .task {
            defer {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.isLoaded = true
                }
            }

            await dataManager.fetch()
            guard let parameters = dataManager.parameters else {
                return
            }

            // Merge fetched data with existing local one
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
}

