import Foundation

extension Capability.PaymentMethod {
    /// Represents Capability.PaymentMethod.Provider JSON object for communication with Omise API
    public enum Provider: String, Hashable {
        case alipayPlus = "Alipay_plus"
        case rms = "RMS"
        case unknown
    }
}

extension Capability.PaymentMethod.Provider: Codable {
    public init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
