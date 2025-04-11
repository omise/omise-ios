import Foundation

typealias Handler<T> = ((T) -> Void)?
typealias VoidHandler = (() -> Void)?

extension Optional where Wrapped == String {
    public var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}
