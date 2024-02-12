import Foundation

extension Source.Payload {
    /// Payload for `Atome App Redirection` payment method
    /// https://docs.opn.ooo/atome
    public struct Atome: Codable, Equatable {
        /// Customer mobile number with a country code (example: +66876543210 or 0876543210)
        let phoneNumber: String
        /// Customer name
        let name: String?
        /// Customer email
        let email: String?
        /// Shipping address
        let shipping: Address
        /// Billing address
        let billing: Address?
        /// Information about items included in the order
        let items: [Item]

        /// Creates a new Atome payment method payload
        ///
        /// - Parameters:
        ///   - phoneNumber: Customer mobile number
        ///   - name: Customer name
        ///   - email: Customer email
        ///   - shipping: Shipping address
        ///   - billing: Billing address
        ///   - items: Items details
        init(phoneNumber: String, name: String? = nil, email: String? = nil, shipping: Address, billing: Address, items: [Item]) {
            self.name = name
            self.email = email
            self.phoneNumber = phoneNumber
            self.shipping = shipping
            self.billing = billing
            self.items = items
        }
    }
}

extension Source.Payload.Atome {
    private enum CodingKeys: String, CodingKey {
        case name
        case email
        case phoneNumber = "phone_number"
        case shipping = "shipping"
        case billing = "billing"
        case items = "items"
    }
}
