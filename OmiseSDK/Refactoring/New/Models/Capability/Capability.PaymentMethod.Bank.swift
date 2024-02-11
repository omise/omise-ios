import Foundation

extension CapabilityNew.PaymentMethod {
    // TODO: Add Unit Tests to Bank
    // TODO: Add comments to Bank's properties
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
