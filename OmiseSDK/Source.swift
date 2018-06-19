import Foundation

public struct Source: Object {
    public typealias CreateParameter = CreateSourceParameter
   
    public static let postURL: URL = URL(string: "https://api.omise.co/sources")!
    
    public let object: String
    public let id: String
    
    public let type: SourceType
    public let flow: Flow
    
    public let amount: Int64
    public let currency: Currency
}

public struct CreateSourceParameter: Encodable {
    public let type: SourceType
    public let amount: Int64
    public let currency: Currency
    
    public init(type: SourceType, amount: Int64, currency: Currency) {
        self.type = type
        self.amount = amount
        self.currency = currency
    }
}

public enum Flow: RawRepresentable, Decodable, Equatable {
    case redirect
    case offline
    case other(String)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let flow = try container.decode(String.self)
        self.init(rawValue: flow)!
    }
    
    public typealias RawValue = String
    public var rawValue: String {
        switch self {
        case .offline:
            return "offline"
        case .redirect:
            return "redirect"
        case .other(let value):
            return value
        }
    }
    public init?(rawValue: String) {
        switch rawValue {
        case "redirect":
            self = .redirect
        case "offline":
            self = .offline
        default:
            self = .other(rawValue)
        }
    }
}

public enum SourceType: RawRepresentable, Codable, Equatable {
    
    private static let internetBankingBAYValue = "internet_banking_bay"
    private static let internetBankingKTBValue = "internet_banking_ktb"
    private static let internetBankingSCBValue = "internet_banking_scb"
    private static let internetBankingBBLValue = "internet_banking_bbl"
    private static let alipayValue = "alipay"
    private static let billPaymentTescoLotusValue = "bill_payment_tesco_lotus"
    private static let barcodeAlipayValue = "barcode_alipay"

    case internetBankingBAY
    case internetBankingKTB
    case internetBankingSCB
    case internetBankingBBL
    case alipay
    case billPaymentTescoLotus
    case barcodeAlipay
    case other(String)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let code = try container.decode(String.self)
        self.init(rawValue: code)!
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
    
    public typealias RawValue = String
    
    public init?(rawValue: String) {
        switch rawValue {
        case SourceType.internetBankingBAYValue:
            self = .internetBankingBAY
        case SourceType.internetBankingKTBValue:
            self = .internetBankingKTB
        case SourceType.internetBankingSCBValue:
            self = .internetBankingSCB
        case SourceType.internetBankingBBLValue:
            self = .internetBankingBBL
        case SourceType.alipayValue:
            self = .alipay
        case SourceType.billPaymentTescoLotusValue:
            self = .billPaymentTescoLotus
        case SourceType.barcodeAlipayValue:
            self = .barcodeAlipay
        default:
            self = .other(rawValue)
        }
    }
    
    public var rawValue: String {
        let value: String
        switch self {
        case .internetBankingBAY:
            value = SourceType.internetBankingBAYValue
        case .internetBankingKTB:
            value = SourceType.internetBankingKTBValue
        case .internetBankingSCB:
            value = SourceType.internetBankingSCBValue
        case .internetBankingBBL:
            value = SourceType.internetBankingBBLValue
        case .alipay:
            value = SourceType.alipayValue
        case .billPaymentTescoLotus:
            value = SourceType.billPaymentTescoLotusValue
        case .barcodeAlipay:
            value = SourceType.barcodeAlipayValue
        case .other(let sourceValue):
            value = sourceValue
        }
        return value
    }
}


extension Request where T == Source {
    public init (sourceType: SourceType, amount: Int64, currency: Currency) {
        self.init(parameter: CreateSourceParameter(
            type: sourceType,
            amount: amount, currency: currency)
        )
    }
}

