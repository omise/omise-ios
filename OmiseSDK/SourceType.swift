import Foundation

public enum SourceType {
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
    case promptpay
    case paynow
    case truemoney
    case pointsCiti
    
    case other(value: String)
    
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
        case .promptpay:
            return "promptpay"
        case .paynow:
            return "paynow"
        case .truemoney:
            return "truemoney"
        case .pointsCiti:
            return "points_citi"
        case .other(let value):
            return value
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
        case .promptpay:
            return "promptpay"
        case .paynow:
            return "paynow"
        case .truemoney:
            return "truemoney"
        case .pointsCiti:
            return "points"
        case .other:
            return ""
        }
    }
    
    init(_ value: String) {
        switch value {
        case SourceType.internetBankingBAY.value:
            self = .internetBankingBAY
        case SourceType.internetBankingKTB.value:
            self = .internetBankingKTB
        case SourceType.internetBankingSCB.value:
            self = .internetBankingSCB
        case SourceType.internetBankingBBL.value:
            self = .internetBankingBBL
            
        case SourceType.installmentBAY.value:
            self = .installmentBAY
        case SourceType.installmentFirstChoice.value:
            self = .installmentFirstChoice
        case SourceType.installmentBBL.value:
            self = .installmentBBL
        case SourceType.installmentKTC.value:
            self = .installmentKTC
        case SourceType.installmentKBank.value:
            self = .installmentKBank
        case SourceType.installmentSCB.value:
            self = .installmentSCB
            
        case SourceType.alipay.value:
            self = .alipay
        case SourceType.barcodeAlipay.value:
            self = .barcodeAlipay
        case SourceType.billPaymentTescoLotus.value:
            self = .billPaymentTescoLotus
        case SourceType.econtext.value:
            self = .econtext
        case SourceType.promptpay.value:
            self = .promptpay
        case SourceType.paynow.value:
            self = .paynow
        case SourceType.truemoney.value:
            self = .truemoney
        case SourceType.pointsCiti.value:
            self = .pointsCiti
            
        default:
            self = .other(value: value)
        }
    }
}

extension SourceType: Hashable { }

extension SourceType {
    var installmentBrand: PaymentInformation.Installment.Brand? {
        switch self {
        case .installmentBAY:
            return .bay
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
        default:
            return nil
        }
    }
    
    var isInstallmentSource: Bool {
        switch self {
        case .installmentBAY, .installmentFirstChoice, .installmentBBL, .installmentKTC, .installmentKBank, .installmentSCB:
            return true
        default:
            return false
        }
        
    }
    
    var internetBankingSource: PaymentInformation.InternetBanking? {
        switch self {
        case .internetBankingBAY:
            return .bay
        case .internetBankingKTB:
            return .ktb
        case .internetBankingSCB:
            return .scb
        case .internetBankingBBL:
            return .bbl
        default:
            return nil
        }
    }
    
    var isInternetBankingSource: Bool {
        switch self {
        case .internetBankingBAY, .internetBankingKTB, .internetBankingSCB, .internetBankingBBL:
            return true
        default:
            return false
        }
    }
}
