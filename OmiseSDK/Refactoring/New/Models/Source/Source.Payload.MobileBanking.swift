import Foundation

extension Source.Payload {
    /// Payloads for Mobile Banking paymen methods
    public struct MobileBanking: Codable, Equatable {
        /// Source type of payment
        var sourceType: SourceType

        private enum CodingKeys: String, CodingKey {
            case sourceType = "type"
        }
    }
}
