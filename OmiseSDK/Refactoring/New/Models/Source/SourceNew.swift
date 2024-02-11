import Foundation

// TODO: Add Unit Tests for SourceNew
/// Represents an Omise Source object
public struct SourceNew: Decodable {
    /// Omise Source ID
    public let id: String
    /// Processing Flow of this source
    public let flow: Flow
    /// Payment amount of this Source
    let amount: Int64
    /// Payment currency of this Source
    let currency: String
    /// The payment details of this source describes how the payment is processed
    let paymentInformation: SourcePayload

//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
//        try container.encode(flow.rawValue, forKey: .flow)
//        try container.encode(amount, forKey: .amount)
//        try container.encode(currency, forKey: .currency)
//        try paymentInformation.encode(to: encoder)
//    }

    private enum CodingKeys: String, CodingKey {
        case id, flow, amount, currency
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        flow = try container.decode(Flow.self, forKey: .flow)
        currency = try container.decode(String.self, forKey: .currency)
        amount = try container.decode(Int64.self, forKey: .amount)
        paymentInformation = try SourcePayload(from: decoder)
    }
}
