import Foundation

extension Source.Payload {
    /// Payloads for Thai Internet Banking paymen methods
    /// https://docs.opn.ooo/internet-banking
    public struct InternetBanking: Codable, Equatable {
        /// Source type of payment
        var sourceType: SourceType

        private enum CodingKeys: String, CodingKey {
            case sourceType = "type"
        }
    }
}
