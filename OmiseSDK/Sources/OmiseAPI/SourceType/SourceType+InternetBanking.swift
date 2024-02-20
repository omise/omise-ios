import Foundation

extension SourceType {
    public static var internetBanking: [SourceType] {
        [
            .internetBankingBAY,
            .internetBankingBBL
        ]
    }

    var isInternetBanking: Bool {
        Self.internetBanking.contains(self)
    }
}
