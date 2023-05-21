import Foundation

public enum TestCaseValue<T> {
    case valid(_ value: T)
    case invalid(_ value: T, _ reason: String = "")

    var value: T {
        switch self {
        case .valid(let value), .invalid(let value, _): return value
        }
    }

    var isValid: Bool {
        switch self {
        case .valid: return true
        default: return false
        }
    }

    var invalidReason: String? {
        switch self {
        case .invalid(_, let reason): return reason
        default: return nil
        }
    }
}

public class TestCaseValueSet<T: Hashable> {
    private let values: [TestCaseValue<T>]
    init(_ values: [TestCaseValue<T>]) {
        self.values = values
    }

    public var all: [T] {
        values.map { $0.value }
    }

    public var valid: T? {
        values.first { $0.isValid }?.value
    }

    public var validAll: [T] {
        values
            .filter { $0.isValid }
            .map { $0.value }
    }

    public var invalid: T? {
        values.first { !$0.isValid }?.value
    }

    public var invalidAll: [T] {
        values
            .filter { !$0.isValid }
            .map { $0.value }
    }
}
