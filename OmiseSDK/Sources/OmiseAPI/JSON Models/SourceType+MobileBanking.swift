import Foundation

extension SourceType {
    public static var mobileBanking: [SourceType] {
        [
            .mobileBankingSCB,
            .mobileBankingKBank,
            .mobileBankingBAY,
            .mobileBankingBBL,
            .mobileBankingKTB,
            .mobileBankingOCBC
        ]
    }

    var isMobileBanking: Bool {
        Self.mobileBanking.contains(self)
    }
}
