import Foundation

extension Source.Payload {
    /// Payloads for Installment payment methods
    /// https://docs.opn.ooo/installment-payments
    public struct Installment: Codable, Equatable {
        /// Valid installment term length in months
        let installmentTerm: Int
        /// Whether customer or merchant absorbs interest. true when merchant absorbs interest
        let zeroInterestInstallments: Bool?
        // swiftlint:disable:previous discouraged_optional_boolean

        /// Source type of payment
        var sourceType: SourceType

        private enum CodingKeys: String, CodingKey {
            case installmentTerm = "installment_term"
            case zeroInterestInstallments = "zero_interest_installments"
            case sourceType = "type"
        }
    }
}

extension Source.Payload.Installment {
    static var sourceTypes: [SourceType] {
        [
            .installmentBAY,
            .installmentBBL,
            .installmentFirstChoice,
            .installmentKBank,
            .installmentKTC,
            .installmentMBB,
            .installmentSCB,
            .installmentTTB,
            .installmentUOB
        ]
    }
}
