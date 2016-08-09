import Foundation

public let OmiseErrorDomain = "co.omise"

public enum OmiseErrorUserInfoKey: String {
    case Location = "location"
    case Code = "code"
    case Message = "message"
    
    public var nsString: NSString {
        return rawValue as NSString
    }
}


/// An error type used in Omise iOS SDK.
public enum OmiseError: ErrorType {
    /// An API error returned from Omise API
    case API(code: String, message: String, location: String)
    /// An error that occur during requesting to Omise APIß
    case Unexpected(message: String, underlying: ErrorType?)
    
    public var nsError: NSError {
        switch self {
        case .API(let code, let message, let location):
            return NSError(domain: OmiseErrorDomain, code: code.hashValue, userInfo: [
                OmiseErrorUserInfoKey.Code.nsString: code,
                OmiseErrorUserInfoKey.Location.nsString: location,
                OmiseErrorUserInfoKey.Message.nsString: message,
                NSLocalizedDescriptionKey: message
                ])
            
        case .Unexpected(let message, let underlying):
            if let underlying = underlying as? AnyObject {
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