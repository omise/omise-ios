import Foundation

public let OmiseErrorDomain = "co.omise"

public enum OmiseErrorUserInfoKey: String {
    case location = "location"
    case code = "code"
    case message = "message"
    
    public var nsString: NSString {
        return rawValue as NSString
    }
}


/// Represent errors from the Omise iOS SDK.
public enum OmiseError: Error {
    /// API error returned from Omise API
    case api(code: String, message: String, location: String)
    /// Any unexpected errors that may happen during Omise API requests.
    case unexpected(message: String, underlying: Error?)
    
    public var nsError: NSError {
        switch self {
        case .api(let code, let message, let location):
            return NSError(domain: OmiseErrorDomain, code: code.hashValue, userInfo: [
                OmiseErrorUserInfoKey.code.nsString: code,
                OmiseErrorUserInfoKey.location.nsString: location,
                OmiseErrorUserInfoKey.message.nsString: message,
                NSLocalizedDescriptionKey: message
                ])
            
        case .unexpected(let message, let underlying):
            if let underlying = underlying as? NSError {
                return NSError(domain: OmiseErrorDomain, code: 0, userInfo: [
                    NSLocalizedDescriptionKey: message,
                    NSUnderlyingErrorKey: underlying
                    ])
                
            } else {
                return NSError(domain: OmiseErrorDomain, code: 0, userInfo: [
                    NSLocalizedDescriptionKey: message
                    ])
            }
        }
    }
}
