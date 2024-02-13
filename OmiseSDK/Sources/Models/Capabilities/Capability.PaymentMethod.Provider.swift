import Foundation

extension Capability.PaymentMethod {
    public enum Provider: String, Codable, Hashable {
        case alipayPlus = "Alipay_plus"
        case rms = "RMS"
        case unknown

        public init(from decoder: Decoder) throws {
            self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
        }
    }
}
