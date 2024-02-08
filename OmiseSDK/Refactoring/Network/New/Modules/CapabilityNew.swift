import Foundation

// TODO: Rename to Capability
// TODO: Add other properties
public struct CapabilityNew: Codable {
    public let countryCode: String
    public let paymentMethods: [CapabilityNew.PaymentMethod]
    
    private enum CodingKeys: String, CodingKey {
        case countryCode = "country"
        case paymentMethods = "payment_methods"
    }
}
