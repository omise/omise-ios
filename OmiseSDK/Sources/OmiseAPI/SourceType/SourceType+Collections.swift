import Foundation

extension SourceType {
    public static let availableByDefaultInThailand: [SourceType] =
    [
        .internetBankingBAY,
        .internetBankingBBL,
        .mobileBankingSCB,
        .mobileBankingKBank,
        .mobileBankingBAY,
        .mobileBankingBBL,
        .mobileBankingKTB,
        .alipay,
        .billPaymentTescoLotus,
        .installmentBAY,
        .installmentFirstChoice,
        .installmentBBL,
        .installmentKTC,
        .installmentKBank,
        .installmentSCB,
        .installmentTTB,
        .installmentUOB,
        .promptPay,
        .trueMoneyWallet,
        .shopeePayJumpApp
    ]

    public static let availableByDefaultInJapan: [SourceType] = [
        .eContext,
        .payPay
    ]

    public static let availableByDefaultSingapore: [SourceType] = [
        .payNow,
        .shopeePayJumpApp
    ]

    public static let availableByDefaultMalaysia: [SourceType] = [
        .fpx,
        .installmentMBB,
        .touchNGo,
        .grabPay,
        .boost,
        .shopeePay,
        .shopeePayJumpApp,
        .maybankQRPay,
        .duitNowQR,
        .duitNowOBW
    ]
}
