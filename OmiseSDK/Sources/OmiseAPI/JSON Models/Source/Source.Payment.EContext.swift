import Foundation

extension Source.Payment {
    /// Payment for Konbini, Pay-easy, and Online Banking payment method
    /// https://docs.omise.co/konbini-pay-easy-online-banking
    public struct EContext: Equatable {
        /// Customer name. The name cannot be longer than 10 characters
        public let name: String
        /// Customer email
        public let email: String
        /// Customer mobile number with a country code (example: +66876543210 or 0876543210)
        public let phoneNumber: String
    }
}

extension Source.Payment.EContext: SourceTypeContainerProtocol {
    /// Source payment method identifier
    static let sourceType: SourceType = .eContext
    var sourceType: SourceType { Self.sourceType }
}

/// Encoding/decoding JSON string
extension Source.Payment.EContext: Codable {
    private enum CodingKeys: String, CodingKey {
        case name
        case email
        case phoneNumber = "phone_number"
    }
}
