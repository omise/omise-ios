import Foundation

public class OmiseWarning {
    
    public class func SDKWarning(message: String) {
        dump("[omise-ios-sdk] Warning: \(message)")
    }
}
