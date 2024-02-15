import Foundation

extension SourceType {
    public static var internetBanking: [SourceType] {
        [
            .internetBankingBAY,
            .internetBankingBAY
        ]
    }

    var isInternetBanking: Bool {
        Self.internetBanking.contains(self)
    }
}
