import Foundation

extension SourceType: CustomStringConvertible {
    public var description: String { localizedTitle }
}

extension SourceType: ListItemProtocol {
    public var localizedTitle: String {
        localized("SourceType.\(self.rawValue).title",
                  text: title,
                  "Localized title for given payment method")
    }

    public var title: String {
        switch self {
        case .billPaymentTescoLotus:
            return "Tesco Lotus"
        case .eContext:
            return "Conbini"
        case .alipay:
            return "Alipay"
        case .alipayCN:
            return "Alipay CN"
        case .alipayHK:
            return "Alipay HK"
        case .atome:
            return "Atome"
        case .dana:
            return "DANA"
        case .gcash:
            return "GCash"
        case .kakaoPay:
            return "Kakao Pay"
        case .touchNGoAlipayPlus:
            return "TNG eWallet"
        case .promptPay:
            return "PromptPay"
        case .payNow:
            return "PayNow"
        case .trueMoneyWallet:
            return "TrueMoney Wallet"
        case .trueMoneyJumpApp:
            return "TrueMoney"
        case .pointsCiti:
            return "Pay with Citi Rewards Points"
        case .fpx:
            return "FPX"
        case .rabbitLinepay:
            return "Rabbit LINE Pay"
        case .ocbcDigital:
            return "OCBC Digital"
        case .grabPay:
            return "Grab"
        case .boost:
            return "Boost"
        case .shopeePay:
            return "ShopeePay"
        case .shopeePayJumpApp:
            return "ShopeePay"
        case .maybankQRPay:
            return "Maybank QRPay"
        case .duitNowQR:
            return "DuitNow QR"
        case .duitNowOBW:
            return "DuitNow Online Banking/Wallets"
        case .touchNGo:
            return "Touch 'n Go"
        case .grabPayRms:
            return "GrabPay"
        case .payPay:
            return "PayPay"
        case .weChat:
            return "WeChat Pay"
        case .barcodeAlipay:
            return "Alipay In-Store"

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
        }
    }

    public var iconName: String {
        switch self {
        case .billPaymentTescoLotus:
            return "Tesco"
        case .eContext:
            return "Conbini"
        case .alipay:
            return "Alipay"
        case .alipayCN:
            return "AlipayCN"
        case .alipayHK:
            return "AlipayHK"
        case .atome:
            return "Atome"
        case .dana:
            return "dana"
        case .gcash:
            return "gcash"
        case .kakaoPay:
            return "kakaopay"
        case .touchNGoAlipayPlus:
            return "touch-n-go"
        case .promptPay:
            return "PromptPay"
        case .payNow:
            return "PayNow"
        case .trueMoneyWallet:
            return "TrueMoney"
        case .trueMoneyJumpApp:
            return "TrueMoney"
        case .pointsCiti:
            return "CitiBank"
        case .fpx:
            return "FPX"
        case .rabbitLinepay:
            return "RabbitLinePay"
        case .ocbcDigital:
            return "ocbc-digital"
        case .grabPay:
            return "Grab"
        case .boost:
            return "Boost"
        case .shopeePay:
            return "Shopeepay"
        case .shopeePayJumpApp:
            return "Shopeepay"
        case .maybankQRPay:
            return "MAE-maybank"
        case .duitNowQR:
            return "DuitNow-QR"
        case .duitNowOBW:
            return "Duitnow-OBW"
        case .touchNGo:
            return "touch-n-go"
        case .grabPayRms:
            return "Grab"
        case .payPay:
            return "PayPay"
        case .weChat:
            return "wechat_pay"
        case .barcodeAlipay:
            return "Alipay"

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
        }
    }

}
