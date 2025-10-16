import Foundation

extension SourceType: CustomStringConvertible {
    public var description: String { localizedTitle }
}

extension SourceType: ViewPresentable {
    public var localizedTitle: String {
        localized("SourceType.\(self.rawValue)")
    }

    public var localizedSubtitle: String? {
        guard let subtitle = subtitle else { return nil }
        return localized("SourceType.\(self.rawValue).subtitle", text: subtitle)
    }

    public var iconName: String {
        switch self {
        case .alipay:
            return "Alipay"
        case .alipayCN:
            return "AlipayCN"
        case .alipayHK:
            return "AlipayHK"
        case .atome:
            return "Atome"
        case .applePay:
            return "ApplePay"
        case .barcodeAlipay:
            return "Alipay"
        case .billPaymentTescoLotus:
            return "Tesco"
        case .boost:
            return "Boost"
        case .dana:
            return "dana"
        case .duitNowOBW:
            return "Duitnow-OBW"
        case .duitNowQR:
            return "DuitNow-QR"
        case .eContext:
            return "" // Doesn't have specific icon
        case .fpx:
            return "FPX"
        case .gcash:
            return "gcash"
        case .grabPay:
            return "Grab"
        case .grabPayRms:
            return "Grab"
        case .installmentBAY, .installmentWhiteLabelBAY:
            return "BAY"
        case .installmentBBL, .installmentWhiteLabelBBL:
            return "BBL"
        case .installmentFirstChoice, .installmentWhiteLabelFirstChoice:
            return "First Choice"
        case .installmentKBank, .installmentWhiteLabelKBank:
            return "KBANK"
        case .installmentKTC, .installmentWhiteLabelKTC:
            return "KTC"
        case .installmentMBB:
            return "FPX/maybank"
        case .installmentSCB, .installmentWhiteLabelSCB:
            return "SCB"
        case .installmentTTB, .installmentWhiteLabelTTB:
            return "ttb"
        case .installmentUOB, .installmentWhiteLabelUOB:
            return "uob"
        case .kakaoPay:
            return "kakaopay"
        case .maybankQRPay:
            return "MAE-maybank"
        case .mobileBankingBAY:
            return "KMA"
        case .mobileBankingBBL:
            return "BBL M"
        case .mobileBankingKBank:
            return "KPlus"
        case .mobileBankingKTB:
            return "KTB Next"
        case .mobileBankingSCB:
            return "SCB"
        case .ocbcDigital:
            return "ocbc-digital"
        case .payNow:
            return "PayNow"
        case .payPay:
            return "PayPay"
        case .promptPay:
            return "PromptPay"
        case .rabbitLinepay:
            return "RabbitLinePay"
        case .shopeePay:
            return "Shopeepay"
        case .shopeePayJumpApp:
            return "Shopeepay"
        case .touchNGo:
            return "touch-n-go"
        case .touchNGoAlipayPlus:
            return "touch-n-go"
        case .trueMoneyWallet:
            return "TrueMoney"
        case .trueMoneyJumpApp:
            return "TrueMoney"
        case .weChat:
            return "wechat_pay"
        }
    }

    var accessoryIcon: Assets.Icon {
        requiresAdditionalDetails ? Assets.Icon.next : Assets.Icon.redirect
    }

    public var subtitle: String? {
        switch self {
        case .alipayCN, .alipayHK, .dana, .gcash, .kakaoPay, .touchNGo:
            return localized("SourceType.alipay.footnote")
        case .grabPay:
            return localized("SourceType.grabpay.footnote")
        default:
            return nil
        }
    }

}
