import Foundation

extension Source.Payload {
    /// Payload for Malaysia FPX payment method
    /// https://docs.opn.ooo/fpx
    public struct FPX: Codable, Equatable {
        let name: String
        let val: String
    }
}
