import Foundation

extension Array {
    func at(_ index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}

extension Array where Element: Equatable {
    func reorder(by preferredOrder: [Element]) -> [Element] {
        return self.sorted { (a, b) -> Bool in
            guard let first = preferredOrder.firstIndex(of: a) else {
                return false
            }

            guard let second = preferredOrder.firstIndex(of: b) else {
                return true
            }

            return first < second
        }
    }
}
