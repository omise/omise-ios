import Foundation

extension SourceType {
    public static var installments: [SourceType] {
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
        ] + whiteLabelInstallments
    }

    public static var whiteLabelInstallments: [SourceType] {
        [
            .installmentWhiteLabelKTC,
            .installmentWhiteLabelKBank,
            .installmentWhiteLabelSCB,
            .installmentWhiteLabelBBL,
            .installmentWhiteLabelBAY,
            .installmentWhiteLabelFirstChoice,
            .installmentWhiteLabelTTB
        ]
    }

    var isInstallment: Bool {
        Self.installments.contains(self)
    }

    var isWhiteLabelInstallment: Bool {
        Self.whiteLabelInstallments.contains(self)
    }
}
