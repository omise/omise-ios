import Foundation

extension Capability.PaymentMethod {
    // TODO: Add Unit Tests to Provider
    // TODO: Add comments to Provider's properties
    public enum Provider: String, Codable, Hashable {
        case alipayPlus = "Alipay_plus"
        case rms = "RMS"
        case unknown

        public init(from decoder: Decoder) throws {
            self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
        }
    }
}
