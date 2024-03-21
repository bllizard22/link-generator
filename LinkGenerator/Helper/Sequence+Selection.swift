import Foundation

extension Sequence where Element: Selection {
    func toEncodedString() -> String {
        self.map { $0.queryID }.joined(separator: "%2C")
    }

    func toString() -> String {
        self.map { $0.rawValue }
            .sorted(by: { $0.lowercased() < $1.lowercased() })
            .joined(separator: ", ")
    }
}
