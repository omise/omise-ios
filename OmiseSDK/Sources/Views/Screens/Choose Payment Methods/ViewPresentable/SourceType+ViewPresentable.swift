import Foundation

extension SourceType: CustomStringConvertible {
    public var description: String { localizedTitle }
}

extension SourceType: ViewPresentable {
    public var localizedTitle: String {
        localized("SourceType.\(self.rawValue)", text: title)
    }

    public var localizedSubtitle: String? {
        guard let subtitle = subtitle else { return nil }
        return localized("SourceType.\(self.rawValue).subtitle", text: subtitle)
    }

    public var title: String {
        switch self {
        case .alipay:
            return "Alipay"
        case .alipayCN:
            return "Alipay CN"
        case .alipayHK:
            return "Alipay HK"
        case .atome:
            return "Atome"
        case .barcodeAlipay:
            return "Alipay In-Store"
        case .billPaymentTescoLotus:
            return "Tesco Lotus"
        case .boost:
            return "Boost"
        case .dana:
            return "DANA"
        case .duitNowOBW:
            return "DuitNow Online Banking/Wallets"
        case .duitNowQR:
            return "DuitNow QR"
        case .eContext:
            return "" // Doesn't have specific title
        case .fpx:
            return "FPX"
        case .gcash:
            return "GCash"
        case .grabPay:
            return "Grab"
        case .grabPayRms:
            return "GrabPay"
        case .installmentBAY:
            return "Krungsri"
        case .installmentBBL:
            return "Bangkok Bank"
        case .installmentFirstChoice:
            return "Krungsri First Choice"
        case .installmentKBank:
            return "Kasikorn"
        case .installmentKTC:
            return "KTC"
        case .installmentMBB:
            return "MayBank"
        case .installmentSCB:
            return "Siam Commercial Bank"
        case .installmentTTB:
            return "TMBThanachart Bank"
        case .installmentUOB:
            return "United Overseas Bank"
        case .internetBankingBAY:
            return "Bank of Ayudhya"
        case .internetBankingBBL:
            return "Bangkok Bank"
        case .kakaoPay:
            return "Kakao Pay"
        case .maybankQRPay:
            return "Maybank QRPay"
        case .mobileBankingBAY:
            return "KMA"
        case .mobileBankingBBL:
            return "Bualuang mBanking"
        case .mobileBankingKBank:
            return "K PLUS"
        case .mobileBankingKTB:
            return "Krungthai Next"
        case .mobileBankingSCB:
            return "SCB EASY"
        case .ocbcDigital:
            return "OCBC Digital"
        case .payNow:
            return "PayNow"
        case .payPay:
            return "PayPay"
        case .pointsCiti:
            return "Pay with Citi Rewards Points"
        case .promptPay:
            return "PromptPay"
        case .rabbitLinepay:
            return "Rabbit LINE Pay"
        case .shopeePay:
            return "ShopeePay"
        case .shopeePayJumpApp:
            return "ShopeePay"
        case .touchNGo:
            return "Touch 'n Go"
        case .touchNGoAlipayPlus:
            return "TNG eWallet"
        case .trueMoneyWallet:
            return "TrueMoney Wallet"
        case .trueMoneyJumpApp:
            return "TrueMoney"
        case .weChat:
            return "WeChat Pay"
        }
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
        case .installmentBAY:
            return "BAY"
        case .installmentBBL:
            return "BBL"
        case .installmentFirstChoice:
            return "First Choice"
        case .installmentKBank:
            return "KBANK"
        case .installmentKTC:
            return "KTC"
        case .installmentMBB:
            return "FPX/maybank"
        case .installmentSCB:
            return "SCB"
        case .installmentTTB:
            return "ttb"
        case .installmentUOB:
            return "uob"
        case .internetBankingBAY:
            return "BAY"
        case .internetBankingBBL:
            return "BBL"
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
        case .pointsCiti:
            return "CitiBank"
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
