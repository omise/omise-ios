import Foundation

public enum SourceType: String, Codable {
    case alipay = "alipay"
    case alipayCN = "alipay_cn"
    case alipayHK = "alipay_hk"
    case atome = "atome"
    case barcodeAlipay = "barcode_alipay"
    case billPaymentTescoLotus = "bill_payment_tesco_lotus"
    case boost = "boost"
    case dana = "dana"
    case duitNowOBW = "duitnow_obw"
    case duitNowQR = "duitnow_qr"
    case eContext = "econtext"
    case fpx = "fpx"
    case gcash = "gcash"
    case grabPay = "grabpay"
    case grabPayRms = "grabpay_rms"
    case installmentBAY = "installment_bay"
    case installmentBBL = "installment_bbl"
    case installmentFirstChoice = "installment_first_choice"
    case installmentKBank = "installment_kbank"
    case installmentKTC = "installment_ktc"
    case installmentMBB = "installment_mbb"
    case installmentSCB = "installment_scb"
    case installmentTTB = "installment_ttb"
    case installmentUOB = "installment_uob"
    case internetBankingBAY = "internet_banking_bay"
    case internetBankingBBL = "internet_banking_bbl"
    case kakaoPay = "kakaopay"
    case maybankQRPay = "maybank_qr"
    case mobileBankingBAY = "mobile_banking_bay"
    case mobileBankingBBL = "mobile_banking_bbl"
    case mobileBankingKBank = "mobile_banking_kbank"
    case mobileBankingKTB = "mobile_banking_ktb"
    case mobileBankingOCBC = "mobile_banking_ocbc"
    case mobileBankingSCB = "mobile_banking_scb"
    case payNow = "paynow"
    case payPay = "paypay"
    case pointsCiti = "points_citi"
    case promptPay = "promptpay"
    case rabbitLinepay = "rabbit_linepay"
    case shopeePay = "shopeepay"
    case shopeePayJumpApp = "shopeepay_jumpapp"
    case touchNGo = "touch_n_go"
    case touchNGoAlipayPlus = "touch_n_go_alipay_plus"
    case trueMoney = "truemoney"
    case trueMoneyJumpApp = "truemoney_jumpapp"
    case weChat = "wechat_pay"
}

// MARK: Installment Brand
// TODO: Refactoring with PaymentInformation
extension SourceType {
    var installmentBrand: PaymentInformation.Installment.Brand? {
        switch self {
        case .installmentBAY:
            return .bay
        case .installmentMBB:
            return .mbb
        case .installmentFirstChoice:
            return .firstChoice
        case .installmentBBL:
            return .bbl
        case .installmentKTC:
            return .ktc
        case .installmentKBank:
            return .kBank
        case .installmentSCB:
            return .scb
        case .installmentTTB:
            return .ttb
        case .installmentUOB:
            return .uob
        default:
            return nil
        }
    }

    // Add Unit Test
    var isInstallment: Bool {
        installmentBrand != nil
    }
}

// MARK: Internet Banking
// TODO: Refactoring with PaymentInformation
extension SourceType {
    var internetBanking: PaymentInformation.InternetBanking? {
        switch self {
        case .internetBankingBAY:
            return .bay
        case .internetBankingBBL:
            return .bbl
        default:
            return nil
        }
    }

    var isInternetBanking: Bool {
        internetBanking != nil
    }
}

// MARK: Mobile Banking
// TODO: Refactoring with PaymentInformation
extension SourceType {
    var mobileBanking: PaymentInformation.MobileBanking? {
        switch self {
        case .mobileBankingSCB:
            return .scb
        case .mobileBankingKBank:
            return .kbank
        case .mobileBankingBAY:
            return .bay
        case .mobileBankingBBL:
            return .bbl
        case .mobileBankingKTB:
            return .ktb
        default:
            return nil
        }
    }

    var isMobileBanking: Bool {
        mobileBanking != nil
    }
}
