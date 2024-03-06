import Foundation

extension SourceType {
    public static var mobileBanking: [SourceType] {
        [
            .mobileBankingSCB,
            .mobileBankingKBank,
            .mobileBankingBAY,
            .mobileBankingBBL,
            .mobileBankingKTB
        ]
    }

    var isMobileBanking: Bool {
        Self.mobileBanking.contains(self)
    }
}
