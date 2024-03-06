import Foundation

extension Token {
    /// Represents Token.ChargeStatus JSON object for communication with Omise API
    public enum ChargeStatus: String {
        case failed
        case expired
        case pending
        case reversed
        case successful
        case unknown

        public static let finalStates: [Self] = [.successful, .failed, .expired, .reversed]
        public var isFinal: Bool { Self.finalStates.contains(self) }
    }
}

extension Token.ChargeStatus: Decodable {
    /// Creates a new Token.ChargeStatus from JSON String
    public init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
