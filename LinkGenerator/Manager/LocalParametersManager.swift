import Foundation

struct LocalParametersManager {
    static let lastListKey = "LinkedInLastSearch"

    static func readFromStorage() -> CreateLinkView.ViewModel {
        guard let data = UserDefaults.standard.value(forKey: lastListKey) as? Data,
              let model = try? JSONDecoder().decode(CreateLinkView.ViewModel.self, from: data)
        else {
            return CreateLinkView.ViewModel()
        }

        return CreateLinkView.ViewModel(
            parameters: model.parameters,
            timeUnit: model.timeUnit,
            timeAmount: model.timeAmount,
            searchPhrase: model.searchPhrase,
            sorting: model.sorting,
            linkType: model.linkType,
            isEasyApply: model.isEasyApply,
            isFewApplicants: model.isFewApplicants
        )
    }

    static func saveData(_ model: CreateLinkView.ViewModel) {
        guard let data = try? JSONEncoder().encode(model) else {
            assertionFailure("Should always succeed")
            return
        }

        UserDefaults.standard.setValue(data, forKey: Self.lastListKey)
    }
}
