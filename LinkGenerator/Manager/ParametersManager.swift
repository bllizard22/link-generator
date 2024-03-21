import Foundation

class ParametersManager {
    var parameters: ParametersModel?

    private let urlBase = "https://raw.githubusercontent.com/bllizard22/link-generator/main/Identificators/"

    func fetch() async {
        do {
            let dto = try await fetchRemoteValues()
            DispatchQueue.main.async {
                self.parameters = ParametersModel(from: dto)
            }
        } catch {
            assertionFailure("Data manager error: \(error)")
        }
    }

    private func fetchRemoteValues() async throws -> ParametersModelDTO {
        guard let url = URL(
            string: urlBase + "parameters.json"
        ) else {
            throw NSError()
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let parameters = try JSONDecoder().decode(ParametersModelDTO.self, from: data)

        return parameters
    }
}
