import Foundation

extension Optional where Wrapped == String {
    public var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}
