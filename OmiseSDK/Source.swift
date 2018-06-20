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
        case OMSSourceTypeValue.internetBankingBAY.rawValue:
            self = .internetBankingBAY
        case OMSSourceTypeValue.internetBankingKTB.rawValue:
            self = .internetBankingKTB
        case OMSSourceTypeValue.internetBankingSCB.rawValue:
            self = .internetBankingSCB
        case OMSSourceTypeValue.internetBankingBBL.rawValue:
            self = .internetBankingBBL
        case OMSSourceTypeValue.alipay.rawValue:
            self = .alipay
        case OMSSourceTypeValue.billPaymentTescoLotus.rawValue:
            self = .billPaymentTescoLotus
        case OMSSourceTypeValue.barcodeAlipay.rawValue:
            self = .barcodeAlipay
        default:
            self = .other(rawValue)
        }
    }
    
    public var rawValue: String {
        let value: String
        switch self {
        case .internetBankingBAY:
            value = OMSSourceTypeValue.internetBankingBAY.rawValue
        case .internetBankingKTB:
            value = OMSSourceTypeValue.internetBankingKTB.rawValue
        case .internetBankingSCB:
            value = OMSSourceTypeValue.internetBankingSCB.rawValue
        case .internetBankingBBL:
            value = OMSSourceTypeValue.internetBankingBBL.rawValue
        case .alipay:
            value = OMSSourceTypeValue.alipay.rawValue
        case .billPaymentTescoLotus:
            value = OMSSourceTypeValue.billPaymentTescoLotus.rawValue
        case .barcodeAlipay:
            value = OMSSourceTypeValue.barcodeAlipay.rawValue
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

