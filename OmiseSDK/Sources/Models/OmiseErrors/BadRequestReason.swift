import Foundation
// swiftlint:disable file_length
extension OmiseError.APIErrorCode.BadRequestReason: Decodable {
    private enum ErrorMessageRegularExpression {
        // swiftlint:disable line_length
        static let amountAtLeastValidAmount: NSRegularExpression! = try? NSRegularExpression(pattern: "amount must be at least ([\\d]+)", options: [])
        static let amountGreaterThanValidAmount: NSRegularExpression! = try? NSRegularExpression(pattern: "amount must be less than ([\\d]+)", options: [])
        static let amountLessThanValidAmount: NSRegularExpression! = try? NSRegularExpression(pattern: "amount must be greater than ([\\d]+)", options: [])
        static let nameIsTooLong: NSRegularExpression! = try? NSRegularExpression(pattern: "name is too long \\(maximum is ([\\d]+) characters\\)", options: [])
        // swiftlint:enable line_length
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(message: try container.decode(String.self), currency: .main)
    }
    
    init(message: String, currency: Currency?) throws {
        if message.hasPrefix("amount must be ") {
            self = Self.processAmountMessage(message: message, currency: currency)
        } else if message.contains("currency must be") {
            self = .invalidCurrency
        } else if message.contains("type") {
            self = .typeNotSupported
        } else if message.contains("currency") {
            self = .currencyNotSupported
        } else if message.contains("name") && message.contains("blank") {
            self = .emptyName
        } else if message.contains("name") && message.contains("invalid") {
            self = .invalidName
        } else if message.hasPrefix("name is too long"), let reason = Self.processNameTooLongMessage(message: message) {
            self = reason
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
    
    var defaultLocalizedErrorDescription: String? {
        let preferredErrorDescription: String
        switch self {
        case .amountIsLessThanValidAmount(validAmount: let validAmount, currency: let currency):
            if let validAmount = validAmount, let currency = currency {
                let preferredErrorDescriptionFormat = getLocalizedError(
                    "error.api.bad_request.amount-is-less-than-valid-amount.with-valid-amount.message",
                    defaultValue: "Amount is less than the valid amount of %@",
                    comment: """
                            A default descriptive message representing an `Bad request` error with \
                            `amount-is-less-than-valid-amount.with-valid-amount` from the backend which \
                            a merchant may show this message to their user
                            """
                )
                let formatter = NumberFormatter.makeAmountFormatter(for: currency)
                preferredErrorDescription = String.localizedStringWithFormat(
                    preferredErrorDescriptionFormat,
                    formatter.string(from: NSNumber(value: currency.convert(fromSubunit: validAmount))) ?? "\(currency.convert(fromSubunit: validAmount))")
            } else {
                preferredErrorDescription = getLocalizedError(
                    "error.api.bad_request.amount-is-less-than-valid-amount.without-valid-amount.message",
                    defaultValue: "Amount is less than the valid amount",
                    comment: """
                            A default descriptive message representing an `Bad request` error with \
                            `amount-is-less-than-valid-amount.without-valid-amount` from the backend \
                            which a merchant may show this message to their user
                            """
                )
            }
        case .amountIsGreaterThanValidAmount(validAmount: let validAmount, currency: let currency):
            if let validAmount = validAmount, let currency = currency {
                let preferredErrorDescriptionFormat = getLocalizedError(
                    "error.api.bad_request.amount-is-greater-than-valid-amount.with-valid-amount.message",
                    defaultValue: "Amount exceeds the valid amount of %@",
                    comment: """
                            A default descriptive message representing an `Bad request` error with \
                            `amount-is-greater-than-valid-amount.with-valid-amount` from the backend \
                             which a merchant may show this message to their user
                            """
                )
                let formatter = NumberFormatter.makeAmountFormatter(for: currency)
                preferredErrorDescription = String.localizedStringWithFormat(
                    preferredErrorDescriptionFormat,
                    formatter.string(from: NSNumber(value: currency.convert(fromSubunit: validAmount))) ?? "\(currency.convert(fromSubunit: validAmount))")
            } else {
                preferredErrorDescription = getLocalizedError(
                    "error.api.bad_request.amount-is-greater-than-valid-amount.without-valid-amount.message",
                    defaultValue: "Amount exceeds the valid amount",
                    comment: """
                            A default descriptive message representing an `Bad request` error with \
                            `amount-is-greater-than-valid-amount.without-valid-amount` from the \
                            backend which a merchant may show this message to their user
                            """
                )
            }
        case .invalidCurrency:
            preferredErrorDescription = getLocalizedError(
                "error.api.bad_request.invalid-currency.message",
                defaultValue: "The currency is invalid",
                comment: """
                        A default descriptive message representing an `Bad request` error with \
                        `invalid-currency` from the backend which a merchant may show this message to their user
                        """
            )
            
        case .emptyName:
            preferredErrorDescription = getLocalizedError(
                "error.api.bad_request.empty-name.message",
                defaultValue: "The customer name is empty",
                comment: """
                        A default descriptive message representing an `Bad request` error with `empty-name` from  \
                        the backend which a merchant may show this message to their user
                        """
            )
            
        case .nameIsTooLong(maximum: let maximumLength):
            if let maximumLength = maximumLength {
                let preferredErrorDescriptionFormat = getLocalizedError(
                    "error.api.bad_request.name-is-too-long.with-valid-length.message",
                    defaultValue: "The customer name exceeds the %d character limit",
                    comment: """
                            A default descriptive message representing an `Bad request` error with \
                            `name-is-too-long.with-valid-length` from the backend which a merchant may show this message to their user
                            """
                )
                preferredErrorDescription = String.localizedStringWithFormat(preferredErrorDescriptionFormat, maximumLength)
            } else {
                preferredErrorDescription = getLocalizedError(
                    "error.api.bad_request.name-is-too-long.without-valid-length.message",
                    defaultValue: "The customer name is too long",
                    comment: """
                            A default descriptive message representing an `Bad request` error with \
                            `name-is-too-long.without-valid-length` from the backend which a merchant may show this message to their user
                            """
                )
            }
        case .invalidName:
            preferredErrorDescription = getLocalizedError(
                "error.api.bad_request.invalid-name.message",
                defaultValue: "The customer name is invalid",
                comment: """
                        A default descriptive message representing an `Bad request` error with `invalid-name` \
                        from the backend which a merchant may show this message to their user
                        """
            )
        case .invalidEmail:
            preferredErrorDescription = getLocalizedError(
                "error.api.bad_request.invalid-email.message",
                defaultValue: "The customer email is invalid",
                comment: """
                        A default descriptive message representing an `Bad request` error with \
                        `invalid-email` from the backend which a merchant may show this message to their user
                        """
            )
            
        case .invalidPhoneNumber:
            preferredErrorDescription = getLocalizedError(
                "error.api.bad_request.invalid-phone-number.message",
                defaultValue: "The customer phone number is invalid",
                comment: """
                        A default descriptive message representing an `Bad request` error with `invalid-phone-number` \
                        from the backend which a merchant may show this message to their user
                        """
            )
            
        case .typeNotSupported:
            preferredErrorDescription = getLocalizedError(
                "error.api.bad_request.type-not-supported.message",
                defaultValue: "The source type is not supported by this account",
                comment: """
                        A default descriptive message representing an `Bad request` error with \
                        `type-not-supported` from the backend which a merchant may show this message to their user
                        """
            )
            
        case .currencyNotSupported:
            preferredErrorDescription = getLocalizedError(
                "error.api.bad_request.currency-not-supported.message",
                defaultValue: "The currency is not supported by this account",
                comment: """
                        A default descriptive message representing an `Bad request` error with \
                        `currency-not-supported` from the backend which a merchant may show this message to their user
                        """
            )
        case .other(let value):
            let preferredErrorDescriptionFormat = getLocalizedError(
                "error.api.bad_request.other.message",
                defaultValue: "Bad request: %@",
                comment: """
                        A default descriptive message representing an `Bad request` error with \
                        `other` from the backend which a merchant may show this message to their user
                        """
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
                let preferredRecoverySuggestionMessageFormat = getLocalizedError(
                    "error.api.bad_request.amount-is-less-than-valid-amount.with-valid-amount.recovery-suggestion",
                    defaultValue: "Please create a source with an amount that is greater than %@",
                    comment: """
                            A default descriptive message representing an `Bad request` error with \
                            `amount-is-less-than-valid-amount.with-valid-amount` from the backend which a merchant may \
                            show this message to their user
                            """
                )
                let formatter = NumberFormatter.makeAmountFormatter(for: currency)
                preferredRecoverySuggestionMessage = String.localizedStringWithFormat(
                    preferredRecoverySuggestionMessageFormat,
                    formatter.string(from: NSNumber(value: currency.convert(fromSubunit: validAmount))) ?? "\(currency.convert(fromSubunit: validAmount))")
            } else {
                preferredRecoverySuggestionMessage = getLocalizedError(
                    "error.api.bad_request.amount-is-less-than-valid-amount.without-valid-amount.recovery-suggestion",
                    defaultValue: "Please create a source with a greater amount",
                    comment: """
                            A default descriptive message representing an `Bad request` error with \
                            `amount-is-less-than-valid-amount.without-valid-amount` from the backend which a merchant \
                            may show this message to their user
                            """
                )
            }
        case .amountIsGreaterThanValidAmount(validAmount: let validAmount, currency: let currency):
            if let validAmount = validAmount, let currency = currency {
                let preferredRecoverySuggestionMessageFormat = getLocalizedError(
                    "error.api.bad_request.amount-is-greater-than-valid-amount.with-valid-amount.recovery-suggestion",
                    defaultValue: "Please create a source with an amount which is less than %@",
                    comment: """
                            A default descriptive message representing an `Bad request` error with \
                            `amount-is-greater-than-valid-amount.with-valid-amount` from the backend which a merchant may show \
                            this message to their user
                            """
                )
                let formatter = NumberFormatter.makeAmountFormatter(for: currency)
                return String.localizedStringWithFormat(
                    preferredRecoverySuggestionMessageFormat,
                    formatter.string(from: NSNumber(value: currency.convert(fromSubunit: validAmount))) ?? "\(currency.convert(fromSubunit: validAmount))")
            } else {
                preferredRecoverySuggestionMessage = getLocalizedError(
                    "error.api.bad_request.amount-is-greater-than-valid-amount.without-valid-amount.recovery-suggestion",
                    defaultValue: "Please create a source with less amount",
                    comment: """
                    A default descriptive message representing an `Bad request` error with \
                    `amount-is-greater-than-valid-amount.without-valid-amount` from the backend which a \
                    merchant may show this message to their user
                    """
                )
            }
        case .invalidCurrency:
            preferredRecoverySuggestionMessage = getLocalizedError(
                "error.api.bad_request.invalid-currency.recovery-suggestion",
                defaultValue: "Bad request",
                comment: """
                    A default descriptive message representing an `Bad request` error with `invalid-currency` from \
                    the backend which a merchant may show this message to their user
                    """
            )
            
        case .emptyName:
            preferredRecoverySuggestionMessage = getLocalizedError(
                "error.api.bad_request.empty-name.recovery-suggestion",
                defaultValue: "Please input customer name",
                comment: """
                    A default descriptive message representing an `Bad request` error with `empty-name` \
                    from the backend which a merchant may show this message to their user
                    """
            )
        case .nameIsTooLong(maximum: let maximumLength):
            if let maximumLength = maximumLength {
                let preferredRecoverySuggestionMessageFormat = getLocalizedError(
                    "error.api.bad_request.name-is-too-long.with-valid-length.recovery-suggestion",
                    defaultValue: "Please input customer name which is no longer than %d characters",
                    comment: """
                    A default descriptive message representing an `Bad request` error with \
                    `name-is-too-long.with-valid-length` from the backend which a merchant may show this message to their user
                    """
                )
                // swiftlint:disable:next line_length
                preferredRecoverySuggestionMessage = String.localizedStringWithFormat(preferredRecoverySuggestionMessageFormat, maximumLength)
            } else {
                preferredRecoverySuggestionMessage = getLocalizedError(
                    "error.api.bad_request.name-is-too-long.without-valid-length.recovery-suggestion",
                    defaultValue: "Please input shorter customer name",
                    comment: """
                    A default descriptive message representing an `Bad request` error with \
                    `name-is-too-long.without-valid-length` from the backend which a merchant may show this message to their user
                    """
                )
            }
        case .invalidName:
            preferredRecoverySuggestionMessage = getLocalizedError(
                "error.api.bad_request.invalid-name.recovery-suggestion",
                defaultValue: "Please review the customer name",
                comment: """
                    A default descriptive message representing an `Bad request` error with `invalid-name` \
                    from the backend which a merchant may show this message to their user
                    """
            )
        case .invalidEmail:
            preferredRecoverySuggestionMessage = getLocalizedError(
                "error.api.bad_request.invalid-email.recovery-suggestion",
                defaultValue: "Please review the customer email",
                comment: """
                    A default descriptive message representing an `Bad request` error with \
                    `invalid-email` from the backend which a merchant may show this message to their user
                    """
            )
        case .invalidPhoneNumber:
            preferredRecoverySuggestionMessage = getLocalizedError(
                "error.api.bad_request.invalid-phone-number.recovery-suggestion",
                defaultValue: "Please review the customer phone number",
                comment: """
                    A default descriptive message representing an `Bad request` error with \
                    `invalid-phone-number` from the backend which a merchant may show this message to their user
                    """
            )
        case .typeNotSupported:
            preferredRecoverySuggestionMessage = getLocalizedError(
                "error.api.bad_request.type-not-supported.recovery-suggestion",
                defaultValue: "Please review the source type",
                comment: """
                    A default descriptive message representing an `Bad request` error with \
                    `type-not-supported` from the backend which a merchant may show this message to their user
                    """
            )
        case .currencyNotSupported:
            preferredRecoverySuggestionMessage = getLocalizedError(
                "error.api.bad_request.currency-not-supported.recovery-suggestion",
                defaultValue: "Please choose another currency",
                comment: """
                    A default descriptive message representing an `Bad request` error with \
                    `currency-not-supported` from the backend which a merchant may show this message to their user
                    """
            )
        case .other(let value):
            preferredRecoverySuggestionMessage = value
        }
        
        return preferredRecoverySuggestionMessage.isEmpty ? nil : preferredRecoverySuggestionMessage
    }
    
    static func parseBadRequestReasonsFromMessage(_ message: String, currency: Currency?) throws -> [OmiseError.APIErrorCode.BadRequestReason] {
        let reasonMessages = message.components(separatedBy: ", and ")
            .flatMap { $0.components(separatedBy: ", ") }
            .flatMap { $0.components(separatedBy: " and ") }
        let parsedReasons = Set(try reasonMessages.map {
            try OmiseError.APIErrorCode.BadRequestReason(message: $0, currency: currency)
        })
        
        return parsedReasons.sorted { lhs, rhs in
            // 1) If lhs is `.other` it must go *after* anything else:
            if case .other = lhs {
                return false
            }
            // 2) If rhs is `.other` then lhs (which is not `.other`) goes *before*:
            if case .other = rhs {
                return true
            }
            
            switch lhs {
            case .amountIsLessThanValidAmount:
                return true
            case .amountIsGreaterThanValidAmount:
                return Self.sortByAmountIsGreaterThanValidAmount(reason: rhs)
            case .invalidCurrency:
                return Self.sortByInvalidCurrency(reason: rhs)
            case .emptyName:
                return Self.sortByEmptyName(reason: rhs)
            case .nameIsTooLong:
                return Self.sortByNameIsTooLong(reason: rhs)
            case .invalidName:
                return Self.sortByInvalidName(reason: rhs)
            case .invalidEmail:
                return Self.sortByInvalidEmail(reason: rhs)
            case .invalidPhoneNumber:
                return Self.sortByInvalidPhoneNumber(reason: rhs)
            case .typeNotSupported:
                return Self.sortByTypeNotSupported(reason: rhs)
            case .currencyNotSupported:
                return Self.sortByCurrencyNotSupported(reason: rhs)
            default:
                return false
            }
        }
    }
}

// MARK: - Sort
extension OmiseError.APIErrorCode.BadRequestReason {
    static func sortByAmountIsGreaterThanValidAmount(reason: OmiseError.APIErrorCode.BadRequestReason) -> Bool {
        switch reason {
        case .amountIsGreaterThanValidAmount, .invalidCurrency, .emptyName, .nameIsTooLong, .invalidName,
                .invalidEmail, .invalidPhoneNumber, .typeNotSupported, .currencyNotSupported:
            return true
        case .amountIsLessThanValidAmount, .other:
            return false
        }
    }
    
    static func sortByInvalidCurrency(reason: OmiseError.APIErrorCode.BadRequestReason) -> Bool {
        switch reason {
        case .invalidCurrency, .emptyName, .nameIsTooLong, .invalidName, .invalidEmail,
                .invalidPhoneNumber, .typeNotSupported, .currencyNotSupported:
            return true
        case .amountIsLessThanValidAmount, .amountIsGreaterThanValidAmount, .other:
            return false
        }
        
    }
    static func sortByEmptyName(reason: OmiseError.APIErrorCode.BadRequestReason) -> Bool {
        switch reason {
        case .emptyName, .nameIsTooLong, .invalidName, .invalidEmail, .invalidPhoneNumber,
                .typeNotSupported, .currencyNotSupported:
            return true
        case .amountIsLessThanValidAmount, .amountIsGreaterThanValidAmount, .invalidCurrency, .other:
            return false
        }
        
    }
    
    static func sortByNameIsTooLong(reason: OmiseError.APIErrorCode.BadRequestReason) -> Bool {
        switch reason {
        case  .nameIsTooLong, .invalidName, .invalidEmail, .invalidPhoneNumber, .typeNotSupported, .currencyNotSupported:
            return true
        case .amountIsLessThanValidAmount, .amountIsGreaterThanValidAmount, .invalidCurrency, .emptyName, .other:
            return false
        }
    }
    
    static func sortByInvalidName(reason: OmiseError.APIErrorCode.BadRequestReason) -> Bool {
        switch reason {
        case .invalidName, .invalidEmail, .invalidPhoneNumber, .typeNotSupported, .currencyNotSupported:
            return true
        case .amountIsLessThanValidAmount, .amountIsGreaterThanValidAmount, .invalidCurrency, .emptyName, .nameIsTooLong, .other:
            return false
        }
    }
    
    static func sortByInvalidEmail(reason: OmiseError.APIErrorCode.BadRequestReason) -> Bool {
        switch reason {
        case .invalidEmail, .invalidPhoneNumber, .typeNotSupported, .currencyNotSupported:
            return true
        case .amountIsLessThanValidAmount, .amountIsGreaterThanValidAmount,
                .invalidCurrency, .emptyName, .nameIsTooLong, .invalidName, .other:
            return false
        }
    }
    
    static func sortByInvalidPhoneNumber(reason: OmiseError.APIErrorCode.BadRequestReason) -> Bool {
        switch reason {
        case .invalidPhoneNumber, .typeNotSupported, .currencyNotSupported:
            return true
        case .amountIsLessThanValidAmount, .amountIsGreaterThanValidAmount, .invalidCurrency,
                .emptyName, .nameIsTooLong, .invalidEmail, .invalidName, .other:
            return false
        }
    }
    
    static func sortByTypeNotSupported(reason: OmiseError.APIErrorCode.BadRequestReason) -> Bool {
        switch reason {
        case .typeNotSupported, .currencyNotSupported:
            return true
        case .amountIsLessThanValidAmount, .amountIsGreaterThanValidAmount, .invalidCurrency,
                .emptyName, .nameIsTooLong, .invalidEmail, .invalidName, .invalidPhoneNumber, .other:
            return false
        }
    }
    
    static func sortByCurrencyNotSupported(reason: OmiseError.APIErrorCode.BadRequestReason) -> Bool {
        switch reason {
        case  .currencyNotSupported:
            return true
        case .amountIsLessThanValidAmount, .amountIsGreaterThanValidAmount, .invalidCurrency, .emptyName,
                .nameIsTooLong, .invalidName, .invalidEmail, .invalidPhoneNumber, .typeNotSupported, .other:
            return false
        }
    }
}

// MARK: - Process Message
private extension OmiseError.APIErrorCode.BadRequestReason {
    static func processAmountMessage(message: String, currency: Currency?) -> Self {
        if let lessThanValidAmountMatch = ErrorMessageRegularExpression.amountLessThanValidAmount
            .firstMatch(in: message, range: NSRange(message.startIndex..<message.endIndex, in: message)),
           lessThanValidAmountMatch.numberOfRanges == 2,
           let amountRange = Range(lessThanValidAmountMatch.range(at: 1), in: message) {
            return .amountIsLessThanValidAmount(validAmount: Int64(message[amountRange]), currency: currency)
        } else if let greaterThanValidAmountMatch = ErrorMessageRegularExpression.amountGreaterThanValidAmount
            .firstMatch(in: message, range: NSRange(message.startIndex..<message.endIndex, in: message)),
                  greaterThanValidAmountMatch.numberOfRanges == 2,
                  let amountRange = Range(greaterThanValidAmountMatch.range(at: 1), in: message) {
            return .amountIsGreaterThanValidAmount(validAmount: Int64(message[amountRange]), currency: currency)
        } else if let atLeastValidAmountMatch = ErrorMessageRegularExpression.amountAtLeastValidAmount
            .firstMatch(in: message, range: NSRange(message.startIndex..<message.endIndex, in: message)),
                  atLeastValidAmountMatch.numberOfRanges == 2,
                  let amountRange = Range(atLeastValidAmountMatch.range(at: 1), in: message) {
            return .amountIsLessThanValidAmount(validAmount: Int64(message[amountRange]), currency: currency)
        } else {
            return .other(message)
        }
    }
    
    static func processNameTooLongMessage(message: String) -> Self? {
        let matchRange = NSRange(message.startIndex..<message.endIndex, in: message)
        guard let match = ErrorMessageRegularExpression.nameIsTooLong.firstMatch(in: message, range: matchRange),
              match.numberOfRanges == 2,
              let range = Range(match.range(at: 1), in: message) else {
            return nil
        }
        
        return .nameIsTooLong(maximum: Int(message[range]))
    }
}
// swiftlint:enable file_length
