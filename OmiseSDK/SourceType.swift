import Foundation

enum SourceType {
    case internetBankingBAY
    case internetBankingKTB
    case internetBankingSCB
    case internetBankingBBL
    
    case installmentBAY
    case installmentFirstChoice
    case installmentBBL
    case installmentKTC
    case installmentKBank
    case installmentSCB
    
    case alipay
    case barcodeAlipay
    case billPaymentTescoLotus
    case econtext
    case promptPay
    case paynow
    case truemoney
    case pointsCiti
    
    var value: String {
        switch self {
        case .internetBankingBAY:
            return "internet_banking_bay"
        case .internetBankingKTB:
            return "internet_banking_ktb"
        case .internetBankingSCB:
            return "internet_banking_scb"
        case .internetBankingBBL:
            return "internet_banking_bbl"
            
        case .installmentBAY:
            return "installment_bay"
        case .installmentFirstChoice:
            return "installment_first_choice"
        case .installmentBBL:
            return "installment_bbl"
        case .installmentKTC:
            return "installment_ktc"
        case .installmentKBank:
            return "installment_kbank"
        case .installmentSCB:
            return "installment_scb"
        
        case .alipay:
            return "alipay"
        case .barcodeAlipay:
            return "barcode_alipay"
        case .billPaymentTescoLotus:
            return "bill_payment_tesco_lotus"
        case .econtext:
            return "econtext"
        case .promptPay:
            return "promptpay"
        case .paynow:
            return "paynow"
        case .truemoney:
            return "truemoney"
        case .pointsCiti:
            return "points_citi"
        }
    }
    
    var prefix: String {
        switch self {
        case .internetBankingBAY, .internetBankingKTB, .internetBankingSCB, .internetBankingBBL:
            return "internet_banking"
        case .installmentBAY, .installmentFirstChoice, .installmentBBL, .installmentKTC, .installmentKBank, .installmentSCB:
            return "installment"
        case .alipay:
            return "alipay"
        case .barcodeAlipay:
            return "barcode"
        case .billPaymentTescoLotus:
            return "bill_payment"
        case .econtext:
            return "econtext"
        case .promptPay:
            return "promptpay"
        case .paynow:
            return "paynow"
        case .truemoney:
            return "truemoney"
        case .pointsCiti:
            return "points"
        }
    }
}
