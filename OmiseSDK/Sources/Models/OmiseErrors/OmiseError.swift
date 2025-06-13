import Foundation

let sourceParameterCodingsUserInfoKey = CodingUserInfoKey(rawValue: "sourceParameter")! // swiftlint:disable:this force_unwrapping

/// Coding Key for decoding the Error data returned in the Omise API
///
/// - location: URL location for the error information page
/// - code: Omise Error Code
/// - message: Error message
public enum ErrorUserInfoKey: String, CodingKey {
    case location
    case code
    case message
}

// MARK: -  OmiseError
/// Represent errors from the Omise iOS SDK.
public enum OmiseError: CustomNSError, LocalizedError, Decodable {
    /// API error returned from Omise API
    case api(code: APIErrorCode, message: String, location: String)
    /// Any unexpected errors that may happen during Omise API requests.
    case unexpected(error: UnexpectedError, underlying: Error?)
    
    /// The error code of the Omise API error
    ///
    /// - invalidCard: The card informaitn is invalid
    /// - badRequest: The request is invalid
    /// - authenticationFailure: The given authentication key is wrong
    /// - serviceNotFound: The requested service is not available for this account
    /// - other: Other error code
    public enum APIErrorCode {
        case invalidCard([InvalidCardReason])
        case badRequest([BadRequestReason])
        case authenticationFailure
        case serviceNotFound
        
        case other(String)
        
        /// The reason of the Invalid Card error
        ///
        /// - invalidCardNumber: The card number is invalid
        /// - invalidExpirationDate: The card expiration date is invalid
        /// - emptyCardHolderName: Card holder name is empty
        /// - unsupportedBrand: The card brand is not supported
        /// - other: Other invalid card reason
        public enum InvalidCardReason: Hashable {
            case invalidCardNumber
            case invalidExpirationDate
            case emptyCardHolderName
            case unsupportedBrand
            
            case other(String)
        }
        
        /// The reason of the Bad Request error
        ///
        /// - amountIsLessThanValidAmount: The given amount is less than the valid amount
        /// - amountIsGreaterThanValidAmount: The given amount is greater than the valid amount
        /// - invalidCurrency: The given currency is invalid
        /// - emptyName: The customer name is empty
        /// - nameIsTooLong: The customer name is too long
        /// - invalidName: The customer name is invalid
        /// - invalidEmail: The customer email is invalid
        /// - invalidPhoneNumber: The customer phone number is invalid
        /// - typeNotSupported: The given Source Type is not supported on this account
        /// - currencyNotSupported: The currency is not supported on this account
        /// - other: Other bad request reason
        public enum BadRequestReason: Hashable {
            case amountIsLessThanValidAmount(validAmount: Int64?, currency: Currency?)
            case amountIsGreaterThanValidAmount(validAmount: Int64?, currency: Currency?)
            
            case invalidCurrency
            
            case emptyName
            case nameIsTooLong(maximum: Int?)
            case invalidName
            case invalidEmail
            case invalidPhoneNumber
            
            case typeNotSupported
            case currencyNotSupported
            
            case other(String)
        }
    }
    
    /// The reason of an unexpected error
    ///
    /// - noErrorNorResponse: API returns without both error nor response
    /// - httpErrorWithNoData: API returns with HTTP error code but there is no response data
    /// - httpErrorResponseWithInvalidData: API returns with HTTP error code but the returned data is invalid
    /// - httpSucceessWithNoData: API returns with HTTP success code but there is no response data
    /// - httpSucceessWithInvalidData: API returns with HTTP success code but the returned data is invalid
    /// - unrecognizedHTTPStatusCode: API returnes with unrecognized HTTP status code
    /// - other: Other expected error reason
    public enum UnexpectedError {
        case noErrorNorResponse
        case httpErrorWithNoData
        case httpErrorResponseWithInvalidData
        case httpSuccessWithNoData
        case httpSuccessWithInvalidData
        case unrecognizedHTTPStatusCode(code: Int)
        case other(String)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ErrorUserInfoKey.self)
        let message = try container.decode(String.self, forKey: .message)
        let location = try container.decode(String.self, forKey: .location)
        
        self = .api(code: try OmiseError.APIErrorCode(from: decoder), message: message, location: location)
    }
    
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch self {
        case .api(code: let errorCode, message: let message, location: _):
            return getAPIErrorDescription(errorCode, messageFromAPI: message)
        case .unexpected(error: _, underlying: let underlyingError?):
            return underlyingError.localizedDescription
        case .unexpected(error: let error, underlying: nil):
            return getUnexpectedErrorDescription(error)
        }
    }
    
    /// A localized message describing how one might recover from the failure.
    public var recoverySuggestion: String? {
        let recoverySuggestionMessage: String?
        switch self {
        case .api(code: let errorCode, message: _, location: _):
            recoverySuggestionMessage = getAPIErrorRecoverySuggestion(errorCode)
        case .unexpected(error: let error, underlying: _):
            recoverySuggestionMessage = getUnexpectedErrorRecoverySuggestion(error)
        }
        return recoverySuggestionMessage.isNilOrEmpty ? nil : recoverySuggestionMessage
    }
    
    /// Storage for values or objects related to this notification.
    public var errorUserInfo: [String: Any] {
        switch self {
        case let .api(code: code, message: message, location: location):
            return [
                ErrorUserInfoKey.code.rawValue: code,
                ErrorUserInfoKey.location.rawValue: location,
                ErrorUserInfoKey.message.rawValue: message,
                NSLocalizedDescriptionKey: errorDescription ?? "",
                NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion ?? ""
            ]
        case let .unexpected(error: _, underlying: error?):
            return [
                NSLocalizedDescriptionKey: error.localizedDescription,
                NSUnderlyingErrorKey: error
            ]
        case .unexpected(error: _, underlying: nil):
            return [
                NSLocalizedDescriptionKey: errorDescription ?? ""
            ]
        }
    }
}


// MARK: -  APIErrorCode
private extension OmiseError {
    func getAPIErrorDescription(_ code: APIErrorCode, messageFromAPI: String) -> String? {
        switch code {
        case .invalidCard(let invalidCardReasons):
            return invalidCardReasons.first?.defaultLocalizedErrorDescription
        case .badRequest(let badRequestReasons):
            return badRequestReasons.first?.defaultLocalizedErrorDescription
        case .authenticationFailure:
            return getLocalizedError(
                "error.api.authentication_failure.message",
                defaultValue: "Authentication failure",
                comment: "A default descriptive message representing an `Authentication failure` error from the backend which a merchant may show this message to their user"
            )
        case .serviceNotFound:
            return getLocalizedError(
                "error.api.service_not_found.message",
                defaultValue: "Service not found",
                comment: "A default descriptive message representing an `Service not found` error from the backend which a merchant may show this message to their user"
            )
        case .other:
            return messageFromAPI
        }
    }
    
    func getAPIErrorRecoverySuggestion(_ code: APIErrorCode) -> String? {
        switch code {
        case .invalidCard(let invalidCardReasons):
            invalidCardReasons.first?.defaultRecoverySuggestionMessage
        case .badRequest(let badRequestReasons):
            badRequestReasons.first?.defaultRecoverySuggestionMessage
        case .authenticationFailure:
            getLocalizedError(
                "error.api.authentication_failure.recovery-suggestion",
                defaultValue: "Please contact the merchant",
                comment: "A default descriptive suggestion message to recovery from the `Authentication failure` error from the backend which a merchant may show this message to their user"
            )
        case .serviceNotFound:
            getLocalizedError(
                "error.api.service_not_found.recovery-suggestion",
                defaultValue: "Please contact the merchant",
                comment: "A default descriptive suggestion message to recovery from the `Service not found` error from the backend which a merchant may show this message to their user"
            )
        default:
            ""
        }
    }
}

// MARK: -  Unexpected Error
private extension OmiseError {
    func getUnexpectedErrorDescription(_ error: UnexpectedError) -> String {
        switch error {
        case .noErrorNorResponse:
            return getLocalizedError(
                "error.unexpected.no-error-norresponse.message",
                defaultValue: "No error nor response",
                comment: "A descriptive message representing an `No error nor response` error during the operation in the client"
            )
        case .httpErrorWithNoData:
            return getLocalizedError(
                "error.unexpected.http-error-with-no-data.message",
                defaultValue: "No error data in the error response",
                comment: "A descriptive message representing an `No error data in the error response` error during the operation in the client"
            )
        case .httpErrorResponseWithInvalidData:
            return getLocalizedError(
                "error.unexpected.http-error-response-with-invalid-data.message",
                defaultValue: "Invalid error data in the error response",
                comment: "A descriptive message representing an `Invalid error data in the error response` error during the operation in the client"
            )
        case .httpSuccessWithNoData:
            return getLocalizedError(
                "error.unexpected.http-succeess-with-no-data.message",
                defaultValue: "No data in the success response",
                comment: "A descriptive message representing an `No data in the success response` error during the operation in the client"
            )
        case .httpSuccessWithInvalidData:
            return getLocalizedError(
                "error.unexpected.http-succeess-with-invalid-data.message",
                defaultValue: "Invalid data in the success response",
                comment: "A descriptive message representing an `Invalid data in the success response` error during the operation in the client"
            )
        case .unrecognizedHTTPStatusCode(let statusCode):
            let messageFormat = getLocalizedError(
                "error.unexpected.unrecognized-HTTP-status-code.message",
                defaultValue: "Unrecognized/unsupported HTTP status code",
                comment: "A descriptive message representing an `Unrecognized/unsupported HTTP status code` error during the operation in the client"
            )
            return String.localizedStringWithFormat(messageFormat, statusCode)
        case .other(let message):
            return message
        }
    }
    
    func getUnexpectedErrorRecoverySuggestion(_ error: UnexpectedError) -> String? {
        enum CommonStrings: String {
            case tryAgainLater = "Please try again later. If the same problem persists please contact customer support."
        }
        
        switch error {
        case .noErrorNorResponse:
            return getLocalizedError(
                "error.unexpected.no-error-norresponse.recovery-suggestion",
                defaultValue: CommonStrings.tryAgainLater.rawValue,
                comment: "A default descriptive suggestion message to recovery from the `No error nor response` error during the operation in the client which a merchant may show this message to their user"
            )
        case .httpErrorWithNoData:
            return getLocalizedError(
                "error.unexpected.http-error-with-no-data.recovery-suggestion",
                defaultValue: CommonStrings.tryAgainLater.rawValue,
                comment: "A default descriptive suggestion message to recovery from the `No error data in the error response` error during the operation in the client which a merchant may show this message to their user"
            )
        case .httpErrorResponseWithInvalidData:
            return getLocalizedError(
                "error.unexpected.http-error-response-with-invalid-data.recovery-suggestion",
                defaultValue: CommonStrings.tryAgainLater.rawValue,
                comment: "A default descriptive suggestion message to recovery from the `Invalid error data in the error response` error during the operation in the client which a merchant may show this message to their user"
            )
        case .httpSuccessWithNoData:
            return getLocalizedError(
                "error.unexpected.http-succeess-with-no-data.recovery-suggestion",
                defaultValue: CommonStrings.tryAgainLater.rawValue,
                comment: "A default descriptive suggestion message to recovery from the `No data in the success response` error during the operation in the client which a merchant may show this message to their user"
            )
        case .httpSuccessWithInvalidData:
            return getLocalizedError(
                "error.unexpected.http-succeess-with-invalid-data.recovery-suggestion",
                defaultValue: CommonStrings.tryAgainLater.rawValue,
                comment: "A default descriptive suggestion message to recovery from the `Invalid data in the success response` error during the operation in the client which a merchant may show this message to their user"
            )
        case .unrecognizedHTTPStatusCode:
            return getLocalizedError(
                "error.unexpected.unrecognized-HTTP-status-code.recovery-suggestion",
                defaultValue: CommonStrings.tryAgainLater.rawValue,
                comment: "A default descriptive suggestion message to recovery from the `Unrecognized/unsupported HTTP status code` error during the operation in the client which a merchant may show this message to their user"
            )
        case .other:
            return nil
        }
    }
}
