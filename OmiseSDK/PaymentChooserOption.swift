import Foundation
import UIKit


enum PaymentChooserOption: CaseIterable, Equatable, CustomStringConvertible {
    case alipay
    case alipayCN
    case alipayHK
    case atome
    case boost
    case citiPoints
    case conbini
    case creditCard
    case dana
    case duitNowOBW
    case duitNowQR
    case fpx
    case gcash
    case grabPay
    case grabPayRms
    case installment
    case internetBanking
    case kakaoPay
    case maybankQRPay
    case mobileBanking
    case netBanking
    case ocbcDigital
    case payEasy
    case paynow
    case payPay
    case promptpay
    case rabbitLinepay
    case shopeePay
    case shopeePayJumpApp
    case tescoLotus
    case touchNGo
    case touchNGoAlipayPlus
    case truemoney
    case truemoneyJumpApp
    case weChat

    static var alphabetical: [PaymentChooserOption] {
        PaymentChooserOption.allCases.sorted {
            $0.description.localizedCaseInsensitiveCompare($1.description) == .orderedAscending
        }
    }

    static let topList: [PaymentChooserOption] = [
        .creditCard,
        .paynow,
        .promptpay,
        .truemoney,
        .truemoneyJumpApp,
        .mobileBanking,
        .internetBanking,
        .alipay,
        .installment,
        .ocbcDigital,
        .rabbitLinepay,
        .shopeePay,
        .shopeePayJumpApp,
        .alipayCN,
        .alipayHK
    ]

    static var sorting: [PaymentChooserOption] {
        var sorted = topList
        for item in alphabetical where !sorted.contains(item) {
            sorted.append(item)
        }
        return sorted
    }

    var description: String {
        switch self {
        case .creditCard:
            return "Credit Card"
        case .installment:
            return "Installment"
        case .internetBanking:
            return "InternetBanking"
        case .mobileBanking:
            return "MobileBanking"
        case .tescoLotus:
            return "Tesco Lotus"
        case .conbini:
            return "Conbini"
        case .payEasy:
            return "PayEasy"
        case .netBanking:
            return "NetBanking"
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
        case .promptpay:
            return "PromptPay"
        case .paynow:
            return "PayNow"
        case .truemoney:
            return "TrueMoney Wallet"
        case .truemoneyJumpApp:
            return "TrueMoney"
        case .citiPoints:
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
        }
    }
    var listIcon: UIImage? {
        switch self {
        case .creditCard:
            return UIImage(named: "Card", in: .omiseSDK, compatibleWith: nil)
        case .installment:
            return UIImage(named: "Installment", in: .omiseSDK, compatibleWith: nil)
        case .internetBanking:
            return UIImage(named: "Banking", in: .omiseSDK, compatibleWith: nil)
        case .mobileBanking:
            return UIImage(named: "MobileBanking", in: .omiseSDK, compatibleWith: nil)
        case .tescoLotus:
            return UIImage(named: "Tesco", in: .omiseSDK, compatibleWith: nil)
        case .conbini:
            return UIImage(named: "Conbini", in: .omiseSDK, compatibleWith: nil)
        case .payEasy:
            return UIImage(named: "Payeasy", in: .omiseSDK, compatibleWith: nil)
        case .netBanking:
            return UIImage(named: "Netbank", in: .omiseSDK, compatibleWith: nil)
        case .alipay:
            return UIImage(named: "Alipay", in: .omiseSDK, compatibleWith: nil)
        case .alipayCN:
            return UIImage(named: "AlipayCN", in: .omiseSDK, compatibleWith: nil)
        case .alipayHK:
            return UIImage(named: "AlipayHK", in: .omiseSDK, compatibleWith: nil)
        case .atome:
            return UIImage(named: "Atome", in: .omiseSDK, compatibleWith: nil)
        case .dana:
            return UIImage(named: "dana", in: .omiseSDK, compatibleWith: nil)
        case .gcash:
            return UIImage(named: "gcash", in: .omiseSDK, compatibleWith: nil)
        case .kakaoPay:
            return UIImage(named: "kakaopay", in: .omiseSDK, compatibleWith: nil)
        case .touchNGoAlipayPlus:
            return UIImage(named: "touch-n-go", in: .omiseSDK, compatibleWith: nil)
        case .promptpay:
            return UIImage(named: "PromptPay", in: .omiseSDK, compatibleWith: nil)
        case .paynow:
            return UIImage(named: "PayNow", in: .omiseSDK, compatibleWith: nil)
        case .truemoney:
            return UIImage(named: "TrueMoney", in: .omiseSDK, compatibleWith: nil)
        case .truemoneyJumpApp:
            return UIImage(named: "TrueMoney", in: .omiseSDK, compatibleWith: nil)
        case .citiPoints:
            return UIImage(named: "CitiBank", in: .omiseSDK, compatibleWith: nil)
        case .fpx:
            return UIImage(named: "FPX", in: .omiseSDK, compatibleWith: nil)
        case .rabbitLinepay:
            return UIImage(named: "RabbitLinePay", in: .omiseSDK, compatibleWith: nil)
        case .ocbcDigital:
            return UIImage(named: "ocbc-digital", in: .omiseSDK, compatibleWith: nil)
        case .grabPay:
            return UIImage(named: "Grab", in: .omiseSDK, compatibleWith: nil)
        case .boost:
            return UIImage(named: "Boost", in: .omiseSDK, compatibleWith: nil)
        case .shopeePay:
            return UIImage(named: "Shopeepay", in: .omiseSDK, compatibleWith: nil)
        case .shopeePayJumpApp:
            return UIImage(named: "Shopeepay", in: .omiseSDK, compatibleWith: nil)
        case .maybankQRPay:
            return UIImage(named: "MAE-maybank", in: .omiseSDK, compatibleWith: nil)
        case .duitNowQR:
            return UIImage(named: "DuitNow-QR", in: .omiseSDK, compatibleWith: nil)
        case .duitNowOBW:
            return UIImage(named: "Duitnow-OBW", in: .omiseSDK, compatibleWith: nil)
        case .touchNGo:
            return UIImage(named: "touch-n-go", in: .omiseSDK, compatibleWith: nil)
        case .grabPayRms:
            return UIImage(named: "Grab", in: .omiseSDK, compatibleWith: nil)
        case .payPay:
            return UIImage(named: "PayPay", in: .omiseSDK, compatibleWith: nil)
        case .weChat:
            return UIImage(named: "wechat_pay", in: .omiseSDK, compatibleWith: nil)
        }
    }
}

