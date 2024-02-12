import Foundation

extension Source.Payload {
    /// Payloads for Installment payment methods
    /// https://docs.opn.ooo/installment-payments
    public struct Installment: Codable, Equatable {
        /// Valid installment term length in months
        let installmentTerm: String
        /// Whether customer or merchant absorbs interest. true when merchant absorbs interest
        let zeroInterestInstallments: String?
        /// Source type of payment
        var sourceType: SourceType

        private enum CodingKeys: String, CodingKey {
            case installmentTerm = "installment_term"
            case zeroInterestInstallments = "zero_interest_installments"
            case sourceType = "type"
        }
    }
}

extension Source.Payload.Installment: SourcePayloadGroupProtocol {
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

/*
{"phone_number":null,"email":null,"platform_type":"IOS","amount":500000,"shipping":null,"items":null,"installment_term":9,"currency":"THB","name":null,"type":"installment_scb"}
*/
