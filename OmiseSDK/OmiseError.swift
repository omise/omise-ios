import Foundation

public let OmiseErrorDomain = "co.omise"

public enum ErrorUserInfoKey: String, CodingKey {
    case location = "location"
    case code = "code"
    case message = "message"
}


/// Represent errors from the Omise iOS SDK.
public enum OmiseError: CustomNSError, LocalizedError, Decodable {
    public static let errorDomain: String = "co.omise.ios"
    
    /// API error returned from Omise API
    case api(code: String, message: String, location: String)
    /// Any unexpected errors that may happen during Omise API requests.
    case unexpected(error: UnexpectedError, underlying: Error?)
    
    public enum UnexpectedError {
        case noErrorNorResponse
        case httpErrorWithNoData
        case httpErrorResponseWithInvalidData
        case httpSucceessWithNoData
        case httpSucceessWithInvalidData
        case unrecognizedHTTPStatusCode(code: Int)
        case other(String)
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
        case .api(code: let errorCode, message: let message, location: _):
            switch errorCode {
            case "invalid_card":
                return NSLocalizedString(
                    "error.api.invalid_card.message",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Invalid card data",
                    comment: "A descriptive message representing an `Invalid card data` error from the backend"
                )
            case "bad_request":
                return NSLocalizedString(
                    "error.api.bad_request.message",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Bad request",
                    comment: "A descriptive message representing an `Bad request` error from the backend"
                )
            case "authentication_failure":
                return NSLocalizedString(
                    "error.api.authentication_failure.message",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Authentication failure",
                    comment: "A descriptive message representing an `Authentication failure` error from the backend"
                )
            case "service_not_found":
                return NSLocalizedString(
                    "error.api.service_not_found.message",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Service not found",
                    comment: "A descriptive message representing an `Service not found` error from the backend"
                )
            default:
                return message
            }
        case .unexpected(error: _, underlying: let underlyingError?):
            return underlyingError.localizedDescription
        case .unexpected(error: let error, underlying: nil):
            switch error {
            case .noErrorNorResponse:
                return NSLocalizedString(
                    "error.unexpected.no-error-norresponse.message",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "No error nor response",
                    comment: "A descriptive message representing an `No error nor response` error during the operation in the client"
                )
            case .httpErrorWithNoData:
                return NSLocalizedString(
                    "error.unexpected.http-error-with-no-data.message",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "No error data in the error response",
                    comment: "A descriptive message representing an `No error data in the error response` error during the operation in the client"
                )
            case .httpErrorResponseWithInvalidData:
                return NSLocalizedString(
                    "error.unexpected.http-error-response-with-invalid-data.message",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Invalid error data in the error response",
                    comment: "A descriptive message representing an `Invalid error data in the error response` error during the operation in the client"
                )
            case .httpSucceessWithNoData:
                return NSLocalizedString(
                    "error.unexpected.http-succeess-with-no-data.message",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "No data in the success response",
                    comment: "A descriptive message representing an `No data in the success response` error during the operation in the client"
                )
            case .httpSucceessWithInvalidData:
                return NSLocalizedString(
                    "error.unexpected.http-succeess-with-invalid-data.message",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Invalid data in the success response",
                    comment: "A descriptive message representing an `Invalid data in the success response` error during the operation in the client"
                )
            case .unrecognizedHTTPStatusCode(let statusCode):
                let messageFormat = NSLocalizedString(
                    "error.unexpected.unrecognized-HTTP-status-code.message",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Unrecognized/unsupported HTTP status code",
                    comment: "A descriptive message representing an `Unrecognized/unsupported HTTP status code` error during the operation in the client"
                )
                
                return String.localizedStringWithFormat(messageFormat, statusCode)
            case .other(let message):
                return message
            }
        }
    }
    
    public var recoverySuggestion: String? {
        let recoverySuggestionMessage: String
        switch self {
        case .api(code: let errorCode, message: let message, location: _):
            switch errorCode {
            case "invalid_card":
                recoverySuggestionMessage = NSLocalizedString(
                    "error.api.invalid_card.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Please review your credit card information",
                    comment: "A descriptive suggestion message to recovery from the `Invalid card data` error from the backend"
                )
            case "bad_request":
                recoverySuggestionMessage = NSLocalizedString(
                    "error.api.bad_request.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Please contact the merchant",
                    comment: "A descriptive suggestion message to recovery from the `Bad request` error from the backend"
                )
            case "authentication_failure":
                recoverySuggestionMessage = NSLocalizedString(
                    "error.api.authentication_failure.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Please contact the merchant",
                    comment: "A descriptive suggestion message to recovery from the `Authentication failure` error from the backend"
                )
            case "service_not_found":
                recoverySuggestionMessage = NSLocalizedString(
                    "error.api.service_not_found.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Please contact the merchant",
                    comment: "A descriptive suggestion message to recovery from the `Service not found` error from the backend"
                )
            default:
                recoverySuggestionMessage = message
            }
        case .unexpected(error: let error, underlying: _):
            switch error {
            case .noErrorNorResponse:
                recoverySuggestionMessage = NSLocalizedString(
                    "error.unexpected.no-error-norresponse.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "",
                    comment: "A descriptive suggestion message to recovery from the `No error nor response` error during the operation in the client"
                )
            case .httpErrorWithNoData:
                recoverySuggestionMessage = NSLocalizedString(
                    "error.unexpected.http-error-with-no-data.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "",
                    comment: "A descriptive suggestion message to recovery from the `No error data in the error response` error during the operation in the client"
                )
            case .httpErrorResponseWithInvalidData:
                recoverySuggestionMessage = NSLocalizedString(
                    "error.unexpected.http-error-response-with-invalid-data.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "",
                    comment: "A descriptive suggestion message to recovery from the `Invalid error data in the error response` error during the operation in the client"
                )
            case .httpSucceessWithNoData:
                recoverySuggestionMessage = NSLocalizedString(
                    "error.unexpected.http-succeess-with-no-data.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "",
                    comment: "A descriptive suggestion message to recovery from the `No data in the success response` error during the operation in the client"
                )
            case .httpSucceessWithInvalidData:
                recoverySuggestionMessage = NSLocalizedString(
                    "error.unexpected.http-succeess-with-invalid-data.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "",
                    comment: "A descriptive suggestion message to recovery from the `Invalid data in the success response` error during the operation in the client"
                )
            case .unrecognizedHTTPStatusCode:
                recoverySuggestionMessage = NSLocalizedString(
                    "error.unexpected.unrecognized-HTTP-status-code.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "",
                    comment: "A descriptive suggestion message to recovery from the `Unrecognized/unsupported HTTP status code` error during the operation in the client"
                )
            case .other:
                return nil
            }
        }
        return !recoverySuggestionMessage.isEmpty ? recoverySuggestionMessage : nil
    }
    
    public var errorUserInfo: [String : Any] {
        switch self {
        case let .api(code: code, message: message, location: location):
            return [
                ErrorUserInfoKey.code.rawValue: code,
                ErrorUserInfoKey.location.rawValue: location,
                ErrorUserInfoKey.message.rawValue: message,
                NSLocalizedDescriptionKey: errorDescription ?? "",
            ]
        case let .unexpected(error: _, underlying: error?):
            return [
                NSLocalizedDescriptionKey: error.localizedDescription,
                NSUnderlyingErrorKey: error,
            ]
        case .unexpected(error: _, underlying: nil):
            return [
                NSLocalizedDescriptionKey: errorDescription ?? "",
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

