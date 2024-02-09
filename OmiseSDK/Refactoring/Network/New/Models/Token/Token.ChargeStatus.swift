import Foundation

extension TokenNew {
    public enum ChargeStatus: String, Codable {
        case failed
        case expired
        case pending
        case reversed
        case successful
        case unknown
    }
}
