import Foundation

func sdkWarn(_ message: String) {
    dump("[omise-ios-sdk] WARN: \(message)")
}


extension Optional where Wrapped == String {
    public var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}

