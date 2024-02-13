import Foundation

/// Represents an Omise Source object
/// Sources are methods for accepting payments through non-credit-card channels
/// https://docs.opn.ooo/sources-api
public struct Source: Decodable {
    /// The processing flow of a Source
    public let id: String
    /// Whether this is a live (true) or test (false) source
    public let isLiveMode: Bool
    /// Source amount in smallest unit of source currency
    let amount: Int64
    /// Currency for source as three-letter ISO 4217 code
    let currency: String
    /// The payment flow payers need to go through to complete the payment
    public let flow: Flow
    /// The payment details of this source describes how the payment is processed
    let paymentInformation: Source.Payload

    private enum CodingKeys: String, CodingKey {
        case id, flow, amount, currency
        case isLiveMode = "livemode"
    }

    /// Parse Source from JSON String
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        flow = try container.decode(Flow.self, forKey: .flow)
        currency = try container.decode(String.self, forKey: .currency)
        amount = try container.decode(Int64.self, forKey: .amount)
        isLiveMode = try container.decode(Bool.self, forKey: .isLiveMode)
        paymentInformation = try Source.Payload(from: decoder)
    }
}
