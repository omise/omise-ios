import Foundation

extension Source.Payment {
    /// Payment for Konbini, Pay-easy, and Online Banking payment method
    /// https://docs.opn.ooo/konbini-pay-easy-online-banking
    public struct EContext: Codable, Equatable {
        /// Customer name. The name cannot be longer than 10 characters
        public let name: String
        /// Customer email
        public let email: String
        /// Customer mobile number with a country code (example: +66876543210 or 0876543210)
        public let phoneNumber: String

        private enum CodingKeys: String, CodingKey {
            case name
            case email
            case phoneNumber = "phone_number"
        }
    }
}
