import Foundation

/// Represents Source JSON object for communication with Omise API
/// Sources are methods for accepting payments through non-credit-card channels
/// https://docs.opn.ooo/sources-api
public struct Source {
    /// The processing flow of a Source
    public let id: String
    /// Whether this is a live (true) or test (false) source
    public let isLiveMode: Bool
    /// Source amount in smallest unit of source currency
    public let amount: Int64
    /// Currency for source as three-letter ISO 4217 code
    public let currency: String
    /// The payment information of this source describes how the payment is processed
    public let paymentInformation: PaymentInformation
    /// The payment flow payers need to go through to complete the payment
    public let flow: Flow

    /// The payment flow payers need to go through to complete the payment
    public enum Flow: String, Codable {
        /// Payer must be redirected to external website (charge.authorize_uri) to complete payment
        case redirect
        /// Payer will receive payment information to complete payment offline (charge.source.references)
        case offline
        /// appRedirect: Payer must be redirected to an app (charge.authorize_uri) to complete payment
        case appRedirect = "app_redirect"
        /// Any other unknown flow
        case unknown

        /// Decodes from JSON string and uses `unknown` state as a default state if casting from string value is failed
        public init(from decoder: Decoder) throws {
            self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
        }
    }
}

extension Source: Decodable {
    /// Mapping keys to encode/decode JSON string
    private enum CodingKeys: String, CodingKey {
        case id, flow, amount, currency
        case isLiveMode = "livemode"
    }

    /// Creates Source instance from JSON String
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        flow = try container.decode(Flow.self, forKey: .flow)
        currency = try container.decode(String.self, forKey: .currency)
        amount = try container.decode(Int64.self, forKey: .amount)
        isLiveMode = try container.decode(Bool.self, forKey: .isLiveMode)
        paymentInformation = try PaymentInformation(from: decoder)
    }
}
