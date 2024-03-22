import Foundation

/// Represents Token JSON object for communication with Omise API
public struct Token {
    /// Omise ID of the token
    public let id: String
    /// Boolean indicates that if this Token is in the live mode
    public let isLiveMode: Bool
    /// Boolean indicates that if this token is already used for creating a charge already
    public var isUsed: Bool
    /// Card that is used for creating this Token
    public let card: Token.Card?
    /// Status of charge created using this token
    public let chargeStatus: ChargeStatus
}

extension Token: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case isLiveMode = "livemode"
        case isUsed = "used"
        case card
        case chargeStatus = "charge_status"
    }
}
