import Foundation

extension CapabilityNew.PaymentMethod {
    // TODO: Add Unit Tests to Provider
    // TODO: Add comments to Provider's properties
    enum Provider: String, Codable, Hashable {
        case alipayPlus = "Alipay_plus"
        case rms = "RMS"
        case unknown

        init(from decoder: Decoder) throws {
            self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
        }
    }
}
