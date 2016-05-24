import Foundation

internal class OmiseWarning {
    class func SDKWarn(message: String) {
        dump("[omise-ios-sdk] Warning: \(message)")
    }
}
