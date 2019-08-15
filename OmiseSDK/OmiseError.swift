import Foundation


/// Default error domain for the Omise Error
public let OmiseErrorDomain = "co.omise"

let sourceParameterCodingsUserInfoKey = CodingUserInfoKey.init(rawValue: "sourceParameter")!

/// Coding Key for decoding the Error data returned in the Omise API
///
/// - location: URL location for the error information page
/// - code: Omise Error Code
/// - message: Error message
public enum ErrorUserInfoKey: String, CodingKey {
    case location = "location"
    case code = "code"
    case message = "message"
}


/// Represent errors from the Omise iOS SDK.
public enum OmiseError: CustomNSError, LocalizedError, Decodable {
    public static let errorDomain: String = "co.omise.ios"
    
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
        public enum InvalidCardReason : Hashable {
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
        public enum BadRequestReason : Hashable {
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
        case httpSucceessWithNoData
        case httpSucceessWithInvalidData
        case unrecognizedHTTPStatusCode(code: Int)
        case other(String)
    }
    
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch self {
        case .api(code: let errorCode, message: let message, location: _):
            switch errorCode {
            case .invalidCard(let invalidCardReasons):
                return invalidCardReasons.first?.defaultLocalizedErrorDescription
            case .badRequest(let badRequestReasons):
                return badRequestReasons.first?.defaultLocalizedErrorDescription
            case .authenticationFailure:
                return NSLocalizedString(
                    "error.api.authentication_failure.message",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Authentication failure",
                    comment: "A default descriptive message representing an `Authentication failure` error from the backend which a merchant may show this message to their user"
                )
            case .serviceNotFound:
                return NSLocalizedString(
                    "error.api.service_not_found.message",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Service not found",
                    comment: "A default descriptive message representing an `Service not found` error from the backend which a merchant may show this message to their user"
                )
            case .other:
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
    
    /// A localized message describing how one might recover from the failure.
    public var recoverySuggestion: String? {
        let recoverySuggestionMessage: String?
        switch self {
        case .api(code: let errorCode, message: _, location: _):
            switch errorCode {
            case .invalidCard(let invalidCardReasons):
                recoverySuggestionMessage = invalidCardReasons.first?.defaultRecoverySuggestionMessage
            case .badRequest(let badRequestReasons):
                recoverySuggestionMessage = badRequestReasons.first?.defaultRecoverySuggestionMessage
            case .authenticationFailure:
                recoverySuggestionMessage = NSLocalizedString(
                    "error.api.authentication_failure.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Please contact the merchant",
                    comment: "A default descriptive suggestion message to recovery from the `Authentication failure` error from the backend which a merchant may show this message to their user"
                )
            case .serviceNotFound:
                recoverySuggestionMessage = NSLocalizedString(
                    "error.api.service_not_found.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Please contact the merchant",
                    comment: "A default descriptive suggestion message to recovery from the `Service not found` error from the backend which a merchant may show this message to their user"
                )
            default:
                recoverySuggestionMessage = ""
            }
        case .unexpected(error: let error, underlying: _):
            switch error {
            case .noErrorNorResponse:
                recoverySuggestionMessage = NSLocalizedString(
                    "error.unexpected.no-error-norresponse.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Please try again later. If the same problem persists please contact customer support.",
                    comment: "A default descriptive suggestion message to recovery from the `No error nor response` error during the operation in the client which a merchant may show this message to their user"
                )
            case .httpErrorWithNoData:
                recoverySuggestionMessage = NSLocalizedString(
                    "error.unexpected.http-error-with-no-data.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Please try again later. If the same problem persists please contact customer support.",
                    comment: "A default descriptive suggestion message to recovery from the `No error data in the error response` error during the operation in the client which a merchant may show this message to their user"
                )
            case .httpErrorResponseWithInvalidData:
                recoverySuggestionMessage = NSLocalizedString(
                    "error.unexpected.http-error-response-with-invalid-data.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Please try again later. If the same problem persists please contact customer support.",
                    comment: "A default descriptive suggestion message to recovery from the `Invalid error data in the error response` error during the operation in the client which a merchant may show this message to their user"
                )
            case .httpSucceessWithNoData:
                recoverySuggestionMessage = NSLocalizedString(
                    "error.unexpected.http-succeess-with-no-data.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Please try again later. If the same problem persists please contact customer support.",
                    comment: "A default descriptive suggestion message to recovery from the `No data in the success response` error during the operation in the client which a merchant may show this message to their user"
                )
            case .httpSucceessWithInvalidData:
                recoverySuggestionMessage = NSLocalizedString(
                    "error.unexpected.http-succeess-with-invalid-data.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Please try again later. If the same problem persists please contact customer support.",
                    comment: "A default descriptive suggestion message to recovery from the `Invalid data in the success response` error during the operation in the client which a merchant may show this message to their user"
                )
            case .unrecognizedHTTPStatusCode:
                recoverySuggestionMessage = NSLocalizedString(
                    "error.unexpected.unrecognized-HTTP-status-code.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Please try again later. If the same problem persists please contact customer support.",
                    comment: "A default descriptive suggestion message to recovery from the `Unrecognized/unsupported HTTP status code` error during the operation in the client which a merchant may show this message to their user"
                )
            case .other:
                return nil
            }
        }
        return recoverySuggestionMessage.isNilOrEmpty ? nil : recoverySuggestionMessage
    }
    
    /// Storage for values or objects related to this notification.
    public var errorUserInfo: [String : Any] {
        switch self {
        case let .api(code: code, message: message, location: location):
            return [
                ErrorUserInfoKey.code.rawValue: code,
                ErrorUserInfoKey.location.rawValue: location,
                ErrorUserInfoKey.message.rawValue: message,
                NSLocalizedDescriptionKey: errorDescription ?? "",
                NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion ?? "",
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
        let message = try container.decode(String.self, forKey: .message)
        let location = try container.decode(String.self, forKey: .location)
        
        self = .api(code: try OmiseError.APIErrorCode.init(from: decoder), message: message, location: location)
    }
}

extension OmiseError.APIErrorCode : Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ErrorUserInfoKey.self)
        let codeValue = try container.decode(String.self, forKey: .code)
        let message = try container.decode(String.self, forKey: .message)
        
        switch codeValue {
        case "invalid_card":
            self = .invalidCard(try OmiseError.APIErrorCode.InvalidCardReason.parseInvalidCardReasonsFromMessage(message))
        case "bad_request":
            let sourceParameter = decoder.userInfo[sourceParameterCodingsUserInfoKey] as? CreateSourceParameter
            self = .badRequest(try OmiseError.APIErrorCode.BadRequestReason.parseBadRequestReasonsFromMessage(message, currency: sourceParameter?.currency))
        case "authentication_failure":
            self = .authenticationFailure
        case "service_not_found":
            self = .serviceNotFound
        default:
            self = .other(codeValue)
        }
    }
}

extension OmiseError.APIErrorCode.InvalidCardReason : Decodable {
    
    init(message: String) throws {
        if message.contains("number") {
            self = .invalidCardNumber
        } else if message.contains("expiration") {
            self = .invalidExpirationDate
        } else if message.contains("name") {
            self = .emptyCardHolderName
        } else if message.contains("brand") {
            self = .unsupportedBrand
        } else {
            self = .other(message)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        try self.init(message: try container.decode(String.self))
    }
    
    var defaultLocalizedErrorDescription: String? {
        let preferredErrorDescription: String
        switch self {
        case .invalidCardNumber:
            preferredErrorDescription = NSLocalizedString(
                "error.api.invalid_card.invalid-card-number.message",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "Invalid card number",
                comment: "A default descriptive message representing an `Invalid card data` error with the `Invalid card number` message from the backend which a merchant may show this message to their user"
            )
        case .invalidExpirationDate:
            preferredErrorDescription = NSLocalizedString(
                "error.api.invalid_card.invalid-expiration-date.message",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "Invalid card expiration date",
                comment: "A default descriptive message representing an `Invalid card data` error with the `Invalid card expiration date` message from the backend which a merchant may show this message to their user"
            )
        case .emptyCardHolderName:
            preferredErrorDescription = NSLocalizedString(
                "error.api.invalid_card.empty-card-holderName.message",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "Invalid card holder name",
                comment: "A default descriptive message representing an `Invalid card data` error with the `Invalid card holder name` message from the backend which a merchant may show this message to their user"
            )
        case .unsupportedBrand:
            preferredErrorDescription = NSLocalizedString(
                "error.api.invalid_card.unsupported-brand.message",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "Unsupported card brand",
                comment: "A default descriptive message representing an `Invalid card data` error with the `Unsupported card brand` message from the backend which a merchant may show this message to their user"
            )
        case .other(let value):
            preferredErrorDescription = value
        }
        
        return preferredErrorDescription.isEmpty ? nil : preferredErrorDescription
    }
    
    var defaultRecoverySuggestionMessage: String? {
        let preferredRecoverySuggestionMessage: String
        switch self {
        case .invalidCardNumber:
            preferredRecoverySuggestionMessage = NSLocalizedString(
                "error.api.invalid_card.invalid-card-number.recovery-suggestion",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "Please review the card number",
                comment: "A default descriptive suggestion message to recovery from the `Invalid card data` error with the `Invalid card number` message from the backend which a merchant may show this message to their user"
            )
        case .invalidExpirationDate:
            preferredRecoverySuggestionMessage = NSLocalizedString(
                "error.api.invalid_card.invalid-expiration-date.recovery-suggestion",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "Please review the card expiration date",
                comment: "A default descriptive suggestion message to recovery from the `Invalid card data` error with the `Invalid card expiration date` message from the backend which a merchant may show this message to their user"
            )
        case .emptyCardHolderName:
            preferredRecoverySuggestionMessage = NSLocalizedString(
                "error.api.invalid_card.empty-card-holder-name.recovery-suggestion",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "Please review the card holder name",
                comment: "A default descriptive suggestion message to recovery from the `Invalid card data` error with the `Invalid card holder name` message from the backend which a merchant may show this message to their user"
            )
        case .unsupportedBrand:
            preferredRecoverySuggestionMessage = NSLocalizedString(
                "error.api.invalid_card.unsupported-brand.recovery-suggestion",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "Please use another credit card",
                comment: "A default descriptive suggestion message to recovery from the `Invalid card data` error with the `Unsupported card brand` message from the backend which a merchant may show this message to their user"
            )
        case .other:
            preferredRecoverySuggestionMessage = NSLocalizedString(
                "error.api.invalid_card.other.recovery-suggestion",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "Please review credit card information",
                comment: "A descriptive suggestion message to recovery from the `Invalid card data` error from the backend which a merchant may show this message to their user"
            )
        }
        
        return preferredRecoverySuggestionMessage.isEmpty ? nil : preferredRecoverySuggestionMessage
    }
    
    static func parseInvalidCardReasonsFromMessage(_ message: String) throws -> [OmiseError.APIErrorCode.InvalidCardReason] {
        let reasonMessages = message.components(separatedBy: ", and ").flatMap({ $0.components(separatedBy: ", ") })
        var parsedReasons = Set(try reasonMessages.map(OmiseError.APIErrorCode.InvalidCardReason.init(message:)))
        
        if parsedReasons.contains(.invalidCardNumber) {
            parsedReasons.remove(.unsupportedBrand)
        }
        return parsedReasons.sorted(by: {
            switch ($0, $1) {
            case (.invalidCardNumber, _):
                return true
            case (.invalidExpirationDate, .emptyCardHolderName):
                return true
            case (.invalidExpirationDate, .unsupportedBrand):
                return true
            case (.emptyCardHolderName, .unsupportedBrand):
                return true
            case (_, .other):
                return true
                
            default: return false
            }
        })
    }
}


let amountAtLeastValidAmountErrorMessageRegularExpression = try! NSRegularExpression(pattern: "amount must be at least ([\\d]+)", options: [])
let amountGreaterThanValidAmountErrorMessageRegularExpression = try! NSRegularExpression(pattern: "amount must be less than ([\\d]+)", options: [])
let amountLessThanValidAmountErrorMessageRegularExpression = try! NSRegularExpression(pattern: "amount must be greater than ([\\d]+)", options: [])

let nameIsTooLongErrorMessageRegularExpression = try! NSRegularExpression(pattern: "name is too long \\(maximum is ([\\d]+) characters\\)", options: [])


extension OmiseError.APIErrorCode.BadRequestReason : Decodable {
    
    init(message: String, currency: Currency?) throws {
        if message.hasPrefix("amount must be ") {
            if let lessThanValidAmountMatch = amountLessThanValidAmountErrorMessageRegularExpression
                .firstMatch(in: message, range: NSRange(message.startIndex..<message.endIndex, in: message)),
                lessThanValidAmountMatch.numberOfRanges == 2,
                let amountRange = Range.init(lessThanValidAmountMatch.range(at: 1), in: message) {
                self = .amountIsLessThanValidAmount(validAmount: Int64(message[amountRange]), currency: currency)
            } else if let greaterThanValidAmountMatch = amountGreaterThanValidAmountErrorMessageRegularExpression
                .firstMatch(in: message, range: NSRange(message.startIndex..<message.endIndex, in: message)),
                greaterThanValidAmountMatch.numberOfRanges == 2,
                let amountRange = Range.init(greaterThanValidAmountMatch.range(at: 1), in: message) {
                self = .amountIsGreaterThanValidAmount(validAmount: Int64(message[amountRange]), currency: currency)
            } else if let atLeastValidAmountMatch = amountAtLeastValidAmountErrorMessageRegularExpression
                .firstMatch(in: message, range: NSRange(message.startIndex..<message.endIndex, in: message)),
                atLeastValidAmountMatch.numberOfRanges == 2,
                let amountRange = Range.init(atLeastValidAmountMatch.range(at: 1), in: message) {
                self = .amountIsLessThanValidAmount(validAmount: Int64(message[amountRange]), currency: currency)
            } else {
                self = .other(message)
            }
        } else if message.contains("currency must be") {
            self = .invalidCurrency
        } else if message.contains("type") {
            self = .typeNotSupported
        } else if message.contains("currency") {
            self = .currencyNotSupported
        } else if message.contains("name") && message.contains("blank") {
            self = .emptyName
        } else if message.hasPrefix("name is too long"),
            let lessThanValidAmountMatch = nameIsTooLongErrorMessageRegularExpression
                .firstMatch(in: message, range: NSRange(message.startIndex..<message.endIndex, in: message)),
            lessThanValidAmountMatch.numberOfRanges == 2,
            let amountRange = Range.init(lessThanValidAmountMatch.range(at: 1), in: message) {
            self = .nameIsTooLong(maximum: Int(message[amountRange]))
        } else if message.contains("name") {
            self = .nameIsTooLong(maximum: nil)
        } else if message.contains("email") {
            self = .invalidEmail
        } else if message.contains("phone") {
            self = .invalidPhoneNumber
        } else {
            self = .other(message)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        let sourceParameter = decoder.userInfo[sourceParameterCodingsUserInfoKey] as? CreateSourceParameter
        
        try self.init(message: try container.decode(String.self), currency: sourceParameter?.currency)
    }
    
    var defaultLocalizedErrorDescription: String? {
        let preferredErrorDescription: String
        switch self {
        case .amountIsLessThanValidAmount(validAmount: let validAmount, currency: let currency):
            if let validAmount = validAmount, let currency = currency {
                let preferredErrorDescriptionFormat = NSLocalizedString(
                    "error.api.bad_request.amount-is-less-than-valid-amount.with-valid-amount.message",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Amount is less than the valid amount of %@",
                    comment: "A default descriptive message representing an `Bad request` error with `amount-is-less-than-valid-amount.with-valid-amount` from the backend which a merchant may show this message to their user"
                )
                let formatter = NumberFormatter.makeAmountFormatter(for: currency)
                preferredErrorDescription = String.localizedStringWithFormat(
                    preferredErrorDescriptionFormat, 
                    formatter.string(from: NSNumber(value: currency.convert(fromSubunit: validAmount))) ?? "\(currency.convert(fromSubunit: validAmount))")
            } else {
                preferredErrorDescription = NSLocalizedString(
                    "error.api.bad_request.amount-is-less-than-valid-amount.without-valid-amount.message",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Amount is less than the valid amount",
                    comment: "A default descriptive message representing an `Bad request` error with `amount-is-less-than-valid-amount.without-valid-amount` from the backend which a merchant may show this message to their user"
                )
            }
        case .amountIsGreaterThanValidAmount(validAmount: let validAmount, currency: let currency):
            if let validAmount = validAmount, let currency = currency {
                let preferredErrorDescriptionFormat = NSLocalizedString(
                    "error.api.bad_request.amount-is-greater-than-valid-amount.with-valid-amount.message",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Amount exceeds the valid amount of %@",
                    comment: "A default descriptive message representing an `Bad request` error with `amount-is-greater-than-valid-amount.with-valid-amount` from the backend which a merchant may show this message to their user"
                )
                let formatter = NumberFormatter.makeAmountFormatter(for: currency)
                preferredErrorDescription = String.localizedStringWithFormat(
                    preferredErrorDescriptionFormat,
                    formatter.string(from: NSNumber(value: currency.convert(fromSubunit: validAmount))) ?? "\(currency.convert(fromSubunit: validAmount))")
            } else {
                preferredErrorDescription = NSLocalizedString(
                    "error.api.bad_request.amount-is-greater-than-valid-amount.without-valid-amount.message",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Amount exceeds the valid amount",
                    comment: "A default descriptive message representing an `Bad request` error with `amount-is-greater-than-valid-amount.without-valid-amount` from the backend which a merchant may show this message to their user"
                )
            }
        case .invalidCurrency:
            preferredErrorDescription = NSLocalizedString(
                "error.api.bad_request.invalid-currency.message",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "The currency is invalid",
                comment: "A default descriptive message representing an `Bad request` error with `invalid-currency` from the backend which a merchant may show this message to their user"
            )
            
        case .emptyName:
            preferredErrorDescription = NSLocalizedString(
                "error.api.bad_request.empty-name.message",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "The customer name is empty",
                comment: "A default descriptive message representing an `Bad request` error with `empty-name` from the backend which a merchant may show this message to their user"
            )
            
        case .nameIsTooLong(maximum: let maximumLength):
            if let maximumLength = maximumLength {
                let preferredErrorDescriptionFormat = NSLocalizedString(
                    "error.api.bad_request.name-is-too-long.with-valid-length.message",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "The customer name exceeds the %d character limit",
                    comment: "A default descriptive message representing an `Bad request` error with `name-is-too-long.with-valid-length` from the backend which a merchant may show this message to their user"
                )
                preferredErrorDescription = String.localizedStringWithFormat(preferredErrorDescriptionFormat, maximumLength)
            } else {
                preferredErrorDescription = NSLocalizedString(
                    "error.api.bad_request.name-is-too-long.without-valid-length.message",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "The customer name is too long",
                    comment: "A default descriptive message representing an `Bad request` error with `name-is-too-long.without-valid-length` from the backend which a merchant may show this message to their user"
                )
            }
        case .invalidName:
            preferredErrorDescription = NSLocalizedString(
                "error.api.bad_request.invalid-name.message",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "The customer name is invalid",
                comment: "A default descriptive message representing an `Bad request` error with `invalid-name` from the backend which a merchant may show this message to their user"
            )
        case .invalidEmail:
            preferredErrorDescription = NSLocalizedString(
                "error.api.bad_request.invalid-email.message",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "The customer email is invalid",
                comment: "A default descriptive message representing an `Bad request` error with `invalid-email` from the backend which a merchant may show this message to their user"
            )
            
        case .invalidPhoneNumber:
            preferredErrorDescription = NSLocalizedString(
                "error.api.bad_request.invalid-phone-number.message",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "The customer phone number is invalid",
                comment: "A default descriptive message representing an `Bad request` error with `invalid-phone-number` from the backend which a merchant may show this message to their user"
            )
            
        case .typeNotSupported:
            preferredErrorDescription = NSLocalizedString(
                "error.api.bad_request.type-not-supported.message",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "The source type is not supported by this account",
                comment: "A default descriptive message representing an `Bad request` error with `type-not-supported` from the backend which a merchant may show this message to their user"
            )
            
        case .currencyNotSupported:
            preferredErrorDescription = NSLocalizedString(
                "error.api.bad_request.currency-not-supported.message",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "The currency is not supported by this account",
                comment: "A default descriptive message representing an `Bad request` error with `currency-not-supported` from the backend which a merchant may show this message to their user"
            )
        case .other(let value):
            let preferredErrorDescriptionFormat = NSLocalizedString(
                "error.api.bad_request.other.message",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "Bad request: %@",
                comment: "A default descriptive message representing an `Bad request` error with `other` from the backend which a merchant may show this message to their user"
            )
            preferredErrorDescription = String.localizedStringWithFormat(preferredErrorDescriptionFormat, value)
        }
        
        return preferredErrorDescription.isEmpty ? nil : preferredErrorDescription
    }
    
    var defaultRecoverySuggestionMessage: String? {
        let preferredRecoverySuggestionMessage: String
        switch self {
        case .amountIsLessThanValidAmount(validAmount: let validAmount, currency: let currency):
            if let validAmount = validAmount, let currency = currency {
                let preferredRecoverySuggestionMessageFormat = NSLocalizedString(
                    "error.api.bad_request.amount-is-less-than-valid-amount.with-valid-amount.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Please create a source with an amount that is greater than %@",
                    comment: "A default descriptive message representing an `Bad request` error with `amount-is-less-than-valid-amount.with-valid-amount` from the backend which a merchant may show this message to their user"
                )
                let formatter = NumberFormatter.makeAmountFormatter(for: currency)
                preferredRecoverySuggestionMessage = String.localizedStringWithFormat(preferredRecoverySuggestionMessageFormat, formatter.string(from: NSNumber(value: validAmount)) ?? "\(validAmount)")
            } else {
                preferredRecoverySuggestionMessage = NSLocalizedString(
                    "error.api.bad_request.amount-is-less-than-valid-amount.without-valid-amount.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Please create a source with a greater amount",
                    comment: "A default descriptive message representing an `Bad request` error with `amount-is-less-than-valid-amount.without-valid-amount` from the backend which a merchant may show this message to their user"
                )
            }
        case .amountIsGreaterThanValidAmount(validAmount: let validAmount, currency: let currency):
            if let validAmount = validAmount, let currency = currency {
                let preferredRecoverySuggestionMessageFormat = NSLocalizedString(
                    "error.api.bad_request.amount-is-greater-than-valid-amount.with-valid-amount.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Please create a source with an amount which is less than %@",
                    comment: "A default descriptive message representing an `Bad request` error with `amount-is-greater-than-valid-amount.with-valid-amount` from the backend which a merchant may show this message to their user"
                )
                let formatter = NumberFormatter.makeAmountFormatter(for: currency)
                preferredRecoverySuggestionMessage = String.localizedStringWithFormat(preferredRecoverySuggestionMessageFormat, formatter.string(from: NSNumber(value: validAmount)) ?? "\(validAmount)")
            } else {
                preferredRecoverySuggestionMessage = NSLocalizedString(
                    "error.api.bad_request.amount-is-greater-than-valid-amount.without-valid-amount.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Please create a source with less amount",
                    comment: "A default descriptive message representing an `Bad request` error with `amount-is-greater-than-valid-amount.without-valid-amount` from the backend which a merchant may show this message to their user"
                )
            }
        case .invalidCurrency:
            preferredRecoverySuggestionMessage = NSLocalizedString(
                "error.api.bad_request.invalid-currency.recovery-suggestion",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "Bad request",
                comment: "A default descriptive message representing an `Bad request` error with `invalid-currency` from the backend which a merchant may show this message to their user"
            )
            
        case .emptyName:
            preferredRecoverySuggestionMessage = NSLocalizedString(
                "error.api.bad_request.empty-name.recovery-suggestion",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "Please input customer name",
                comment: "A default descriptive message representing an `Bad request` error with `empty-name` from the backend which a merchant may show this message to their user"
            )
        case .nameIsTooLong(maximum: let maximumLength):
            if let maximumLength = maximumLength {
                let preferredRecoverySuggestionMessageFormat = NSLocalizedString(
                    "error.api.bad_request.name-is-too-long.with-valid-length.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Please input customer name which is no longer than %d characters",
                    comment: "A default descriptive message representing an `Bad request` error with `name-is-too-long.with-valid-length` from the backend which a merchant may show this message to their user"
                )
                preferredRecoverySuggestionMessage = String.localizedStringWithFormat(preferredRecoverySuggestionMessageFormat, maximumLength)
            } else {
                preferredRecoverySuggestionMessage = NSLocalizedString(
                    "error.api.bad_request.name-is-too-long.without-valid-length.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Please input shorter customer name",
                    comment: "A default descriptive message representing an `Bad request` error with `name-is-too-long.without-valid-length` from the backend which a merchant may show this message to their user"
                )
            }
        case .invalidName:
            preferredRecoverySuggestionMessage = NSLocalizedString(
                "error.api.bad_request.invalid-name.recovery-suggestion",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "Please review the customer name",
                comment: "A default descriptive message representing an `Bad request` error with `invalid-name` from the backend which a merchant may show this message to their user"
            )
        case .invalidEmail:
            preferredRecoverySuggestionMessage = NSLocalizedString(
                "error.api.bad_request.invalid-email.recovery-suggestion",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "Please review the customer email",
                comment: "A default descriptive message representing an `Bad request` error with `invalid-email` from the backend which a merchant may show this message to their user"
            )
        case .invalidPhoneNumber:
            preferredRecoverySuggestionMessage = NSLocalizedString(
                "error.api.bad_request.invalid-phone-number.recovery-suggestion",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "Please review the customer phone number",
                comment: "A default descriptive message representing an `Bad request` error with `invalid-phone-number` from the backend which a merchant may show this message to their user"
            )
        case .typeNotSupported:
            preferredRecoverySuggestionMessage = NSLocalizedString(
                "error.api.bad_request.type-not-supported.recovery-suggestion",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "Please review the source type",
                comment: "A default descriptive message representing an `Bad request` error with `type-not-supported` from the backend which a merchant may show this message to their user"
            )
        case .currencyNotSupported:
            preferredRecoverySuggestionMessage = NSLocalizedString(
                "error.api.bad_request.currency-not-supported.recovery-suggestion",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "Please choose another currency",
                comment: "A default descriptive message representing an `Bad request` error with `currency-not-supported` from the backend which a merchant may show this message to their user"
            )
        case .other(let value):
            preferredRecoverySuggestionMessage = value
        }
        
        return preferredRecoverySuggestionMessage.isEmpty ? nil : preferredRecoverySuggestionMessage
    }
    
    static func parseBadRequestReasonsFromMessage(_ message: String, currency: Currency?) throws -> [OmiseError.APIErrorCode.BadRequestReason] {
        let reasonMessages = message.components(separatedBy: ", and ").flatMap({ $0.components(separatedBy: ", ") }).flatMap({ $0.components(separatedBy: " and ") })
        let parsedReasons = Set(try reasonMessages.map({
            try OmiseError.APIErrorCode.BadRequestReason(message: $0, currency: currency)
        }))
        
        return parsedReasons.sorted(by: {
            switch $0 {
            case .amountIsLessThanValidAmount:
                return true
            case .other:
                return false
                
            case .amountIsGreaterThanValidAmount:
                switch $1 {
                case .amountIsGreaterThanValidAmount, .invalidCurrency, .emptyName, .nameIsTooLong, .invalidName,
                     .invalidEmail, .invalidPhoneNumber, .typeNotSupported, .currencyNotSupported:
                    return true
                case .amountIsLessThanValidAmount, .other:
                    return false
                }
            case .invalidCurrency:
                switch $1 {
                case .invalidCurrency, .emptyName, .nameIsTooLong, .invalidName, .invalidEmail,
                     .invalidPhoneNumber, .typeNotSupported, .currencyNotSupported:
                    return true
                case .amountIsLessThanValidAmount, .amountIsGreaterThanValidAmount, .other:
                    return false
                }
            case .emptyName:
                switch $1 {
                case .emptyName, .nameIsTooLong, .invalidName, .invalidEmail, .invalidPhoneNumber,
                     .typeNotSupported, .currencyNotSupported:
                    return true
                case .amountIsLessThanValidAmount, .amountIsGreaterThanValidAmount, .invalidCurrency, .other:
                    return false
                }
            case .nameIsTooLong:
                switch $1 {
                case  .nameIsTooLong, .invalidName, .invalidEmail, .invalidPhoneNumber, .typeNotSupported, .currencyNotSupported:
                    return true
                case .amountIsLessThanValidAmount, .amountIsGreaterThanValidAmount, .invalidCurrency, .emptyName, .other:
                    return false
                }
            case .invalidName:
                switch $1 {
                case .invalidName, .invalidEmail, .invalidPhoneNumber, .typeNotSupported, .currencyNotSupported:
                    return true
                case .amountIsLessThanValidAmount, .amountIsGreaterThanValidAmount, .invalidCurrency, .emptyName, .nameIsTooLong, .other:
                    return false
                }
            case .invalidEmail:
                switch $1 {
                case .invalidEmail, .invalidPhoneNumber, .typeNotSupported, .currencyNotSupported:
                    return true
                case .amountIsLessThanValidAmount, .amountIsGreaterThanValidAmount,
                     .invalidCurrency, .emptyName, .nameIsTooLong, .invalidName, .other:
                    return false
                }
            case .invalidPhoneNumber:
                switch $1 {
                case .invalidPhoneNumber, .typeNotSupported, .currencyNotSupported:
                    return true
                case .amountIsLessThanValidAmount, .amountIsGreaterThanValidAmount, .invalidCurrency,
                     .emptyName, .nameIsTooLong, .invalidEmail, .invalidName, .other:
                    return false
                }
            case .typeNotSupported:
                switch $1 {
                case .typeNotSupported, .currencyNotSupported:
                    return true
                case .amountIsLessThanValidAmount, .amountIsGreaterThanValidAmount, .invalidCurrency,
                     .emptyName, .nameIsTooLong, .invalidEmail, .invalidName, .invalidPhoneNumber, .other:
                    return false
                }
            case .currencyNotSupported:
                switch $1 {
                case  .currencyNotSupported:
                    return true
                case .amountIsLessThanValidAmount, .amountIsGreaterThanValidAmount, .invalidCurrency, .emptyName,
                     .nameIsTooLong, .invalidName, .invalidEmail, .invalidPhoneNumber, .typeNotSupported, .other:
                    return false
                }
            }
        })
    }
    

}

#if swift(>=4.2)
#else
extension OmiseError.APIErrorCode.BadRequestReason {
    public var hashValue: Int {
        switch self {
        case .amountIsLessThanValidAmount(validAmount: let amount, currency: let currency):
            return ~"amountIsLessThanValidAmount".hashValue ^ (amount?.hashValue ?? 0) ^ (currency?.hashValue ?? 0)
        case .amountIsGreaterThanValidAmount(validAmount: let amount, currency: let currency):
            return ~"amountIsGreaterThanValidAmount".hashValue ^ (amount?.hashValue ?? 0) ^ (currency?.hashValue ?? 0)
        case .invalidCurrency:
            return ~"invalidCurrency".hashValue
        case .emptyName:
            return ~"emptyName".hashValue
        case .nameIsTooLong(maximum: let length):
            return ~"nameIsTooLong".hashValue ^ (length?.hashValue ?? 0)
        case .invalidName:
            return ~"invalidName".hashValue
        case .invalidEmail:
            return ~"invalidEmail".hashValue
        case .invalidPhoneNumber:
            return ~"invalidPhoneNumber".hashValue
        case .typeNotSupported:
            return ~"typeNotSupported".hashValue
        case .currencyNotSupported:
            return ~"currencyNotSupported".hashValue
        case .other(let message):
            return ~message.hashValue
        }
    }
}
#endif

