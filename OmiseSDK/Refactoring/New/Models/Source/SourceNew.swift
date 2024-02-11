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
    let details: SourcePayload

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(flow.rawValue, forKey: .flow)
        try container.encode(amount, forKey: .amount)
        try container.encode(currency, forKey: .currency)
        try details.encode(to: encoder)
    }
}
