import Foundation

extension Token {
    public enum ChargeStatus: String, Decodable {
        case failed
        case expired
        case pending
        case reversed
        case successful
        case unknown

        public init(from decoder: Decoder) throws {
            self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
        }
    }
}

extension Token.ChargeStatus {
    static let finalStates: [Self] = [.successful, .failed, .expired, .reversed]

    var isFinal: Bool {
        Self.finalStates.contains(self)
    }
}
