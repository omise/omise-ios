import Foundation

// TODO: Add Unit Tests to Capability
// TODO: Add comments to CapabilityNew's properties
public struct Capability: Codable {
    public let countryCode: String
    public let paymentMethods: [Capability.PaymentMethod]
    public let banks: Set<String>

    private enum CodingKeys: String, CodingKey {
        case countryCode = "country"
        case paymentMethods = "payment_methods"
        case banks
    }
}
