import Foundation

extension PaymentChooserOption {
    // swiftlint:disable:next function_body_length
    static func paymentOptions(for sourceType: SourceType) -> [PaymentChooserOption] {
        switch sourceType {
        case .trueMoneyWallet:
            return [.truemoney]
        case .trueMoneyJumpApp:
            return [.truemoneyJumpApp]
        case .installmentFirstChoice, .installmentMBB, .installmentKBank, .installmentKTC,
                .installmentBBL, .installmentBAY, .installmentSCB, .installmentTTB, .installmentUOB:
            return [.installment]
        case .billPaymentTescoLotus:
            return [.tescoLotus]
        case .eContext:
            return [.conbini, .payEasy, .netBanking]
        case .alipay:
            return [.alipay]
        case .alipayCN:
            return [.alipayCN]
        case .alipayHK:
            return [.alipayHK]
        case .atome:
            return [.atome]
        case .dana:
            return [.dana]
        case .gcash:
            return [.gcash]
        case .kakaoPay:
            return [.kakaoPay]
        case .touchNGoAlipayPlus:
            return [.touchNGoAlipayPlus]
        case .touchNGo:
            return [.touchNGo]
        case .internetBankingBAY, .internetBankingBBL:
            return [.internetBanking]
        case .mobileBankingSCB, .mobileBankingKBank, .mobileBankingBAY, .mobileBankingBBL, .mobileBankingKTB:
            return [.mobileBanking]
        case .payNow:
            return [.paynow]
        case .promptPay:
            return [.promptpay]
        case .pointsCiti:
            return [.citiPoints]
        case .barcodeAlipay:
            return []
        case .fpx:
            return [.fpx]
        case .rabbitLinepay:
            return [.rabbitLinepay]
        case .ocbcDigital:
            return [.ocbcDigital]
        case .grabPay:
            return [.grabPay]
        case .grabPayRms:
            return [.grabPayRms]
        case .boost:
            return [.boost]
        case .shopeePay:
            return [.shopeePay]
        case .shopeePayJumpApp:
            return [.shopeePayJumpApp]
        case .maybankQRPay:
            return [.maybankQRPay]
        case .duitNowQR:
            return [.duitNowQR]
        case .duitNowOBW:
            return [.duitNowOBW]
        case .payPay:
            return [.payPay]
        case .weChat:
            return [.weChat]
        }
    }
}

