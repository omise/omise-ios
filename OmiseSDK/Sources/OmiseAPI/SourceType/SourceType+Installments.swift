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
        ]
    }

    var isInstallment: Bool {
        Self.installments.contains(self)
    }
}
