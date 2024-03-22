import Foundation

extension Dictionary where Key == String, Value == Parameter {
    func toEncodedString() -> String {
        self.values.compactMap { $0.isSelected ? "\($0.searchID)" : nil }
        .joined(separator: "%2C")
    }

    func toString(isSelected: Bool = false) -> String {
        self.values.compactMap {
            guard isSelected else {
                return $0.name
            }

            return $0.isSelected ? $0.name : nil
        }
        .sorted(by: { $0.lowercased() < $1.lowercased() })
        .joined(separator: ", ")
    }
}
