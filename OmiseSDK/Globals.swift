import Foundation
import os


@available(iOS 10.0, *)
let sdkLogObject: OSLog = OSLog(subsystem: "co.omise.ios.sdk", category: "SDK")

@available(iOS 10.0, *)
let uiLogObject: OSLog = OSLog(subsystem: "co.omise.ios.sdk", category: "UI")


extension Optional where Wrapped == String {
    public var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}


struct JSONCodingKeys: CodingKey {
    var stringValue: String
    
    init?(stringValue: String) {
        self.init(key: stringValue)
    }
    
    init(key: String) {
        self.stringValue = key
    }
    
    var intValue: Int?
    
    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}


enum CombineCodingKeys<Left: CodingKey, Right: CodingKey> : CodingKey {
    var stringValue: String {
        switch self {
        case .left(let left):
            return left.stringValue
        case .right(let right):
            return right.stringValue
        }
    }
    
    var intValue: Int? {
        switch self {
        case .left(let left):
            return left.intValue
        case .right(let right):
            return right.intValue
        }
    }
    
    init?(stringValue: String) {
        if let left = Left(stringValue: stringValue) {
            self = .left(left)
        } else if let right = Right(stringValue: stringValue) {
            self = .right(right)
        } else {
            return nil
        }
    }
    
    init?(intValue: Int) {
        if let left = Left(intValue: intValue) {
            self = .left(left)
        } else if let right = Right(intValue: intValue) {
            self = .right(right)
        } else {
            return nil
        }
    }
    
    case left(Left)
    case right(Right)
}

struct SkippingKeyCodingKeys<Key: CodingKey> : CodingKey {
    let stringValue: String
    
    init?(stringValue: String) {
        guard Key(stringValue: stringValue) == nil else {
            return nil
        }
        
        self.stringValue = stringValue
        self.intValue = Int(stringValue)
    }
    
    let intValue: Int?
    
    init?(intValue: Int) {
        guard Key(intValue: intValue) == nil else {
            return nil
        }
        
        self.intValue = intValue
        self.stringValue = String(intValue)
    }
}

extension OMSSourceTypeValue {
    var sourceTypePrefix: String {
        switch self {
        case .internetBankingBAY, .internetBankingKTB, .internetBankingSCB, .internetBankingBBL:
            return "internet_banking"
        case .alipay:
            return "alipay"
        case .billPaymentTescoLotus:
            return "bill_payment"
        case .barcodeAlipay:
            return "barcode"
        case .installmentBAY, .installmentFirstChoice, .installmentBBL, .installmentKTC, .installmentKBank:
            return "installment"
        case .eContext:
            return "econtext"
        case .promptPay:
            return "promptpay"
        case .payNow:
            return "paynow"
        case .trueMoney:
            return "truemoney"
        case .pointsCiti:
            return "points"
        default:
            return self.rawValue
        }
    }
}

extension Decoder {
    func decodeJSONDictionary() throws -> Dictionary<String, Any> {
        let container = try self.container(keyedBy: JSONCodingKeys.self)
        return try container.decodeJSONDictionary()
    }
}

extension KeyedDecodingContainerProtocol {
    func decode(_ type: Dictionary<String, Any>.Type, forKey key: Key) throws -> Dictionary<String, Any> {
        let container = try self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        return try container.decodeJSONDictionary()
    }
    
    func decodeIfPresent(_ type: Dictionary<String, Any>.Type, forKey key: Key) throws -> Dictionary<String, Any>? {
        guard contains(key) else {
            return nil
        }
        return try decode(type, forKey: key)
    }
    
    func decode(_ type: Array<Any>.Type, forKey key: Key) throws -> Array<Any> {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        return try container.decodeJSONArray()
    }
    
    func decodeIfPresent(_ type: Array<Any>.Type, forKey key: Key) throws -> Array<Any>? {
        guard contains(key) else {
            return nil
        }
        return try decode(type, forKey: key)
    }
    
    func decodeJSONDictionary() throws -> Dictionary<String, Any> {
        var dictionary = Dictionary<String, Any>()
        
        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            } else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            } else if let nestedArray = try? decode(Array<Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            } else if try decodeNil(forKey: key) {
                dictionary[key.stringValue] = String?.none as Any
            }
        }
        return dictionary
    }
}

extension UnkeyedDecodingContainer {
    mutating func decodeJSONArray() throws -> Array<Any> {
        var array: [Any] = []
        while isAtEnd == false {
            if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self) {
                array.append(nestedDictionary)
            } else if let nestedArray = try? decodeArrayElement() {
                array.append(nestedArray)
            }
        }
        return array
    }
    
    private mutating func decodeArrayElement() throws -> Array<Any> {
        var nestedContainer = try self.nestedUnkeyedContainer()
        return try nestedContainer.decodeJSONArray()
    }
    
    mutating func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        let nestedContainer = try self.nestedContainer(keyedBy: JSONCodingKeys.self)
        return try nestedContainer.decodeJSONDictionary()
    }
}


extension Encoder {
    func encodeJSONDictionary(_ jsonDictionary: Dictionary<String, Any>) throws {
        var container = self.container(keyedBy: JSONCodingKeys.self)
        try container.encodeJSONDictionary(jsonDictionary)
    }
}

extension KeyedEncodingContainerProtocol where Key == JSONCodingKeys {
    mutating func encodeJSONDictionary(_ value: Dictionary<String, Any>) throws {
        try value.forEach({ (key, value) in
            let key = JSONCodingKeys(key: key)
            switch value {
            case let value as Bool:
                try encode(value, forKey: key)
            case let value as Int:
                try encode(value, forKey: key)
            case let value as String:
                try encode(value, forKey: key)
            case let value as Double:
                try encode(value, forKey: key)
            case let value as Dictionary<String, Any>:
                try encode(value, forKey: key)
            case let value as Array<Any>:
                try encode(value, forKey: key)
            case Optional<Any>.none:
                try encodeNil(forKey: key)
            default:
                throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath + [key], debugDescription: "Invalid JSON value"))
            }
        })
    }
}

extension KeyedEncodingContainerProtocol {
    mutating func encode(_ value: Dictionary<String, Any>, forKey key: Key) throws {
        var container = self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        try container.encodeJSONDictionary(value)
    }
    
    mutating func encodeIfPresent(_ value: Dictionary<String, Any>?, forKey key: Key) throws {
        if let value = value {
            try encode(value, forKey: key)
        }
    }
    
    mutating func encode(_ value: Array<Any>, forKey key: Key) throws {
        var container = self.nestedUnkeyedContainer(forKey: key)
        try container.encodeJSONArray(value)
    }
    
    mutating func encodeIfPresent(_ value: Array<Any>?, forKey key: Key) throws {
        if let value = value {
            try encode(value, forKey: key)
        }
    }
}

extension UnkeyedEncodingContainer {
    mutating func encodeJSONArray(_ value: Array<Any>) throws {
        try value.enumerated().forEach({ (index, value) in
            switch value {
            case let value as Bool:
                try encode(value)
            case let value as Int:
                try encode(value)
            case let value as String:
                try encode(value)
            case let value as Double:
                try encode(value)
            case let value as Dictionary<String, Any>:
                try encodeJSONDictionary(value)
            case let value as Array<Any>:
                try encodeArrayElement(value)
            case Optional<Any>.none:
                try encodeNil()
            default:
                let keys = JSONCodingKeys(intValue: index).map({ [ $0 ] }) ?? []
                throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath + keys, debugDescription: "Invalid JSON value"))
            }
        })
    }
    
    private mutating func encodeArrayElement(_ value: Array<Any>) throws {
        var nestedContainer = self.nestedUnkeyedContainer()
        try nestedContainer.encodeJSONArray(value)
    }
    
    mutating func encodeJSONDictionary(_ value: Dictionary<String, Any>) throws {
        var nestedContainer = self.nestedContainer(keyedBy: JSONCodingKeys.self)
        try nestedContainer.encodeJSONDictionary(value)
    }
}

extension ControlState: Hashable {
    public var hashValue: Int {
        return rawValue.hashValue
    }
}

extension Bundle {
    public static let omiseSDKBundle = Bundle(for: CreditCardFormViewController.self)
}

extension NumberFormatter {
    static func makeAmountFormatter(for currency: Currency?) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency?.code
        if currency == .thb {
            formatter.currencySymbol = "฿"
        }
        return formatter
    }
}


extension OmiseError {
    var bannerErrorDescription: String {
        switch self {
        case .api(code: let code, message: _, location: _):
            switch code {
            case .invalidCard(let invalidCardReasons):
                switch invalidCardReasons.first {
                case .invalidCardNumber?:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.invalid-card-number.message",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Invalid card number",
                        comment: "The displaying message showing in the error banner in the built-in Payment Creator when there is the `invalid-card-number` API error occured"
                    )
                case .invalidExpirationDate?:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.invalid-expiration-date.message",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Invalid card expiration date",
                        comment: "The displaying message showing in the error banner in the built-in Payment Creator when there is the `invalid-expiration-date` API error occured"
                    )
                case .emptyCardHolderName?:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.empty-card-holder-name.message",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Invalid card holder name",
                        comment: "The displaying message showing in the error banner in the built-in Payment Creator when there is the `empty-card-holder-name` API error occured"
                    )
                case .unsupportedBrand?:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.unsupported-brand.message",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Unsupported card brand",
                        comment: "The displaying message showing in the error banner in the built-in Payment Creator when there is the `unsupported-brand` API error occured"
                    )
                case .other?, nil:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.other.message",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "An unknown error occured",
                        comment: "The displaying message showing in the error banner in the built-in Payment Creator when there is the `other` API error occured"
                    )
                }
            case .badRequest(let badRequestReasons):
                switch badRequestReasons.first {
                case .amountIsLessThanValidAmount(validAmount: let validAmount, currency: let currency)?:
                    if let validAmount = validAmount, let currency = currency {
                        let preferredErrorDescriptionFormat = NSLocalizedString(
                            "payment-creator.error.api.bad_request.amount-is-less-than-valid-amount.with-valid-amount.message",
                            tableName: "Error", bundle: Bundle.omiseSDKBundle,
                            value: "Amount is less than the valid amount of %@",
                            comment: "The displaying message showing in the error banner an `Bad request` error with `amount-is-less-than-valid-amount.with-valid-amount` from the backend has occurred"
                        )
                        let formatter = NumberFormatter.makeAmountFormatter(for: currency)
                        return String.localizedStringWithFormat(
                            preferredErrorDescriptionFormat,
                            formatter.string(from: NSNumber(value: currency.convert(fromSubunit: validAmount))) ?? "\(currency.convert(fromSubunit: validAmount))")
                    } else {
                        return NSLocalizedString(
                            "payment-creator.error.api.bad_request.amount-is-less-than-valid-amount.without-valid-amount.message",
                            tableName: "Error", bundle: Bundle.omiseSDKBundle,
                            value: "Amount is less than the valid amount",
                            comment: "The displaying message showing in the error banner an `Bad request` error with `amount-is-less-than-valid-amount.without-valid-amount` from the backend has occurred"
                        )
                    }
                case .amountIsGreaterThanValidAmount(validAmount: let validAmount, currency: let currency)?:
                    if let validAmount = validAmount, let currency = currency {
                        let preferredErrorDescriptionFormat = NSLocalizedString(
                            "payment-creator.error.api.bad_request.amount-is-greater-than-valid-amount.with-valid-amount.message",
                            tableName: "Error", bundle: Bundle.omiseSDKBundle,
                            value: "Amount is greater than the valid amount of %@",
                            comment: "The displaying message showing in the error banner an `Bad request` error with `amount-is-greater-than-valid-amount.with-valid-amount` from the backend has occurred"
                        )
                        let formatter = NumberFormatter.makeAmountFormatter(for: currency)
                        return String.localizedStringWithFormat(
                            preferredErrorDescriptionFormat,
                            formatter.string(from: NSNumber(value: currency.convert(fromSubunit: validAmount))) ?? "\(currency.convert(fromSubunit: validAmount))")
                    } else {
                        return NSLocalizedString(
                            "payment-creator.error.api.bad_request.amount-is-greater-than-valid-amount.without-valid-amount.message",
                            tableName: "Error", bundle: Bundle.omiseSDKBundle,
                            value: "Amount is greater than the valid amount",
                            comment: "The displaying message showing in the error banner an `Bad request` error with `amount-is-greater-than-valid-amount.without-valid-amount` from the backend has occurred"
                        )
                    }
                case .invalidCurrency?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.invalid-currency.message",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "The currency is invalid",
                        comment: "The displaying message showing in the error banner an `Bad request` error with `invalid-currency` from the backend has occurred"
                    )
                    
                case .emptyName?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.empty-name.message",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "The customer name is empty",
                        comment: "The displaying message showing in the error banner an `Bad request` error with `empty-name` from the backend has occurred"
                    )
                    
                case .nameIsTooLong(maximum: let maximumLength)?:
                    if let maximumLength = maximumLength {
                        let preferredErrorDescriptionFormat = NSLocalizedString(
                            "payment-creator.error.api.bad_request.name-is-too-long.with-valid-length.message",
                            tableName: "Error", bundle: Bundle.omiseSDKBundle,
                            value: "The customer name exceeds %d characters",
                            comment: "The displaying message showing in the error banner an `Bad request` error with `name-is-too-long.with-valid-length` from the backend has occurred"
                        )
                        return String.localizedStringWithFormat(preferredErrorDescriptionFormat, maximumLength)
                    } else {
                        return NSLocalizedString(
                            "payment-creator.error.api.bad_request.name-is-too-long.without-valid-length.message",
                            tableName: "Error", bundle: Bundle.omiseSDKBundle,
                            value: "The customer name is too long",
                            comment: "The displaying message showing in the error banner an `Bad request` error with `name-is-too-long.without-valid-length` from the backend has occurred"
                        )
                    }
                case .invalidName?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.invalid-name.message",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "The customer name is invalid",
                        comment: "The displaying message showing in the error banner an `Bad request` error with `invalid-name` from the backend has occurred"
                    )
                    
                case .invalidEmail?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.invalid-email.message",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "The customer email is invalid",
                        comment: "The displaying message showing in the error banner an `Bad request` error with `invalid-email` from the backend has occurred"
                    )
                    
                case .invalidPhoneNumber?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.invalid-phone-number.message",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "The customer phone number is invalid",
                        comment: "The displaying message showing in the error banner an `Bad request` error with `invalid-phone-number` from the backend has occurred"
                    )
                    
                case .typeNotSupported?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.type-not-supported.message",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "The source type is not supported by this account",
                        comment: "The displaying message showing in the error banner an `Bad request` error with `type-not-supported` from the backend has occurred"
                    )
                    
                case .currencyNotSupported?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.currency-not-supported.message",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "The currency is not supported for this account",
                        comment: "The displaying message showing in the error banner an `Bad request` error with `currency-not-supported` from the backend has occurred"
                    )
                case .other?, nil:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.other.message",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Unknown error occurred",
                        comment: "The displaying message showing in the error banner an `Bad request` error with `other` from the backend has occurred"
                    )
                }
            case .authenticationFailure, .serviceNotFound:
                return NSLocalizedString(
                    "payment-creator.error.api.unexpected.message",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "An unexpected error occured",
                    comment: "The displaying message showing in the error banner in the built-in Payment Creator when there is the `unexpected` API error occured"
                )
            case .other:
                return NSLocalizedString(
                    "payment-creator.error.api.unknown.message",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "An unknown error occured",
                    comment: "The displaying message showing in the error banner when there is an `unknown` API error occured"
                )
            }
        case .unexpected:
            return NSLocalizedString(
                "payment-creator.error.unexpected.message",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "An unexpected error occurred",
                comment: "The displaying message showing in the error banner when there is the `unexpected` error occured"
            )
        }
    }
    
    var bannerErrorRecoverySuggestion: String {
        switch self {
        case .api(code: let code, message: _, location: _):
            switch code {
            case .invalidCard(let invalidCardReasons):
                switch invalidCardReasons.first {
                case .invalidCardNumber?:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.invalid-card-number.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please review the card number",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator in the built-in Payment Creator when there is the `invalid-card-number` API error occured"
                    )
                case .invalidExpirationDate?:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.invalid-expiration-date.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please review the card expiration date again.",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator in the built-in Payment Creator when there is the `invalid-expiration-date` API error occured"
                    )
                case .emptyCardHolderName?:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.empty-card-holder-name.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please review the card holder name",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator in the built-in Payment Creator when there is the `empty-card-holder-name` API error occured"
                    )
                case .unsupportedBrand?:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.unsupported-brand.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please use another card",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator in the built-in Payment Creator when there is the `unsupported-brand` API error occured"
                    )
                case .other?, nil:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.other.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please try again later",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator in the built-in Payment Creator when there is the `other` API error occured"
                    )
                }
            case .badRequest(let badRequestReasons):
                switch badRequestReasons.first {
                case .amountIsLessThanValidAmount(validAmount: let validAmount, currency: let currency)?:
                    if let validAmount = validAmount, let currency = currency {
                        let preferredErrorDescriptionFormat = NSLocalizedString(
                            "payment-creator.error.api.bad_request.amount-is-less-than-valid-amount.with-valid-amount.recovery-suggestion",
                            tableName: "Error", bundle: Bundle.omiseSDKBundle,
                            value: "The payment amount is too low. Please make a payment with a higher amount.",
                            comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `amount-is-less-than-valid-amount.with-valid-amount` from the backend has occurred"
                        )
                        let formatter = NumberFormatter.makeAmountFormatter(for: currency)
                        return String.localizedStringWithFormat(
                            preferredErrorDescriptionFormat,
                            formatter.string(from: NSNumber(value: currency.convert(fromSubunit: validAmount))) ?? "\(currency.convert(fromSubunit: validAmount))")
                    } else {
                        return NSLocalizedString(
                            "payment-creator.error.api.bad_request.amount-is-less-than-valid-amount.without-valid-amount.recovery-suggestion",
                            tableName: "Error", bundle: Bundle.omiseSDKBundle,
                            value: "The payment amount is too low. Please make a payment with a higher amount.",
                            comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `amount-is-less-than-valid-amount.without-valid-amount` from the backend has occurred"
                        )
                    }
                case .amountIsGreaterThanValidAmount(validAmount: let validAmount, currency: let currency)?:
                    if let validAmount = validAmount, let currency = currency {
                        let preferredErrorDescriptionFormat = NSLocalizedString(
                            "payment-creator.error.api.bad_request.amount-is-greater-than-valid-amount.with-valid-amount.recovery-suggestion",
                            tableName: "Error", bundle: Bundle.omiseSDKBundle,
                            value: "The payment amount is too high. Please make a payment with a lower amount.",
                            comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `amount-is-greater-than-valid-amount.with-valid-amount` from the backend has occurred"
                        )
                        let formatter = NumberFormatter.makeAmountFormatter(for: currency)
                        return String.localizedStringWithFormat(
                            preferredErrorDescriptionFormat,
                            formatter.string(from: NSNumber(value: currency.convert(fromSubunit: validAmount))) ?? "\(currency.convert(fromSubunit: validAmount))")
                    } else {
                        return NSLocalizedString(
                            "payment-creator.error.api.bad_request.amount-is-greater-than-valid-amount.without-valid-amount.recovery-suggestion",
                            tableName: "Error", bundle: Bundle.omiseSDKBundle,
                            value: "The payment amount is too high. Please make a payment with a lower amount.",
                            comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `amount-is-greater-than-valid-amount.without-valid-amount` from the backend has occurred"
                        )
                    }
                case .invalidCurrency?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.invalid-currency.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please choose another currency or contact customer support",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `invalid-currency` from the backend has occurred"
                    )
                    
                case .emptyName?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.empty-name.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please fill in the customer name",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `empty-name` from the backend has occurred"
                    )
                    
                case .nameIsTooLong(maximum: _)?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.name-is-too-long.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please review the customer name",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `name-is-too-long.without-valid-length` from the backend has occurred"
                    )
                case .invalidName?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.invalid-name.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please review the customer name",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `invalid-name` from the backend has occurred"
                    )
                    
                case .invalidEmail?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.invalid-email.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please review the email",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `invalid-email` from the backend has occurred"
                    )
                    
                case .invalidPhoneNumber?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.invalid-phone-number.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please review the phone number",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `invalid-phone-number` from the backend has occurred"
                    )
                    
                case .typeNotSupported?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.type-not-supported.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please contact customer support",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `type-not-supported` from the backend has occurred"
                    )
                    
                case .currencyNotSupported?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.currency-not-supported.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please choose another currency",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `currency-not-supported` from the backend has occurred"
                    )
                case .other?, nil:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.other.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please try again later",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `other` from the backend has occurred"
                    )
                }
            case .authenticationFailure, .serviceNotFound:
                return NSLocalizedString(
                    "payment-creator.error.api.unexpected.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Please try again later",
                    comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator when there is the `unexpected` API error occured"
                )
            case .other:
                return NSLocalizedString(
                    "payment-creator.error.api.unknown.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Please try again later",
                    comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator when there is an `unknown` API error occured"
                )
            }
        case .unexpected:
            return NSLocalizedString(
                "payment-creator.error.unexpected.recovery-suggestion",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "Please try again later",
                comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator when there is the `unexpected` error occured"
            )
        }
    }
}

