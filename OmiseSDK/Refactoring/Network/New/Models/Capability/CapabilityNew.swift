import Foundation

// TODO: Rename to Capability
// TODO: Add comments for public properties and functions
public struct CapabilityNew: Codable {
    public let countryCode: String
    public let paymentMethods: [CapabilityNew.PaymentMethod]
    public let banks: Set<String>

    private enum CodingKeys: String, CodingKey {
        case countryCode = "country"
        case paymentMethods = "payment_methods"
        case banks
    }
}
