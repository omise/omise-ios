import Foundation


/// Represents an Omise Source object
public struct Source: Object {
    public typealias CreateParameter = CreateSourceParameter
   
    public static let postURL: URL = URL(string: "https://api.omise.co/sources")!
    
    public let object: String
    public let id: String
    
    public let paymentInformation: PaymentInformation
    public let flow: Flow
    
    public let amount: Int64
    public let currency: Currency
    
    enum CodingKeys: String, CodingKey {
        case object
        case id
        case flow
        case amount
        case currency
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        paymentInformation = try PaymentInformation(from: decoder)
        object = try container.decode(String.self, forKey: .object)
        id = try container.decode(String.self, forKey: .id)
        flow = try container.decode(Flow.self, forKey: .flow)
        currency = try container.decode(Currency.self, forKey: .currency)
        amount = try container.decode(Int64.self, forKey: .amount)
    }
}


/// Parameter for creating a new `Source`
/// - seealso: Source
public struct CreateSourceParameter: Encodable {
    public let paymentInformation: PaymentInformation
    public let amount: Int64
    public let currency: Currency
    
    private enum CodingKeys: String, CodingKey {
        case amount
        case currency
    }
    
    public init(paymentInformation: PaymentInformation, amount: Int64, currency: Currency) {
        self.paymentInformation = paymentInformation
        self.amount = amount
        self.currency = currency
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amount, forKey: .amount)
        try container.encode(currency, forKey: .currency)
        try paymentInformation.encode(to: encoder)
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

