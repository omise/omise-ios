import Foundation

extension SourceType {
    // TODO: Revert changes before create PR
    public static let availableByDefaultInThailand: [SourceType] = SourceType.allCases
//
//    [
//        .internetBankingBAY,
//        .internetBankingBBL,
//        .mobileBankingSCB,
//        .mobileBankingKBank,
//        .mobileBankingBAY,
//        .mobileBankingBBL,
//        .mobileBankingKTB,
//        .alipay,
//        .billPaymentTescoLotus,
//        .installmentBAY,
//        .installmentFirstChoice,
//        .installmentBBL,
//        .installmentKTC,
//        .installmentKBank,
//        .installmentSCB,
//        .installmentTTB,
//        .installmentUOB,
//        .promptPay,
//        .trueMoneyWallet,
//        .pointsCiti,
//        .shopeePayJumpApp
//    ]

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
