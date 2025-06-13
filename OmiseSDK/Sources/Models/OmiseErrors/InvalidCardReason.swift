import Foundation

extension OmiseError.APIErrorCode.InvalidCardReason: Decodable {
    
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
                tableName: "Error",
                bundle: .omiseSDK,
                value: "Invalid card number",
                comment: "A default descriptive message representing an `Invalid card data` error with the `Invalid card number` message from the backend which a merchant may show this message to their user"
            )
        case .invalidExpirationDate:
            preferredErrorDescription = NSLocalizedString(
                "error.api.invalid_card.invalid-expiration-date.message",
                tableName: "Error",
                bundle: .omiseSDK,
                value: "Invalid card expiration date",
                comment: "A default descriptive message representing an `Invalid card data` error with the `Invalid card expiration date` message from the backend which a merchant may show this message to their user"
            )
        case .emptyCardHolderName:
            preferredErrorDescription = NSLocalizedString(
                "error.api.invalid_card.empty-card-holderName.message",
                tableName: "Error",
                bundle: .omiseSDK,
                value: "Invalid card holder name",
                comment: "A default descriptive message representing an `Invalid card data` error with the `Invalid card holder name` message from the backend which a merchant may show this message to their user"
            )
        case .unsupportedBrand:
            preferredErrorDescription = NSLocalizedString(
                "error.api.invalid_card.unsupported-brand.message",
                tableName: "Error",
                bundle: .omiseSDK,
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
                tableName: "Error",
                bundle: .omiseSDK,
                value: "Please review the card number",
                comment: "A default descriptive suggestion message to recovery from the `Invalid card data` error with the `Invalid card number` message from the backend which a merchant may show this message to their user"
            )
        case .invalidExpirationDate:
            preferredRecoverySuggestionMessage = NSLocalizedString(
                "error.api.invalid_card.invalid-expiration-date.recovery-suggestion",
                tableName: "Error",
                bundle: .omiseSDK,
                value: "Please review the card expiration date",
                comment: "A default descriptive suggestion message to recovery from the `Invalid card data` error with the `Invalid card expiration date` message from the backend which a merchant may show this message to their user"
            )
        case .emptyCardHolderName:
            preferredRecoverySuggestionMessage = NSLocalizedString(
                "error.api.invalid_card.empty-card-holder-name.recovery-suggestion",
                tableName: "Error",
                bundle: .omiseSDK,
                value: "Please review the card holder name",
                comment: "A default descriptive suggestion message to recovery from the `Invalid card data` error with the `Invalid card holder name` message from the backend which a merchant may show this message to their user"
            )
        case .unsupportedBrand:
            preferredRecoverySuggestionMessage = NSLocalizedString(
                "error.api.invalid_card.unsupported-brand.recovery-suggestion",
                tableName: "Error",
                bundle: .omiseSDK,
                value: "Please use another credit card",
                comment: "A default descriptive suggestion message to recovery from the `Invalid card data` error with the `Unsupported card brand` message from the backend which a merchant may show this message to their user"
            )
        case .other:
            preferredRecoverySuggestionMessage = NSLocalizedString(
                "error.api.invalid_card.other.recovery-suggestion",
                tableName: "Error",
                bundle: .omiseSDK,
                value: "Please review credit card information",
                comment: "A descriptive suggestion message to recovery from the `Invalid card data` error from the backend which a merchant may show this message to their user"
            )
        }
        
        return preferredRecoverySuggestionMessage.isEmpty ? nil : preferredRecoverySuggestionMessage
    }
    
    static func parseInvalidCardReasonsFromMessage(_ message: String) throws -> [OmiseError.APIErrorCode.InvalidCardReason] {
        let reasonMessages = message.components(separatedBy: ", and ").flatMap { $0.components(separatedBy: ", ") }
        var parsedReasons = Set(try reasonMessages.map(OmiseError.APIErrorCode.InvalidCardReason.init(message:)))
        
        if parsedReasons.contains(.invalidCardNumber) {
            parsedReasons.remove(.unsupportedBrand)
        }
        return parsedReasons.sorted {
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
        }
    }
}
