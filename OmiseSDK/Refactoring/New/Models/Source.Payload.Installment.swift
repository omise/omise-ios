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

    static func availableTerms(for sourceType: SourceType) -> [Int] {
        switch sourceType {
        case .installmentBAY:
            return [ 3, 4, 6, 9, 10 ]
        case .installmentFirstChoice:
            return [ 3, 4, 6, 9, 10, 12, 18, 24, 36 ]
        case .installmentBBL:
            return [ 4, 6, 8, 9, 10 ]
        case .installmentMBB:
            return [ 6, 12, 18, 24 ]
        case .installmentKTC:
            return [ 3, 4, 5, 6, 7, 8, 9, 10 ]
        case .installmentKBank:
            return [ 3, 4, 6, 10 ]
        case .installmentSCB:
            return [ 3, 4, 6, 9, 10 ]
        case .installmentTTB:
            return [ 3, 4, 6, 10, 12 ]
        case .installmentUOB:
            return [ 3, 4, 6, 10 ]
        default:
            return []
        }
    }
}
