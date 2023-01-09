// swiftlint:disable file_length type_name force_unwrapping

import Foundation

/**
 Represents Omise card sources.
 - seealso: [Sources API](https://www.omise.co/sources-api)
 */
@objc(OMSSource) public class __OmiseSource: NSObject {
    private let source: Source

    @objc public lazy var object: String = source.object

    /// Omise Source ID
    @objc public lazy var sourcdID: String = source.id

    /// Omise Source Type value using in the Omise API
    @objc public lazy var type: String = source.paymentInformation.sourceType

    /// The payment information of this source describes how the payment is processed
    @objc public lazy var paymentInformation = __SourcePaymentInformation.makeSourcePaymentInformation(from: source.paymentInformation)

    /// Processing Flow of this source
    @objc public lazy var flow: String = source.flow.rawValue

    /// Payment amount of this Source
    @objc public lazy var amount: Int64 = source.amount

    /// Payment currency of this Source
    @objc public lazy var currencyCode: String = source.currency.code

    init(source: Source) {
        self.source = source
    }
}

/// Based type of the Source Payment Information type
@objc(OMSPaymentInformation)
@objcMembers
public class __SourcePaymentInformation: NSObject {
    public let type: OMSSourceTypeValue

    init?(type: OMSSourceTypeValue) {
        self.type = type
    }

    /// Payment Information for an Alipay Payment
    public static let alipayPayment = __SourcePaymentInformation(type: OMSSourceTypeValue.alipay)!

    /// Payment Information for an Alipay+ CN Wallet Payment
    public static let alipayCNPayment = __SourcePaymentInformation(type: OMSSourceTypeValue.alipayCN)!

    /// Payment Information for an Alipay+ HK Wallet Payment
    public static let alipayHKPayment = __SourcePaymentInformation(type: OMSSourceTypeValue.alipayHK)!

    /// Payment Information for an Alipay+ DANA Wallet Payment
    public static let danaPayment = __SourcePaymentInformation(type: OMSSourceTypeValue.dana)!

    /// Payment Information for an Alipay+ GCash Wallet Payment
    public static let gcashPayment = __SourcePaymentInformation(type: OMSSourceTypeValue.gcash)!

    /// Payment Information for an Alipay+ KakaoPay Wallet Payment
    public static let kakaoPayPayment = __SourcePaymentInformation(type: OMSSourceTypeValue.kakaoPay)!

    /// Payment Information for an Touch N Go Wallet Payment
    public static let touchNGoPayment = __SourcePaymentInformation(type: OMSSourceTypeValue.touchNGo)!

    /// Payment Information for a Lotus's Bill Payment Payment
    public static let tescoLotusBillPaymentPayment = __SourcePaymentInformation(type: OMSSourceTypeValue.billPaymentTescoLotus)!

    /// Payment Information for an PromptPay Payment
    public static let promptPayPayment = __SourcePaymentInformation(type: OMSSourceTypeValue.promptPay)!

    /// Payment Information for an PayNow Payment
    public static let payNowPayment = __SourcePaymentInformation(type: OMSSourceTypeValue.promptPay)!
    
    /// Payment Information for an Rabbit LINE Pay Payment
    public static let rabbitLinepayPayment = __SourcePaymentInformation(type: OMSSourceTypeValue.rabbitLinepay)!
    
    /// Payment Information for an OCBC Pay Anyone
    public static let ocbcPaoPayment = __SourcePaymentInformation(type: OMSSourceTypeValue.mobileBankingOCBCPAO)!

    /// Payment Information for a GrabPay Payment
    public static let grabPayPayment = __SourcePaymentInformation(type: OMSSourceTypeValue.grabPay)!

    /// Payment Information for an Boost
    public static let boostPayment = __SourcePaymentInformation(type: OMSSourceTypeValue.boost)!

    /// Payment Information for an ShopeePay
    public static let shopeePayPayment = __SourcePaymentInformation(type: OMSSourceTypeValue.shopeePay)!
    
    /// Payment Information for an ShopeePay Jump App
    public static let shopeePayJumpAppPayment = __SourcePaymentInformation(type: OMSSourceTypeValue.shopeePayJumpApp)!

    /// Payment Information for an Maybank QRPay
    public static let maybankQRPayPayment = __SourcePaymentInformation(type: OMSSourceTypeValue.maybankQRPay)!

    /// Payment Information for an DuitNow QR
    public static let duitNowQRPayment = __SourcePaymentInformation(type: OMSSourceTypeValue.duitNowQR)!

    /// Payment Information for an DuitNow OBW
    public static let duitNowOBWPayment = __SourcePaymentInformation(type: OMSSourceTypeValue.duitNowOBW)!
}

/// Internet Bankning Source Payment Information
@objc(OMSInternetBankingPaymentInformation)
@objcMembers
public class __SourceInternetBankingPayment: __SourcePaymentInformation {

    /// Payment Information for a BAY Internet Banking Payment
    public static let bayInternetBankingPayment = __SourceInternetBankingPayment(type: OMSSourceTypeValue.internetBankingBAY)!
    /// Payment Information for a KTB Internet Banking Payment
    public static let ktbInternetBankingPayment = __SourceInternetBankingPayment(type: OMSSourceTypeValue.internetBankingKTB)!
    /// Payment Information for a SCB Internet Banking Payment
    public static let scbInternetBankingPayment = __SourceInternetBankingPayment(type: OMSSourceTypeValue.internetBankingSCB)!
    /// Payment Information for a BBL Internet Banking Payment
    public static let bblInternetBankingPayment = __SourceInternetBankingPayment(type: OMSSourceTypeValue.internetBankingBBL)!

    /// Create an Internet Banking payment with the given source type value
    ///
    /// - Parameter type: Source type of the source to be created
    /// - Precondition: type must have a prefix of `internet_banking`
    public override init?(type: OMSSourceTypeValue) {
        guard type.rawValue.hasPrefix(PaymentInformation.InternetBanking.paymentMethodTypePrefix) else {
            return nil
        }
        super.init(type: type)
    }
}

/// Barcode Source Payment Information
@objc(OMSBarcodePaymentInformation)
@objcMembers
public class __SourceBarcodePayment: __SourcePaymentInformation {}

/// AlipayBarcode Source Payment Information
@objc(OMSAlipayBarcodePaymentInformation)
@objcMembers
public class __SourceAlipayBarcodePayment: __SourceBarcodePayment {
    let alipayBarcodeInformation: PaymentInformation.Barcode.AlipayBarcode

    /// Create an Alipay Barcode payment with the given information
    ///
    /// - Parameters:
    ///   - barcode: Payment of a customer to be charged with
    ///   - storeID: ID of the Store registered with Omise
    ///   - storeName: Name of the Store registered with Omise
    ///   - terminalID: ID of the terminal which creates this charge
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

/// CustomBarcode Source Payment Information
@objc(OMSCustomBarcodePaymentInformation)
@objcMembers
public class __SourceCustomBarcodePayment: __SourceBarcodePayment {
    let parameters: [String: Any]

    /// Create a Barcode payment with the given source type and information
    ///
    /// - Parameters:
    ///   - customType: The type of a source to be created
    ///   - parameters: Parameters of a source to be created
    public init(customType: String, parameters: [String: Any]) {
        self.parameters = parameters
        super.init(type: OMSSourceTypeValue(rawValue: customType))!
    }
}

/// Installments Source Payment Information
@objc(OMSInstallmentsPaymentInformation)
@objcMembers
public class __SourceInstallmentsPayment: __SourcePaymentInformation {
    /// Number of terms of the installment plan
    public let numberOfTerms: Int

    /// Create an Installment paymment with the given source type and number of terms
    ///
    /// - Parameters:
    ///   - type: The type of a source to be created
    ///   - numberOfTerms: Number of terms of the installment plan
    public init?(type: OMSSourceTypeValue, numberOfTerms: Int) {
        guard type.rawValue.hasPrefix(PaymentInformation.Installment.paymentMethodTypePrefix) else {
            return nil
        }
        self.numberOfTerms = numberOfTerms
        super.init(type: type)
    }

    /// Create a BAY Installment payment with the given number of terms
    ///
    /// - Parameter numberOfTerms: Number of plan of the installment plan
    /// - Returns: BAY Installment payment with the specified number of terms
    public static func installmentBAYPayment(withNumberOfTerms numberOfTerms: Int) -> __SourceInstallmentsPayment {
        return __SourceInstallmentsPayment(type: OMSSourceTypeValue.installmentBAY, numberOfTerms: numberOfTerms)!
    }
    /// Create a FirstChoice Installment payment with the given number of terms
    ///
    /// - Parameter numberOfTerms: Number of plan of the installment plan
    /// - Returns: FirstChoice Installment payment with the specified number of terms
    public static func installmentFirstChoicePayment(withNumberOfTerms numberOfTerms: Int) -> __SourceInstallmentsPayment {
        return __SourceInstallmentsPayment(type: OMSSourceTypeValue.installmentFirstChoice, numberOfTerms: numberOfTerms)!
    }
    /// Create a BBL Installment payment with the given number of terms
    ///
    /// - Parameter numberOfTerms: Number of plan of the installment plan
    /// - Returns: BBL Installment payment with the specified number of terms
    public static func installmentBBLPayment(withNumberOfTerms numberOfTerms: Int) -> __SourceInstallmentsPayment {
        return __SourceInstallmentsPayment(type: OMSSourceTypeValue.installmentBBL, numberOfTerms: numberOfTerms)!
    }

    /// Create a MBB Installment payment with the given number of terms
    ///
    /// - Parameter numberOfTerms: Number of plan of the installment plan
    /// - Returns: MBB Installment payment with the specified number of terms
    public static func installmentMBBPayment(withNumberOfTerms numberOfTerms: Int) -> __SourceInstallmentsPayment {
        return __SourceInstallmentsPayment(type: OMSSourceTypeValue.installmentMBB, numberOfTerms: numberOfTerms)!
    }
    /// Create a KTC Installment payment with the given number of terms
    ///
    /// - Parameter numberOfTerms: Number of plan of the installment plan
    /// - Returns: KTC Installment payment with the specified number of terms
    public static func installmentKTCPayment(withNumberOfTerms numberOfTerms: Int) -> __SourceInstallmentsPayment {
        return __SourceInstallmentsPayment(type: OMSSourceTypeValue.installmentKTC, numberOfTerms: numberOfTerms)!
    }
    /// Create a KBank Installment payment with the given number of terms
    ///
    /// - Parameter numberOfTerms: Number of plan of the installment plan
    /// - Returns: KBank Installment payment with the specified number of terms
    public static func installmentKBankPayment(withNumberOfTerms numberOfTerms: Int) -> __SourceInstallmentsPayment {
        return __SourceInstallmentsPayment(type: OMSSourceTypeValue.installmentKBank, numberOfTerms: numberOfTerms)!
    }
    /// Create a SCB Installment payment with the given number of terms
    ///
    /// - Parameter numberOfTerms: Number of plan of the installment plan
    /// - Returns: SCB Installment payment with the specified number of terms
    public static func installmentSCBPayment(withNumberOfTerms numberOfTerms: Int) -> __SourceInstallmentsPayment {
        return __SourceInstallmentsPayment(type: OMSSourceTypeValue.installmentSCB, numberOfTerms: numberOfTerms)!
    }
    /// Create a Citi Installment payment with the given number of terms
    ///
    /// - Parameter numberOfTerms: Number of plan of the installment plan
    /// - Returns: Citi Installment payment with the specified number of terms
    public static func installmentCitiPayment(withNumberOfTerms numberOfTerms: Int) -> __SourceInstallmentsPayment {
        return __SourceInstallmentsPayment(type: OMSSourceTypeValue.installmentCiti, numberOfTerms: numberOfTerms)!
    }
    /// Create a TTB Installment payment with the given number of terms
    ///
    /// - Parameter numberOfTerms: Number of plan of the installment plan
    /// - Returns: TTB Installment payment with the specified number of terms
    public static func installmentTTBPayment(withNumberOfTerms numberOfTerms: Int) -> __SourceInstallmentsPayment {
        return __SourceInstallmentsPayment(type: OMSSourceTypeValue.installmentTTB, numberOfTerms: numberOfTerms)!
    }
    /// Create a UOB Installment payment with the given number of terms
    ///
    /// - Parameter numberOfTerms: Number of plan of the installment plan
    /// - Returns: UOB Installment payment with the specified number of terms
    public static func installmentUOBPayment(withNumberOfTerms numberOfTerms: Int) -> __SourceInstallmentsPayment {
        return __SourceInstallmentsPayment(type: OMSSourceTypeValue.installmentUOB, numberOfTerms: numberOfTerms)!
    }
}

/// EContext Source Payment Information
@objc(OMSEContextPaymentInformation)
@objcMembers
public class __SourceEContextPayment: __SourcePaymentInformation {
    /// Name of the payer
    public let name: String
    /// Email of the payer
    public let email: String
    /// Phone number of the payer
    public let phoneNumber: String

    /// Create an E-Context payment with the given payer information
    ///
    /// - Parameters:
    ///   - name: Name of the payer
    ///   - email: Email of the payer
    ///   - phoneNumber: Phone number of the payer
    public init(name: String, email: String, phoneNumber: String) {
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        super.init(type: OMSSourceTypeValue.eContext)!
    }
}

/// The TrueMoney customer information
@objc(OMSTrueMoneyPaymentInformation)
@objcMembers
public class __SourceTrueMoneyPayment: __SourcePaymentInformation {
    /// The customers phone number. Contains only digits and has 10 or 11 characters
    public let phoneNumber: String

    /// Creates a new TrueMoney source with the given customer information
    ///
    /// - Parameters:
    ///   - phoneNumber: The customers phone number
    public init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
        super.init(type: OMSSourceTypeValue.trueMoney)!
    }
}

/// Points Source Payment Information
@objc(OMSPointsPaymentInformation)
@objcMembers
public class __SourcePointsPayment: __SourcePaymentInformation {

    /// Payment Information for a Citi Points Payment
    public static let citiPoints = __SourcePointsPayment(type: OMSSourceTypeValue.pointsCiti)!

    /// Create a Points payment with the given source type value
    ///
    /// - Parameter type: Source type of the source to be created
    /// - Precondition: type must have a prefix of `points`
    public override init?(type: OMSSourceTypeValue) {
        guard type.rawValue.hasPrefix(PaymentInformation.Points.paymentMethodTypePrefix) else {
            return nil
        }
        super.init(type: type)
    }
}

/// Mobile Bankning Source Payment Information
@objc(OMSMobileBankingPaymentInformation)
@objcMembers
public class __SourceMobileBankingPayment: __SourcePaymentInformation {

    /// Payment Information for a SCB Mobile Banking Payment
    public static let scbMobileBankingPayment = __SourceMobileBankingPayment(type: OMSSourceTypeValue.mobileBankingSCB)!
    
    /// Payment Information for a KBank PayPlus Mobile Banking Payment
    public static let kbankMobileBankingPayment = __SourceMobileBankingPayment(type: OMSSourceTypeValue.mobileBankingKBank)!

    /// Payment Information for a BAY Mobile Banking Payment
    public static let bayMobileBankingPayment = __SourceMobileBankingPayment(type: OMSSourceTypeValue.mobileBankingBAY)!

    /// Payment Information for a BBL Mobile Banking Payment
    public static let bblMobileBankingPayment = __SourceMobileBankingPayment(type: OMSSourceTypeValue.mobileBankingBBL)!

    /// Create an Mobile Banking payment with the given source type value
    ///
    /// - Parameter type: Source type of the source to be created
    /// - Precondition: type must have a prefix of `internet_banking`
    public override init?(type: OMSSourceTypeValue) {
        guard type.rawValue.hasPrefix(PaymentInformation.MobileBanking.paymentMethodTypePrefix) else {
            return nil
        }
        super.init(type: type)
    }
}

/// The FPX Source Payment information
@objc(OMSFPXPaymentInformation)
@objcMembers
public class __SourceFPXPayment: __SourcePaymentInformation {
    /// The customer's bank name
    public let bank: String

    /// The customer's email
    public let email: String?

    /// Creates a new FPX source with the given customer information
    ///
    /// - Parameters:
    ///   - bank:  Internet banking name e.g. uob
    ///   - email:  Customer's email
    public init(bank: String, email: String?) {
        self.bank = bank
        self.email = email
        super.init(type: OMSSourceTypeValue.fpx)!
    }
}

/// The DuitNow OBW Source Payment information
@objc(OMSDuitNowOBWPaymentInformation)
@objcMembers
public class __SourceDuitNowOBWPayment: __SourcePaymentInformation {
    /// The customer's bank name
    public let bank: String

    /// Creates a new FPX source with the given customer information
    ///
    /// - Parameters:
    ///   - bank:  Internet banking name e.g. uob
    public init(bank: String) {
        self.bank = bank
        super.init(type: OMSSourceTypeValue.duitNowOBW)!
    }
}

/// CustomSource Source Payment Information
@objc(OMSCustomPaymentInformation)
@objcMembers
public class __CustomSourcePayment: __SourcePaymentInformation {
    /// Parameter of the payment source in a JSON data type
    public let parameters: [String: Any]

    /// Create a payment source with the given type and source parameter
    ///
    /// - Parameters:
    ///   - customType: The source type of the payment source
    ///   - parameters: The parameter of the payment source
    public init(customType: String, parameters: [String: Any]) {
        self.parameters = parameters
        super.init(type: OMSSourceTypeValue(rawValue: customType))!
    }
}

extension PaymentInformation {
    // swiftlint:disable function_body_length
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
            case .mobileBankingSCB:
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
            case .installmentMBB:
                brand = .mbb
            case .installmentKTC:
                brand = .ktc
            case .installmentKBank:
                brand = .kBank
            case .installmentSCB:
                brand = .scb
            case .installmentCiti:
                brand = .citi
            case .installmentTTB:
                brand = .ttb
            case .installmentUOB:
                brand = .uob
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
        case let value where value.type == OMSSourceTypeValue.promptPay:
            self = .promptpay
        case let value as __SourceTrueMoneyPayment:
            self = .truemoney(TrueMoney(phoneNumber: value.phoneNumber))
        case let value as __SourcePointsPayment:
            let type: PaymentInformation.Points
            switch value.type {
            case .pointsCiti:
                type = .citiPoints
            case let typeValue:
                let range = typeValue.rawValue.range(of: PaymentInformation.Points.paymentMethodTypePrefix)!
                type = .other(String(typeValue.rawValue[range.upperBound...]))
            }
            self = .points(type)
        case let value as __CustomSourcePayment:
            self = .other(type: value.type.rawValue, parameters: value.parameters)
        default:
            self = .other(type: paymentInformation.type.rawValue, parameters: [:])
        }
    }
}

extension __SourcePaymentInformation {
    // swiftlint:disable function_body_length
    static func makeSourcePaymentInformation(from paymentInformation: PaymentInformation) -> __SourcePaymentInformation {
        switch paymentInformation {
        case .alipay:
            return __SourcePaymentInformation.alipayPayment
        case .alipayCN:
            return __SourcePaymentInformation.alipayCNPayment
        case .alipayHK:
            return __SourcePaymentInformation.alipayHKPayment
        case .dana:
            return __SourcePaymentInformation.danaPayment
        case .gcash:
            return __SourcePaymentInformation.gcashPayment
        case .kakaoPay:
            return __SourcePaymentInformation.kakaoPayPayment
        case .touchNGo:
            return __SourcePaymentInformation.touchNGoPayment

        case .barcode(PaymentInformation.Barcode.alipay(let alipayInformation)):
            return __SourceAlipayBarcodePayment(barcode: alipayInformation.barcode,
                                                storeID: alipayInformation.storeID,
                                                storeName: alipayInformation.storeName,
                                                terminalID: alipayInformation.terminalID)
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
            case .mbb:
                return __SourceInstallmentsPayment.installmentMBBPayment(withNumberOfTerms: installment.numberOfTerms)
            case .ktc:
                return __SourceInstallmentsPayment.installmentKTCPayment(withNumberOfTerms: installment.numberOfTerms)
            case .kBank:
                return __SourceInstallmentsPayment.installmentKBankPayment(withNumberOfTerms: installment.numberOfTerms)
            case .scb:
                return __SourceInstallmentsPayment.installmentSCBPayment(withNumberOfTerms: installment.numberOfTerms)
            case .citi:
                return __SourceInstallmentsPayment.installmentCitiPayment(withNumberOfTerms: installment.numberOfTerms)
            case .ttb:
                return __SourceInstallmentsPayment.installmentTTBPayment(withNumberOfTerms: installment.numberOfTerms)
            case .uob:
                return __SourceInstallmentsPayment.installmentUOBPayment(withNumberOfTerms: installment.numberOfTerms)
            case .other(let type) where type.hasPrefix(PaymentInformation.Installment.paymentMethodTypePrefix):
                return __SourceInstallmentsPayment.init(type: OMSSourceTypeValue(type), numberOfTerms: installment.numberOfTerms)!
            case .other(let type):
                return __CustomSourcePayment(customType: type, parameters: [:])
            }
        case .eContext(let eContext):
            return __SourceEContextPayment(name: eContext.name, email: eContext.email, phoneNumber: eContext.phoneNumber)

        case .promptpay:
            return __SourcePaymentInformation.promptPayPayment

        case .paynow:
            return __SourcePaymentInformation.payNowPayment
            
        case .rabbitLinepay:
            return __SourcePaymentInformation.rabbitLinepayPayment

        case .ocbcPao:
            return __SourcePaymentInformation.ocbcPaoPayment

        case .grabPay:
            return __SourcePaymentInformation.grabPayPayment
            
        case .boost:
            return __SourcePaymentInformation.boostPayment
            
        case .shopeePay:
            return __SourcePaymentInformation.shopeePayPayment

        case .shopeePayJumpApp:
            return __SourcePaymentInformation.shopeePayJumpAppPayment

        case .maybankQRPay:
            return __SourcePaymentInformation.maybankQRPayPayment
            
        case .duitNowQR:
            return __SourcePaymentInformation.duitNowQRPayment
            
        case .truemoney(let trueMoney):
            return __SourceTrueMoneyPayment(phoneNumber: trueMoney.phoneNumber)

        case .points(let points):
            switch points {
            case .citiPoints:
                return __SourcePointsPayment.citiPoints
            case .other(let type):
                return __CustomSourcePayment(customType: type, parameters: [:])
            }

        case .mobileBanking(let bank):
            switch bank {
            case .scb:
                return __SourceMobileBankingPayment.scbMobileBankingPayment
            case .kbank:
                return __SourceMobileBankingPayment.kbankMobileBankingPayment
            case .bay:
                return __SourceMobileBankingPayment.bayMobileBankingPayment
            case .bbl:
                return __SourceMobileBankingPayment.bblMobileBankingPayment
            case .other(let type):
                return __CustomSourcePayment(customType: type, parameters: [:])
            }

        case .fpx(let fpx):
            return __SourceFPXPayment(bank: fpx.bank, email: fpx.email)
            
        case .duitNowOBW(let duitNowOBW):
            return __SourceDuitNowOBWPayment(bank: duitNowOBW.bank)
            
        case .other(type: let type, parameters: let parameters):
            return __CustomSourcePayment(customType: type, parameters: parameters)
        }
    }
}
