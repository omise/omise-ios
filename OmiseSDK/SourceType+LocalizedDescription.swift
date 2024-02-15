import Foundation

extension SourceType {
    var localizedDescription: String {
        switch self {
//        case .creditCard:
//            return "Credit Card"
        case _ where isInstallment:
            return "Installment"
        case _ where isInternetBanking:
            return "InternetBanking"
        case _ where isMobileBanking:
            return "MobileBanking"
        case .billPaymentTescoLotus:
            return "Tesco Lotus"
        case .eContext:
            return "Conbini"
//        case .payEasy:
//            return "PayEasy"
//        case .netBanking:
//            return "NetBanking"
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
            return "CitiPoints"
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
            return "DuitNow OBW"
        case .touchNGo:
            return "Touch 'n Go"
        case .grabPayRms:
            return "GrabPay"
        case .payPay:
            return "PayPay"
        case .weChat:
            return "WeChat Pay"
        default:
            return self.rawValue.localizedUppercase
        }
    }
}
