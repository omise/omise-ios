import Foundation

extension PaymentInformation {
    /// Payment for `Atome App Redirection` payment method
    /// https://docs.opn.ooo/atome
    public struct Atome: Equatable {
        /// Customer mobile number with a country code (example: +66876543210 or 0876543210)
        public let phoneNumber: String
        /// Customer name
        public let name: String?
        /// Customer email
        public let email: String?
        /// Shipping address
        public let shipping: PaymentInformation.Address
        /// Billing address
        public let billing: PaymentInformation.Address?
        /// Information about items included in the order
        public let items: [PaymentInformation.Item]

        /// Creates a new Atome payment method payload
        ///
        /// - Parameters:
        ///   - phoneNumber: Customer mobile number
        ///   - name: Customer name
        ///   - email: Customer email
        ///   - shipping: Shipping address
        ///   - billing: Billing address
        ///   - items: Items details
        public init(phoneNumber: String, name: String? = nil, email: String? = nil, shipping: Address, billing: PaymentInformation.Address?, items: [PaymentInformation.Item]) {
            self.name = name
            self.email = email
            self.phoneNumber = phoneNumber
            self.shipping = shipping
            self.billing = billing
            self.items = items
        }
    }
}

extension PaymentInformation.Atome: SourceTypeContainerProtocol {
    /// Payment method identifier
    public static let sourceType: SourceType = .atome
    public var sourceType: SourceType { Self.sourceType }
}

/// Encoding/decoding JSON string
extension PaymentInformation.Atome: Codable {
    private enum CodingKeys: String, CodingKey {
        case name
        case email
        case phoneNumber = "phone_number"
        case shipping = "shipping"
        case billing = "billing"
        case items = "items"
    }
}
