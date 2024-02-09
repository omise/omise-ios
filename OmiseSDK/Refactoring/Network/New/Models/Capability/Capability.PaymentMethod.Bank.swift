import Foundation

// TODO: Add comments for public properties and functions
extension CapabilityNew.PaymentMethod {
    public struct Bank: Codable, Hashable {
        public let name: String
        public let code: String
        public let isActive: Bool

        enum CodingKeys: String, CodingKey {
            case name
            case code
            case isActive = "active"
        }
    }
}
