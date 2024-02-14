import Foundation

extension Capability.PaymentMethod {
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
