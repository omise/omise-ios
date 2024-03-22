import Foundation

extension Capability.PaymentMethod {
    /// Represents Capability.PaymentMethod.Bank JSON object for communication with Omise API
    public struct Bank: Hashable {
        public let name: String
        public let code: String
        public let isActive: Bool
    }
}

extension Capability.PaymentMethod.Bank: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case code
        case isActive = "active"
    }
}
