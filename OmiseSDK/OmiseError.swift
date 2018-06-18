import Foundation

public let OmiseErrorDomain = "co.omise"

public enum ErrorUserInfoKey: String, CodingKey {
    case location = "location"
    case code = "code"
    case message = "message"
}


/// Represent errors from the Omise iOS SDK.
public enum OmiseError: CustomNSError, LocalizedError, Decodable {
    /// API error returned from Omise API
    case api(code: String, message: String, location: String)
    /// Any unexpected errors that may happen during Omise API requests.
    case unexpected(message: String, underlying: Error?)
    
    public static var errorDomain: String {
        return OmiseErrorDomain
    }
    
    public var errorCode: Int {
        switch self {
        case .api(code: let code, message: _, location: _):
            return code.hashValue
        case .unexpected:
            return 0
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .api(code: _, message: let message, location: _):
            return message
        case .unexpected(message: let message, underlying: _):
            return message
        }
    }
    
    public var errorUserInfo: [String : Any] {
        switch self {
        case let .api(code: code, message: message, location: location):
            return [
                ErrorUserInfoKey.code.rawValue: code,
                ErrorUserInfoKey.location.rawValue: location,
                ErrorUserInfoKey.message.rawValue: message,
                NSLocalizedDescriptionKey: message,
            ]
        case let .unexpected(message: message, underlying: error?):
            return [
                NSLocalizedDescriptionKey: message,
                NSUnderlyingErrorKey: error,
            ]
        case let .unexpected(message: message, underlying: nil):
            return [
                NSLocalizedDescriptionKey: message,
            ]
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ErrorUserInfoKey.self)
        let code = try container.decode(String.self, forKey: .code)
        let message = try container.decode(String.self, forKey: .message)
        let location = try container.decode(String.self, forKey: .location)
        
        self = .api(code: code, message: message, location: location)
    }
}
