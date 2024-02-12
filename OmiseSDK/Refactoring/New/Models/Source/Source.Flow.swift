import Foundation

extension Source {

    /// The payment flow payers need to go through to complete the payment
    ///
    /// - redirect: Payer must be redirected to external website (charge.authorize_uri) to complete payment
    /// - offline: Payer will receive payment information to complete payment offline (charge.source.references)
    /// - appRedirect: Payer must be redirected to an app (charge.authorize_uri) to complete payment
    /// - unknown: Any other unknown flow
    public enum Flow: String, Codable {
        case redirect
        case offline
        case appRedirect = "app_redirect"
        case unknown

        public init(from decoder: Decoder) throws {
            self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
        }
    }
}
