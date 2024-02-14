import Foundation

extension PaymentInformation {
    /// Payloads for Installment payment methods
    /// https://docs.opn.ooo/installment-payments
    public struct Installment: Equatable {
        /// Valid installment term length in months
        let installmentTerm: Int
        /// Whether customer or merchant absorbs interest. true when merchant absorbs interest
        let zeroInterestInstallments: Bool?
        // swiftlint:disable:previous discouraged_optional_boolean
        /// Source type of payment
        var sourceType: SourceType
    }
}

/// Encoding/decoding JSON string
extension PaymentInformation.Installment: Codable {
    private enum CodingKeys: String, CodingKey {
        case sourceType = "type"
        case installmentTerm = "installment_term"
        case zeroInterestInstallments = "zero_interest_installments"
    }
}

extension PaymentInformation.Installment {
    /// List of sourceTypes belongs to Installment payment type
    public static var sourceTypes: [SourceType] {
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

    /// Available Installments terms (months) for given sourceType
    public static func availableTerms(for sourceType: SourceType) -> [Int] {
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
