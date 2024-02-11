import Foundation

// TODO: Add Unit Tests for SourceNew
/// Represents an Omise Source object
public struct SourceNew: Decodable {
    /// Omise Source ID
    public let id: String
    /// Processing Flow of this source
    public let flow: Flow
    /// Boolean indicates that if this Token is in the live mode
    public let isLiveMode: Bool
    /// Payment amount of this Source
    let amount: Int64
    /// Payment currency of this Source
    let currency: String
    /// The payment details of this source describes how the payment is processed
    let paymentInformation: SourcePayload

    private enum CodingKeys: String, CodingKey {
        case id, flow, amount, currency
        case isLiveMode = "livemode"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        flow = try container.decode(Flow.self, forKey: .flow)
        currency = try container.decode(String.self, forKey: .currency)
        amount = try container.decode(Int64.self, forKey: .amount)
        isLiveMode = try container.decode(Bool.self, forKey: .isLiveMode)
        paymentInformation = try SourcePayload(from: decoder)
    }
}
