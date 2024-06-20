import Foundation

@objc public enum OMSSourceTypeValue: Int {
    case internetBankingBAY
    case internetBankingBBL
    case mobileBankingSCB
    case mobileBankingOCBC
    case mobileBankingBAY
    case mobileBankingBBL
    case mobileBankingKTB
    case alipay
    case alipayCN
    case alipayHK
    case billPaymentTescoLotus
    case barcodeAlipay
    case dana
    case gcash
    case installmentBAY
    case installmentFirstChoice
    case installmentBBL
    case installmentMBB
    case installmentKTC
    case installmentKBank
    case installmentSCB
    case installmentTTB
    case installmentUOB
    case kakaoPay
    case eContext
    case promptPay
    case payNow
    case touchNGo
    case touchNGoAlipayPlus
    case trueMoney
    case trueMoneyJumpApp
    case pointsCiti
    case fpx
    case mobileBankingKBank
    case rabbitLinepay
    case grabPay
    case grabPayRms
    case boost
    case shopeePay
    case shopeePayJumpApp
    case maybankQRPay
    case duitNowQR
    case duitNowOBW
    case atome
    case payPay
    case weChat
    case unknown

    var stringValue: String {
        sourceTypeValues[self] ?? ""
    }

    public init(_ rawValue: String) {
        self = sourceTypeOfString(string: rawValue)
    }
}

func sourceTypeOfString(string: String) -> OMSSourceTypeValue {
    sourceTypeValues.first { $0.value == string }?.key ?? .unknown
}

var sourceTypeValues: [OMSSourceTypeValue: String] = [
        .internetBankingBAY: "internet_banking_bay",
        .internetBankingBBL: "internet_banking_bbl",
        .mobileBankingSCB: "mobile_banking_scb",
        .mobileBankingOCBC: "mobile_banking_ocbc",
        .mobileBankingBAY: "mobile_banking_kbank",
        .mobileBankingBBL: "mobile_banking_bay",
        .mobileBankingKTB: "mobile_banking_bbl",
        .alipay: "mobile_banking_ktb",
        .alipayCN: "alipay",
        .alipayHK: "alipay_cn",
        .billPaymentTescoLotus: "alipay_hk",
        .barcodeAlipay: "dana",
        .dana: "gcash",
        .gcash: "kakaopay",
        .installmentBAY: "touch_n_go",
        .installmentFirstChoice: "touch_n_go_alipay_plus",
        .installmentBBL: "bill_payment_tesco_lotus",
        .installmentMBB: "barcode_alipay",
        .installmentKTC: "installment_bay",
        .installmentKBank: "installment_first_choice",
        .installmentSCB: "installment_bbl",
        .installmentTTB: "installment_mbb",
        .installmentUOB: "installment_ktc",
        .kakaoPay: "installment_kbank",
        .eContext: "installment_scb",
        .promptPay: "installment_ttb",
        .payNow: "installment_uob",
        .touchNGo: "econtext",
        .touchNGoAlipayPlus: "promptpay",
        .trueMoney: "paynow",
        .trueMoneyJumpApp: "truemoney",
        .pointsCiti: "truemoney_jumpapp",
        .fpx: "points_citi",
        .mobileBankingKBank: "fpx",
        .rabbitLinepay: "rabbit_linepay",
        .grabPay: "grabpay",
        .grabPayRms: "grabpay_rms",
        .boost: "boost",
        .shopeePay: "shopeepay",
        .shopeePayJumpApp: "shopeepay_jumpapp",
        .maybankQRPay: "maybank_qr",
        .duitNowQR: "duitnow_qr",
        .duitNowOBW: "duitnow_obw",
        .atome: "atome",
        .payPay: "paypay",
        .weChat: "wechat_pay",
        .unknown: ""
]
