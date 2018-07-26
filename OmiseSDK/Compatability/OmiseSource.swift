import Foundation


/**
 Represents Omise card sources.
 - seealso: [Sources API](https://www.omise.co/sources-api)
 */
@objc(OMSSource) public class __OmiseSource: NSObject {
    private let source: Source
    
    @objc lazy public var object: String = source.object
    
    @objc lazy public var id: String = source.id
    
    
    @objc lazy public var type: String = source.paymentInformation.sourceType
    
    @objc lazy public var paymentInformation: __SourcePaymentInformation = __SourcePaymentInformation.makeSourcePaymentInformation(from: source.paymentInformation)
    
    @objc lazy public var flow: String = source.flow.rawValue
    
    
    @objc lazy public var amount: Int64 = source.amount
    
    @objc lazy public var currencyCode: String = source.currency.code
    
    
    init(source: Source) {
        self.source = source
    }
}


@objc(OMSPaymentInformation)
@objcMembers
public class __SourcePaymentInformation: NSObject {
    @objc public let type: OMSSourceTypeValue
    
    init?(type: OMSSourceTypeValue) {
        self.type = type
    }
    
    public static let alipayPayment = __SourcePaymentInformation(type: OMSSourceTypeValue.alipay)!
    public static let tescoLotusBillPaymentPayment = __SourcePaymentInformation(type: OMSSourceTypeValue.billPaymentTescoLotus)!
}

@objc(OMSInternetBankingPaymentInformation)
@objcMembers
public class __SourceInternetBankingPayment: __SourcePaymentInformation {
    public static let bayInternetBankingPayment = __SourceInternetBankingPayment(type: OMSSourceTypeValue.internetBankingBAY)!
    public static let ktbInternetBankingPayment = __SourceInternetBankingPayment(type: OMSSourceTypeValue.internetBankingKTB)!
    public static let scbInternetBankingPayment = __SourceInternetBankingPayment(type: OMSSourceTypeValue.internetBankingSCB)!
    public static let bblInternetBankingPayment = __SourceInternetBankingPayment(type: OMSSourceTypeValue.internetBankingBBL)!
    
    public override init?(type: OMSSourceTypeValue) {
        guard type.rawValue.hasPrefix(PaymentInformation.InternetBanking.paymentMethodTypePrefix) else {
            return nil
        }
        super.init(type: type)
    }
}

@objc(OMSBarcodePaymentInformation)
@objcMembers
public class __SourceBarcodePayment: __SourcePaymentInformation {}


@objc(OMSAlipayBarcodePaymentInformation)
@objcMembers
public class __SourceAlipayBarcodePayment: __SourceBarcodePayment {
    let alipayBarcodeInformation: PaymentInformation.Barcode.AlipayBarcode
    
    public init(barcode: String, storeID: String?, storeName: String?, terminalID: String?) {
        let storeInformation: PaymentInformation.Barcode.AlipayBarcode.StoreInformation?
        
        if let storeID = storeID, let storeName = storeName {
            storeInformation = PaymentInformation.Barcode.AlipayBarcode.StoreInformation(storeID: storeID, storeName: storeName)
        } else {
            storeInformation = nil
        }
        
        self.alipayBarcodeInformation = PaymentInformation.Barcode.AlipayBarcode(
            barcode: barcode, storeInformation: storeInformation, terminalID: terminalID
        )
        
        super.init(type: OMSSourceTypeValue.barcodeAlipay)!
    }
}

@objc(OMSCustomBarcodePaymentInformation)
@objcMembers
public class __SourceCustomBarcodePayment: __SourceBarcodePayment {
    let parameters: [String: Any]
    
    public init(customType: String, parameters: [String: Any]) {
        self.parameters = parameters
        super.init(type: OMSSourceTypeValue(rawValue: customType))!
    }
}

@objc(OMSInstallmentsPaymentInformation)
@objcMembers
public class __SourceInstallmentsPayment: __SourcePaymentInformation {
    public let numberOfTerms: Int
    
    public init?(type: OMSSourceTypeValue, numberOfTerms: Int) {
        guard type.rawValue.hasPrefix(PaymentInformation.Installment.paymentMethodTypePrefix) else {
            return nil
        }
        self.numberOfTerms = numberOfTerms
        super.init(type: type)
    }
    
    @objc public static func installmentBAYPayment(withNumberOfTerms numberOfTerms: Int) -> __SourceInstallmentsPayment {
        return __SourceInstallmentsPayment(type: OMSSourceTypeValue.installmentBAY, numberOfTerms: numberOfTerms)!
    }
    @objc public static func installmentFirstChoicePayment(withNumberOfTerms numberOfTerms: Int) -> __SourceInstallmentsPayment {
        return __SourceInstallmentsPayment(type: OMSSourceTypeValue.installmentFirstChoice, numberOfTerms: numberOfTerms)!
    }
    @objc public static func installmentBBLPayment(withNumberOfTerms numberOfTerms: Int) -> __SourceInstallmentsPayment {
        return __SourceInstallmentsPayment(type: OMSSourceTypeValue.installmentBBL, numberOfTerms: numberOfTerms)!
    }
    @objc public static func installmentKTCPayment(withNumberOfTerms numberOfTerms: Int) -> __SourceInstallmentsPayment {
        return __SourceInstallmentsPayment(type: OMSSourceTypeValue.installmentKTC, numberOfTerms: numberOfTerms)!
    }
    @objc public static func installmentKBankPayment(withNumberOfTerms numberOfTerms: Int) -> __SourceInstallmentsPayment {
        return __SourceInstallmentsPayment(type: OMSSourceTypeValue.installmentKBank, numberOfTerms: numberOfTerms)!
    }
    
}

@objc(OMSCustomPaymentInformation)
@objcMembers
public class __CustomSourcePayment: __SourcePaymentInformation {
    public let parameters: [String: Any]
    
    @objc public init(customType: String, parameters: [String: Any]) {
        self.parameters = parameters
        super.init(type: OMSSourceTypeValue(rawValue: customType))!
    }
}


extension PaymentInformation {
    init(from paymentInformation: __SourcePaymentInformation) {
        switch paymentInformation {
        case let value as __SourceInternetBankingPayment:
            let bank: InternetBanking
            switch value.type {
            case .internetBankingBAY:
                bank = .bay
            case .internetBankingKTB:
                bank = .ktb
            case .internetBankingSCB:
                bank = .scb
            case .internetBankingBBL:
                bank = .bbl
            case let type:
                let range = type.rawValue.range(of: PaymentInformation.InternetBanking.paymentMethodTypePrefix)!
                bank = .other(String(type.rawValue[range.upperBound...]))
            }
            self = .internetBanking(bank)
        case let value as __SourceInstallmentsPayment:
            let brand: Installment.Brand
            switch value.type {
            case .installmentBAY:
                brand = .bay
            case .installmentFirstChoice:
                brand = .firstChoice
            case .installmentBBL:
                brand = .bbl
            case .installmentKTC:
                brand = .ktc
            case .installmentKBank:
                brand = .kBank
            case let type:
                let range = type.rawValue.range(of: PaymentInformation.Installment.paymentMethodTypePrefix)!
                brand = .other(String(type.rawValue[range.upperBound...]))
            }
            self = .installment(PaymentInformation.Installment(brand: brand, numberOfTerms: value.numberOfTerms))
        case let value where value.type == OMSSourceTypeValue.alipay:
            self = .alipay
        case let value where value.type == OMSSourceTypeValue.billPaymentTescoLotus:
            self = .billPayment(PaymentInformation.BillPayment.tescoLotus)
        case let value where value.type.rawValue.hasPrefix(PaymentInformation.BillPayment.paymentMethodTypePrefix):
            let rangeOfPrefix = value.type.rawValue.range(of: PaymentInformation.BillPayment.paymentMethodTypePrefix)!
            self = .billPayment(PaymentInformation.BillPayment.other(String(value.type.rawValue[rangeOfPrefix.upperBound...])))
        case let value as __SourceAlipayBarcodePayment:
            let storeInformation: PaymentInformation.Barcode.AlipayBarcode.StoreInformation?
            if let storeID = value.alipayBarcodeInformation.storeID,
                let storeName = value.alipayBarcodeInformation.storeName {
                storeInformation = PaymentInformation.Barcode.AlipayBarcode.StoreInformation(storeID: storeID, storeName: storeName)
            } else {
                storeInformation = nil
            }

            self = .barcode(PaymentInformation.Barcode.alipay(
                PaymentInformation.Barcode.AlipayBarcode(
                    barcode: value.alipayBarcodeInformation.barcode,
                    storeInformation: storeInformation,
                    terminalID: value.alipayBarcodeInformation.terminalID)
                )
            )
        case let value as __SourceCustomBarcodePayment:
            self = .barcode(.other(value.type.rawValue, parameters: value.parameters))
        case let value as __SourceBarcodePayment:
            let rangeOfPrefix = value.type.rawValue.range(of: PaymentInformation.Barcode.paymentMethodTypePrefix)!
            self = .barcode(PaymentInformation.Barcode.other(String(value.type.rawValue[rangeOfPrefix.upperBound...]), parameters: [:]))
        case let value as __CustomSourcePayment:
            self = .other(type: value.type.rawValue, parameters: value.parameters)
        default:
            self = .other(type: paymentInformation.type.rawValue, parameters: [:])
        }
    }
}


extension __SourcePaymentInformation {
    static func makeSourcePaymentInformation(from paymentInformation: PaymentInformation) -> __SourcePaymentInformation {
        switch paymentInformation {
        case .alipay:
            return __SourcePaymentInformation.alipayPayment
            
        case .barcode(PaymentInformation.Barcode.alipay(let alipayInformation)):
            return __SourceAlipayBarcodePayment(barcode: alipayInformation.barcode, storeID: alipayInformation.storeID, storeName: alipayInformation.storeName, terminalID: alipayInformation.terminalID)
        case .barcode(PaymentInformation.Barcode.other(let type, parameters: let parameters)):
            return __SourceCustomBarcodePayment(customType: type, parameters: parameters)
            
        case .billPayment(PaymentInformation.BillPayment.tescoLotus):
            return __SourcePaymentInformation.tescoLotusBillPaymentPayment
        case .billPayment(PaymentInformation.BillPayment.other(let type)):
            return __SourcePaymentInformation.init(type: OMSSourceTypeValue(type))!
        case .internetBanking(let bank):
            switch bank {
            case .bay:
                return __SourceInternetBankingPayment.bayInternetBankingPayment
            case .ktb:
                return __SourceInternetBankingPayment.ktbInternetBankingPayment
            case .scb:
                return __SourceInternetBankingPayment.scbInternetBankingPayment
            case .bbl:
                return __SourceInternetBankingPayment.bblInternetBankingPayment
            case .other(let type) where type.hasPrefix(PaymentInformation.InternetBanking.paymentMethodTypePrefix):
                return __SourceInternetBankingPayment.init(type: OMSSourceTypeValue(type))!
            case .other(let type):
                return __CustomSourcePayment(customType: type, parameters: [:])
            }
        case .installment(let installment):
            switch installment.brand {
            case .bay:
                return __SourceInstallmentsPayment.installmentBAYPayment(withNumberOfTerms: installment.numberOfTerms)
            case .firstChoice:
                return __SourceInstallmentsPayment.installmentFirstChoicePayment(withNumberOfTerms: installment.numberOfTerms)
            case .bbl:
                return __SourceInstallmentsPayment.installmentBBLPayment(withNumberOfTerms: installment.numberOfTerms)
            case .ktc:
                return __SourceInstallmentsPayment.installmentKTCPayment(withNumberOfTerms: installment.numberOfTerms)
            case .kBank:
                return __SourceInstallmentsPayment.installmentKBankPayment(withNumberOfTerms: installment.numberOfTerms)
            case .other(let type) where type.hasPrefix(PaymentInformation.Installment.paymentMethodTypePrefix):
                return __SourceInstallmentsPayment.init(type: OMSSourceTypeValue(type), numberOfTerms: installment.numberOfTerms)!
            case .other(let type):
                return __CustomSourcePayment(customType: type, parameters: [:])
            }
        case .other(type: let type, parameters: let parameters):
            return __CustomSourcePayment(customType: type, parameters: parameters)
        }
    }
}

