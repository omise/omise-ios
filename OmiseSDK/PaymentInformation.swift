// swiftlint:disable file_length

import Foundation

public protocol PaymentMethod: Equatable, Codable {
    static var paymentMethodTypePrefix: String { get }
    var type: String { get }
}

// swiftlint:disable:next static_operator operator_whitespace
func ~=<T: PaymentMethod>(methodType: T.Type, type: String) -> Bool {
    return type.hasPrefix(methodType.paymentMethodTypePrefix)
}

/// Represents the payment information of a Source
public enum PaymentInformation: Codable, Equatable {
// swiftlint:disable:previous type_body_length

    /// The code of the bank for the Internet Bankning Payment
    public enum InternetBanking: PaymentMethod {
        public static let paymentMethodTypePrefix: String = "internet_banking_"

        case bay
        case bbl
        case other(String)
    }
    /// Internet Banking Payment Source
    case internetBanking(InternetBanking)

    /// Online Alipay Payment Source
    case alipay

    /// Online Alipay + China Wallet Payment Source
    case alipayCN

    /// Online Alipay + Hongkong Wallet Payment Source
    case alipayHK
    
    /// Online Atome Payment Source
    case atome(Atome)

    /// Online Alipay + Dana Wallet Payment Source
    case dana

    /// Online Alipay + Gcash Wallet Payment Source
    case gcash

    /// Online Alipay + KakaoPay Wallet Payment Source
    case kakaoPay

    /// Online Alipay + Touch N Go Wallet Payment Source
    case touchNGo

    /// The name of the supported services to process the Bill Payment
    public enum BillPayment: PaymentMethod {
        public static let paymentMethodTypePrefix: String = "bill_payment_"

        case tescoLotus
        case other(String)
    }
    /// Bill Payment Payment Source
    case billPayment(BillPayment)

    /// The name of the supported Barcode Payment services
    public enum Barcode: PaymentMethod {
        public static let paymentMethodTypePrefix: String = "barcode_"

        case alipay(AlipayBarcode)
        case other(String, parameters: [String: Any])

        public var type: String {
            switch self {
            case .alipay:
                return SourceTypeValue.barcodeAlipay.rawValue
            case .other(let value, _):
                return Barcode.paymentMethodTypePrefix + value
            }
        }
    }
    /// Barcode Payment Source
    case barcode(Barcode)

    /// The Installments information
    public struct Installment: PaymentMethod {
        public static let paymentMethodTypePrefix: String = "installment_"

        /// The code of the supported Installment payment banks
        public enum Brand: Equatable {
            case bay
            case firstChoice
            case bbl
            case mbb
            case ktc
            case kBank
            case scb
            case ttb
            case uob
            case other(String)
        }

        /// The brand of the bank of the installment
        public let brand: Brand
        /// A number of terms to do the installment
        public let numberOfTerms: Int

        /// Method for query the default list of the brand's available number of terms
        ///
        /// - Parameter brand: The brand that want to query ask
        /// - Returns: The numbers of available terms for installment payment
        static func availableTerms(for brand: Brand) -> IndexSet {
            switch brand {
            case .bay:
                return IndexSet([ 3, 4, 6, 9, 10 ])
            case .firstChoice:
                return IndexSet([ 3, 4, 6, 9, 10, 12, 18, 24, 36 ])
            case .bbl:
                return IndexSet([ 4, 6, 8, 9, 10 ])
            case .mbb:
                return IndexSet([ 6, 12, 18, 24 ])
            case .ktc:
                return IndexSet([ 3, 4, 5, 6, 7, 8, 9, 10 ])
            case .kBank:
                return IndexSet([ 3, 4, 6, 10 ])
            case .scb:
                return IndexSet([ 3, 4, 6, 9, 10 ])
            case .ttb:
                return IndexSet([ 3, 4, 6, 10, 12 ])
            case .uob:
                return IndexSet([ 3, 4, 6, 10 ])
            case .other:
                return IndexSet(1...60)
            }
        }

        public init(brand: Brand, numberOfTerms: Int) {
            self.brand = brand
            self.numberOfTerms = numberOfTerms
        }
    }
    /// Installments Payment Source
    case installment(Installment)

    /// The EContext customer information
    public struct EContext: PaymentMethod, Codable, Equatable {
        public static var paymentMethodTypePrefix: String = SourceTypeValue.eContext.rawValue

        public let type: String = SourceTypeValue.eContext.rawValue

        /// Customer name. The name cannot be longer than 10 characters
        public let name: String
        /// Customer email
        public let email: String
        /// Customer phone number. The phone number must contains only digit characters and has 10 or 11 characters
        public let phoneNumber: String

        private enum CodingKeys: String, CodingKey {
            case name
            case email
            case phoneNumber = "phone_number"
        }

        /// Creates a new EContext customer information with the given info
        ///
        /// - Parameters:
        ///   - name: Customer name
        ///   - email: Customer email
        ///   - phoneNumber: Customer phone number
        public init(name: String, email: String, phoneNumber: String) {
            self.name = name
            self.email = email
            self.phoneNumber = phoneNumber
        }
    }
    /// E-Context Payment Source
    case eContext(EContext)

    /// PromptPay Payment Source
    case promptpay

    /// PayNow Payment Source
    case paynow

    /// WeChat Payment Source
    case weChat

    /// The TrueMoney customer information
    public struct TrueMoney: PaymentMethod {

        public static var paymentMethodTypePrefix: String = SourceTypeValue.trueMoney.rawValue

        public var type: String = SourceTypeValue.trueMoney.rawValue

        /// The customers phone number. Contains only digits and has 10 or 11 characters
        public let phoneNumber: String

        private enum CodingKeys: String, CodingKey {
            case phoneNumber = "phone_number"
        }

        /// Creates a new TrueMoney source with the given customer information
        ///
        /// - Parameters:
        ///   - phoneNumber:  The customers phone number
        public init(phoneNumber: String) {
            self.phoneNumber = phoneNumber
        }

    }

    /// TrueMoney Payment Source
    case truemoney(TrueMoney)
    case truemoneyJumpApp

    /// The name of the supported services to process the Points Payment
    public enum Points: PaymentMethod {
        public static let paymentMethodTypePrefix: String = "points_"

        case citiPoints
        case other(String)
    }

    /// Points Payment Source
    case points(Points)

    /// The code of the bank for the Internet Bankning Payment
    public enum MobileBanking: PaymentMethod {
        public static let paymentMethodTypePrefix: String = "mobile_banking_"

        case scb
        case kbank
        case bay
        case bbl
        case ktb
        case other(String)
    }

    /// Mobile Banking Payment Source
    case mobileBanking(MobileBanking)

    /// Internet Banking FPX
    public struct FPX: PaymentMethod {
        public static var paymentMethodTypePrefix: String = SourceTypeValue.fpx.rawValue

        public var type: String = SourceTypeValue.fpx.rawValue

        /// The customer's bank name
        public let bank: String

        /// Customer email
        public let email: String?

        private enum CodingKeys: String, CodingKey {
            case bank
            case email
        }

        /// Creates a new FPX source with the given bank name
        ///
        /// - Parameters:
        ///   - bank:  Internet banking name e.g. uob
        ///   - email: Customer email
        public init(bank: String, email: String?) {
            self.bank = bank
            self.email = email
        }
    }

    /// Internet Banking FPX
    case fpx(FPX)
    
    // Rabbit LINE Pay
    case rabbitLinepay
    
    /// OCBC Digital Payment Source
    case ocbcDigital

    /// Boost Payment Source
    case boost
    
    /// ShopeePay Payment Source
    case shopeePay
    
    /// ShopeePayJumpApp Payment Source
    case shopeePayJumpApp
    
    /// Maybank QRPay Payment Source
    case maybankQRPay
    
    /// DuitNow QR Payment Source
    case duitNowQR
    
    /// DuitNow OBW
    public struct DuitNowOBW: PaymentMethod {
        public static var paymentMethodTypePrefix: String = SourceTypeValue.duitNowOBW.rawValue

        public var type: String = SourceTypeValue.duitNowOBW.rawValue

        /// The code of the supported Installment payment banks
        public enum Bank: Equatable {
            case affin
            case alliance
            case agro
            case ambank
            case cimb
            case islam
            case rakyat
            case muamalat
            case bsn
            case hongleong
            case hsbc
            case kfh
            case maybank2u
            case ocbc
            case publicBank
            case rhb
            case sc
            case uob
            case other(String)
        }
        
        /// The customer's bank name
        public let bank: String

        private enum CodingKeys: String, CodingKey {
            case bank
        }
        
        /// Creates a new DuitNow OBW source with the given bank name
        ///
        /// - Parameters:
        ///   - bank:  bank name e.g. affin
        public init(bank: String) {
            self.bank = bank
        }
    }

    /// DuitNow OBW Payment Source
    case duitNowOBW(DuitNowOBW)

    // GrabPay
    case grabPay
    
    // PayPay
    case payPay

    /// Other Payment Source
    case other(type: String, parameters: [String: Any])

    fileprivate enum CodingKeys: String, CodingKey {
        case type
    }

    // swiftlint:disable:next function_body_length
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeValue = try container.decode(String.self, forKey: .type)

        switch typeValue {
        case PaymentInformation.InternetBanking.self:
            self = .internetBanking(try PaymentInformation.InternetBanking(from: decoder))
        case PaymentInformation.BillPayment.self:
            self = .billPayment(try BillPayment(from: decoder))
        case PaymentInformation.Barcode.self:
            self = .barcode(try Barcode(from: decoder))
        case PaymentInformation.Installment.self:
            self = .installment(try Installment(from: decoder))
        case PaymentInformation.EContext.self:
            self = .eContext(try EContext(from: decoder))
        case SourceTypeValue.alipay.rawValue:
            self = .alipay
        case SourceTypeValue.alipayCN.rawValue:
            self = .alipayCN
        case SourceTypeValue.alipayHK.rawValue:
            self = .alipayHK
        case SourceTypeValue.atome.rawValue:
            self = .atome(try Atome(from: decoder))
        case SourceTypeValue.dana.rawValue:
            self = .dana
        case SourceTypeValue.gcash.rawValue:
            self = .gcash
        case SourceTypeValue.kakaoPay.rawValue:
            self = .kakaoPay
        case SourceTypeValue.touchNGo.rawValue:
            self = .touchNGo
        case SourceTypeValue.promptPay.rawValue:
            self = .promptpay
        case SourceTypeValue.payNow.rawValue:
            self = .paynow
        case SourceTypeValue.trueMoney.rawValue:
            self = .truemoney(try TrueMoney(from: decoder))
        case SourceTypeValue.rabbitLinepay.rawValue:
            self = .rabbitLinepay
        case SourceTypeValue.grabPay.rawValue:
            self = .grabPay
        case SourceTypeValue.boost.rawValue:
            self = .boost
        case SourceTypeValue.shopeePay.rawValue:
            self = .shopeePay
        case SourceTypeValue.shopeePayJumpApp.rawValue:
            self = .shopeePayJumpApp
        case SourceTypeValue.maybankQRPay.rawValue:
            self = .maybankQRPay
        case SourceTypeValue.duitNowQR.rawValue:
            self = .duitNowQR
        case PaymentInformation.Points.self:
            self = .points(try Points(from: decoder))
        case PaymentInformation.MobileBanking.self:
            self = .mobileBanking(try PaymentInformation.MobileBanking(from: decoder))
        case PaymentInformation.FPX.self:
            self = .fpx(try FPX(from: decoder))
        case PaymentInformation.DuitNowOBW.self:
            self = .duitNowOBW(try DuitNowOBW(from: decoder))
        case SourceTypeValue.payPay.rawValue:
            self = .payPay
        case let value:
            self = .other(type: value, parameters: try decoder.decodeJSONDictionary().filter({ (key, _) -> Bool in
                switch key {
                case CodingKeys.type.stringValue, Source.CodingKeys.object.stringValue,
                     Source.CodingKeys.id.stringValue, Source.CodingKeys.flow.stringValue,
                     Source.CodingKeys.currency.stringValue, Source.CodingKeys.amount.stringValue,
                    "livemode", "location":
                    return false
                default: return true
                }
            }))
        }
    }

    // swiftlint:disable:next function_body_length
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .internetBanking(let value):
            try value.encode(to: encoder)
        case .billPayment(let value):
            try value.encode(to: encoder)
        case .barcode(let value):
            try value.encode(to: encoder)
        case .installment(let value):
            try value.encode(to: encoder)
        case .alipay:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SourceTypeValue.alipay.rawValue, forKey: .type)
        case .alipayCN:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SourceTypeValue.alipayCN.rawValue, forKey: .type)
        case .alipayHK:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SourceTypeValue.alipayHK.rawValue, forKey: .type)
        case .atome:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SourceTypeValue.atome.rawValue, forKey: .type)
        case .dana:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SourceTypeValue.dana.rawValue, forKey: .type)
        case .gcash:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SourceTypeValue.gcash.rawValue, forKey: .type)
        case .kakaoPay:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SourceTypeValue.kakaoPay.rawValue, forKey: .type)
        case .touchNGo:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SourceTypeValue.touchNGo.rawValue, forKey: .type)
        case .eContext(let eContext):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SourceTypeValue.eContext.rawValue, forKey: .type)
            try eContext.encode(to: encoder)
        case .promptpay:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SourceTypeValue.promptPay.rawValue, forKey: .type)
        case .paynow:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SourceTypeValue.payNow.rawValue, forKey: .type)
        case .truemoney(let trueMoney):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SourceTypeValue.trueMoney.rawValue, forKey: .type)
            try trueMoney.encode(to: encoder)
        case .truemoneyJumpApp:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SourceTypeValue.trueMoneyJumpApp.rawValue, forKey: .type)
        case .points(let points):
            try points.encode(to: encoder)
        case .mobileBanking(let value):
            try value.encode(to: encoder)
        case .fpx(let fpx):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SourceTypeValue.fpx.rawValue, forKey: .type)
            try fpx.encode(to: encoder)
        case .rabbitLinepay:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SourceTypeValue.rabbitLinepay.rawValue, forKey: .type)
        case .ocbcDigital:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SourceTypeValue.mobileBankingOCBC.rawValue, forKey: .type)
        case .grabPay:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SourceTypeValue.grabPay.rawValue, forKey: .type)
        case .boost:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SourceTypeValue.boost.rawValue, forKey: .type)
        case .shopeePay:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SourceTypeValue.shopeePay.rawValue, forKey: .type)
        case .shopeePayJumpApp:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SourceTypeValue.shopeePayJumpApp.rawValue, forKey: .type)
        case .maybankQRPay:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SourceTypeValue.maybankQRPay.rawValue, forKey: .type)
        case .duitNowQR:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SourceTypeValue.duitNowQR.rawValue, forKey: .type)
        case .duitNowOBW(let duitNowOBW):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SourceTypeValue.duitNowOBW.rawValue, forKey: .type)
            try duitNowOBW.encode(to: encoder)
        case .payPay:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SourceTypeValue.payPay.rawValue, forKey: .type)
        case .weChat:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(SourceTypeValue.weChat.rawValue, forKey: .type)
        case .other(type: let type, parameters: let parameters):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            try encoder.encodeJSONDictionary(parameters)
        }
    }

    // swiftlint:disable:next function_body_length
    public static func == (lhs: PaymentInformation, rhs: PaymentInformation) -> Bool {
        switch (lhs, rhs) {
        case (.internetBanking(let lhsValue), .internetBanking(let rhsValue)):
            return lhsValue == rhsValue
        case (.alipay, .alipay):
            return true
        case (.alipayCN, .alipayCN):
            return true
        case (.alipayHK, .alipayHK):
            return true
        case (.atome, .atome):
            return true
        case (.dana, .dana):
            return true
        case (.gcash, .gcash):
            return true
        case (.kakaoPay, .kakaoPay):
            return true
        case (.touchNGo, .touchNGo):
            return true
        case (.promptpay, .promptpay), (.paynow, .paynow):
            return true
        case (.rabbitLinepay, .rabbitLinepay):
            return true
        case (.grabPay, .grabPay):
            return true
        case (.boost, .boost):
            return true
        case (.shopeePay, .shopeePay):
            return true
        case (.shopeePayJumpApp, .shopeePayJumpApp):
            return true
        case (.maybankQRPay, .maybankQRPay):
            return true
        case (.duitNowQR, .duitNowQR):
            return true
        case (.truemoney(let lhsValue), .truemoney(let rhsValue)):
            return lhsValue == rhsValue
        case (.billPayment(let lhsValue), .billPayment(let rhsValue)):
            return lhsValue == rhsValue
        case (.barcode(let lhsValue), .barcode(let rhsValue)):
            return lhsValue == rhsValue
        case (.installment(let lhsValue), .installment(let rhsValue)):
            return lhsValue == rhsValue
        case (.eContext(let lhsValue), .eContext(let rhsValue)):
            return lhsValue == rhsValue
        case (.points(let lhsValue), .points(let rhsValue)):
            return lhsValue == rhsValue
        case (.mobileBanking(let lhsValue), .mobileBanking(let rhsValue)):
            return lhsValue == rhsValue
        case (.fpx(let lhsValue), .fpx(let rhsValue)):
            return lhsValue == rhsValue
        case (.duitNowOBW(let lhsValue), .duitNowOBW(let rhsValue)):
            return lhsValue == rhsValue
        case (.payPay, .payPay):
            return true
        case (.weChat, .weChat):
            return true
        case (.other(let lhsType, let lhsParameters), .other(let rhsType, let rhsParameters)):
            return lhsType == rhsType &&
                Set(lhsParameters.keys) == Set(rhsParameters.keys)
        default: return false
        }
    }

}

extension Request where T == Source {
    /// Initializes a new Source Request
    public init (paymentInformation: PaymentInformation, amount: Int64, currency: Currency) {
        self.init(
            parameter: CreateSourceParameter(paymentInformation: paymentInformation, amount: amount, currency: currency)
        )
    }
}

extension PaymentInformation {
    /// Omise Source Type value using in the Omise API
    public var sourceType: String {
        switch self {
        case .alipay:
            return SourceTypeValue.alipay.rawValue
        case .alipayCN:
            return SourceTypeValue.alipayCN.rawValue
        case .alipayHK:
            return SourceTypeValue.alipayHK.rawValue
        case .atome:
            return SourceTypeValue.atome.rawValue
        case .dana:
            return SourceTypeValue.dana.rawValue
        case .gcash:
            return SourceTypeValue.gcash.rawValue
        case .kakaoPay:
            return SourceTypeValue.kakaoPay.rawValue
        case .touchNGo:
            return SourceTypeValue.touchNGo.rawValue
        case .barcode(let barcode):
            return barcode.type
        case .billPayment(let billPayment):
            return billPayment.type
        case .installment(let installment):
            return installment.type
        case .internetBanking(let bank):
            return bank.type
        case .eContext:
            return SourceTypeValue.eContext.rawValue
        case .promptpay:
            return SourceTypeValue.promptPay.rawValue
        case .paynow:
            return SourceTypeValue.payNow.rawValue
        case .truemoney:
            return SourceTypeValue.trueMoney.rawValue
        case .truemoneyJumpApp:
            return SourceTypeValue.trueMoneyJumpApp.rawValue
        case .rabbitLinepay:
            return SourceTypeValue.rabbitLinepay.rawValue
        case .ocbcDigital:
            return SourceTypeValue.mobileBankingOCBC.rawValue
        case .grabPay:
            return SourceTypeValue.grabPay.rawValue
        case .boost:
            return SourceTypeValue.boost.rawValue
        case .shopeePay:
            return SourceTypeValue.shopeePay.rawValue
        case .shopeePayJumpApp:
            return SourceTypeValue.shopeePayJumpApp.rawValue
        case .maybankQRPay:
            return SourceTypeValue.maybankQRPay.rawValue
        case .duitNowQR:
            return SourceTypeValue.duitNowQR.rawValue
        case .points(let points):
            return points.type
        case .mobileBanking(let bank):
            return bank.type
        case .fpx(let bank):
            return bank.type
        case .duitNowOBW(let bank):
            return bank.type
        case .payPay:
            return SourceTypeValue.payPay.rawValue
        case .weChat:
            return SourceTypeValue.weChat.rawValue
        case .other(let value, _):
            return value
        }
    }
}

extension PaymentInformation.InternetBanking: CaseIterable, CustomStringConvertible {
    public typealias AllCases = [PaymentInformation.InternetBanking]
    public static var allCases: PaymentInformation.InternetBanking.AllCases = [
        .bay, .bbl
    ]

    /// Omise Source Type value using in the Omise API
    public var type: String {
        switch self {
        case .bay:
            return SourceTypeValue.internetBankingBAY.rawValue
        case .bbl:
            return SourceTypeValue.internetBankingBBL.rawValue
        case .other(let value):
            return PaymentInformation.InternetBanking.paymentMethodTypePrefix + value
        }
    }

    public var description: String {
        switch self {
        case .bay:
            return "BAY"
        case .bbl:
            return "BBL"
        case .other(let value):
            return value
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PaymentInformation.CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        guard type.hasPrefix(PaymentInformation.InternetBanking.paymentMethodTypePrefix),
            let typePrefixRange = type.range(of: PaymentInformation.InternetBanking.paymentMethodTypePrefix) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .type,
                    in: container,
                    debugDescription: "Invalid internet banking source type value"
                )
        }

        switch type[typePrefixRange.upperBound...] {
        case "bay":
            self = .bay
        case "bbl":
            self = .bbl
        case let value:
            self = .other(String(value))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PaymentInformation.CodingKeys.self)
        try container.encode(type, forKey: .type)
    }
}

extension PaymentInformation.Installment {
    /// Omise Source Type value using in the Omise API
    public var type: String {
        switch brand {
        case .bay:
            return SourceTypeValue.installmentBAY.rawValue
        case .firstChoice:
            return SourceTypeValue.installmentFirstChoice.rawValue
        case .bbl:
            return SourceTypeValue.installmentBBL.rawValue
        case .mbb:
            return SourceTypeValue.installmentMBB.rawValue
        case .ktc:
            return SourceTypeValue.installmentKTC.rawValue
        case .kBank:
            return SourceTypeValue.installmentKBank.rawValue
        case .scb:
            return SourceTypeValue.installmentSCB.rawValue
        case .ttb:
            return SourceTypeValue.installmentTTB.rawValue
        case .uob:
            return SourceTypeValue.installmentUOB.rawValue
        case .other(let value):
            return PaymentInformation.Installment.paymentMethodTypePrefix + value
        }
    }

    private enum CodingKeys: String, CodingKey {
        case installmentTerms = "installment_term"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PaymentInformation.CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        guard type.hasPrefix(PaymentInformation.Installment.paymentMethodTypePrefix),
            let typePrefixRange = type.range(of: PaymentInformation.Installment.paymentMethodTypePrefix) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .type,
                    in: container,
                    debugDescription: "Invalid installments source type value"
                )
        }

        let brand: Brand
        switch type[typePrefixRange.upperBound...] {
        case "bay":
            brand = .bay
        case "first_choice":
            brand = .firstChoice
        case "bbl":
            brand = .bbl
        case "mbb":
            brand = .mbb
        case "ktc":
            brand = .ktc
        case "kbank":
            brand = .kBank
        case "scb":
            brand = .scb
        case "ttb":
            brand = .ttb
        case "uob":
            brand = .uob
        case let value:
            brand = .other(String(value))
        }

        let installmentContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.init(brand: brand, numberOfTerms: try installmentContainer.decode(Int.self, forKey: .installmentTerms))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PaymentInformation.CodingKeys.self)
        try container.encode(type, forKey: .type)
        var installmentsContainer = encoder.container(keyedBy: CodingKeys.self)
        try installmentsContainer.encode(numberOfTerms, forKey: .installmentTerms)
    }
}

extension PaymentInformation.Installment.Brand: CaseIterable, CustomStringConvertible {
    public typealias AllCases = [PaymentInformation.Installment.Brand]
    public static var allCases: PaymentInformation.Installment.Brand.AllCases = [
        .bay, .firstChoice, .bbl, .ktc, .kBank, .scb
    ]

    public var description: String {
        switch self {
        case .bay:
            return "BAY"
        case .firstChoice:
            return "First Choice"
        case .bbl:
            return "BBL"
        case .mbb:
            return "MBB"
        case .ktc:
            return "KTC"
        case .kBank:
            return "K-Bank"
        case .scb:
            return "SCB"
        case .ttb:
            return "TTB"
        case .uob:
            return "UOB"
        case .other(let value):
            return value
        }
    }

    public var type: String {
        switch self {
        case .bay:
            return SourceTypeValue.installmentBAY.rawValue
        case .firstChoice:
            return SourceTypeValue.installmentFirstChoice.rawValue
        case .bbl:
            return SourceTypeValue.installmentBBL.rawValue
        case .mbb:
            return SourceTypeValue.installmentMBB.rawValue
        case .ktc:
            return SourceTypeValue.installmentKTC.rawValue
        case .kBank:
            return SourceTypeValue.installmentKBank.rawValue
        case .scb:
            return SourceTypeValue.installmentSCB.rawValue
        case .ttb:
            return SourceTypeValue.installmentTTB.rawValue
        case .uob:
            return SourceTypeValue.installmentUOB.rawValue
        case .other(let value):
            return value
        }
    }
}

extension PaymentInformation.BillPayment {
    /// Omise Source Type value using in the Omise API
    public var type: String {
        switch self {
        case .tescoLotus:
            return SourceTypeValue.billPaymentTescoLotus.rawValue
        case .other(let value):
            return PaymentInformation.BillPayment.paymentMethodTypePrefix + value
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PaymentInformation.CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        guard type.hasPrefix(PaymentInformation.BillPayment.paymentMethodTypePrefix),
            let typePrefixRange = type.range(of: PaymentInformation.BillPayment.paymentMethodTypePrefix) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .type,
                    in: container,
                    debugDescription: "Invalid bill payment source type value"
                )
        }

        switch type[typePrefixRange.upperBound...] {
        case "tesco_lotus":
            self = .tescoLotus
        case let value:
            self = .other(String(value))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PaymentInformation.CodingKeys.self)
        try container.encode(type, forKey: .type)
    }
}

extension PaymentInformation.Barcode {
    /// Alipay Barcode Payment Information
    public struct AlipayBarcode: Codable, Equatable {
        /// Barcode value generated by the customer's Alipay app
        public let barcode: String

        /// The Store Information for the Alipay Barcode Payement
        public struct StoreInformation: Codable, Equatable {
            /// Store ID registering with Omise or Alipay
            public let storeID: String
            /// Store Name registering with Omise or Alipay
            public let storeName: String

            public init(storeID: String, storeName: String) {
                self.storeID = storeID
                self.storeName = storeName
            }
        }

        /// Store Information where the source is being created, optional.
        public let storeInformation: StoreInformation?

        /// Store ID registering with Omise or Alipay
        public var storeID: String? {
            return storeInformation?.storeID
        }

        /// Store Name registering with Omise or Alipay
        public var storeName: String? {
            return storeInformation?.storeName
        }

        /// ID of the Terminal where the source is being created
        public let terminalID: String?
        private enum CodingKeys: String, CodingKey {
            case barcode
            case storeID = "store_id"
            case storeName = "store_name"
            case terminalID = "terminal_id"
        }

        public init(barcode: String, storeInformation: StoreInformation? = nil, terminalID: String? = nil) {
            self.storeInformation = storeInformation
            self.terminalID = terminalID
            self.barcode = barcode
        }

        public init(barcode: String, storeID: String, storeName: String, terminalID: String?) {
            self.init(barcode: barcode, storeInformation: StoreInformation(storeID: storeID, storeName: storeName), terminalID: terminalID)
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let barcode = try container.decode(String.self, forKey: .barcode)

            let storeID = try container.decodeIfPresent(String.self, forKey: .storeID)
            let storeName = try container.decodeIfPresent(String.self, forKey: .storeName)

            let terminalID = try container.decodeIfPresent(String.self, forKey: .terminalID)

            let storeInformation: StoreInformation?
            switch (storeID, storeName) {
            case let (storeID?, storeName?):
                storeInformation = StoreInformation(storeID: storeID, storeName: storeName)
            case (nil, nil):
                storeInformation = nil
            case (nil, .some):
                let context = DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Alipay Barcode store name is present but store id informaiton is missing"
                )
                throw DecodingError.keyNotFound(CodingKeys.storeID, context)
            case (.some, nil):
                let context = DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Alipay Barcode store id is present but store name informaiton is missing"
                )
                throw DecodingError.keyNotFound(CodingKeys.storeName, context)
            }

            self.init(barcode: barcode, storeInformation: storeInformation, terminalID: terminalID)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(barcode, forKey: .barcode)

            try container.encodeIfPresent(storeInformation?.storeID, forKey: .storeID)
            try container.encodeIfPresent(storeInformation?.storeName, forKey: .storeName)
            try container.encodeIfPresent(terminalID, forKey: .terminalID)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PaymentInformation.CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        guard type.hasPrefix(PaymentInformation.Barcode.paymentMethodTypePrefix),
            let typePrefixRange = type.range(of: PaymentInformation.Barcode.paymentMethodTypePrefix) else {
                throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid barcode source type value")
        }
        switch String(type[typePrefixRange.upperBound...]) {
        case SourceTypeValue.alipay.rawValue:
            self = .alipay(try AlipayBarcode(from: decoder))
        case let value:
            self = .other(String(value), parameters: try decoder.decodeJSONDictionary().filter({ (key, _) -> Bool in
                switch key {
                case PaymentInformation.CodingKeys.type.stringValue, Source.CodingKeys.object.stringValue,
                     Source.CodingKeys.id.stringValue, Source.CodingKeys.flow.stringValue,
                     Source.CodingKeys.currency.stringValue, Source.CodingKeys.amount.stringValue,
                     "livemode", "location":
                    return false
                default: return true
                }
            }))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PaymentInformation.CodingKeys.self)
        try container.encode(type, forKey: .type)

        switch self {
        case .alipay(let alipay):
            try alipay.encode(to: encoder)
        case .other:
            break
        }
    }

    public static func == (lhs: PaymentInformation.Barcode, rhs: PaymentInformation.Barcode) -> Bool {
        switch (lhs, rhs) {
        case let (.alipay(lhsValue), .alipay(rhsValue)):
            return lhsValue == rhsValue
        case (.other(let lhsType, let lhsParameters), .other(let rhsType, let rhsParameters)):
            return lhsType == rhsType &&
                Set(lhsParameters.keys) == Set(rhsParameters.keys)
        default:
            return false
        }
    }
}

extension PaymentInformation.Points {
    /// Omise Source Type value using in the Omise API
    public var type: String {
        switch self {
        case .citiPoints:
            return SourceTypeValue.pointsCiti.rawValue
        case .other(let value):
            return PaymentInformation.Points.paymentMethodTypePrefix + value
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PaymentInformation.CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        guard type.hasPrefix(PaymentInformation.Points.paymentMethodTypePrefix),
            let typePrefixRange = type.range(of: PaymentInformation.Points.paymentMethodTypePrefix) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .type,
                    in: container,
                    debugDescription: "Invalid points payment source type value"
                )
        }

        switch type[typePrefixRange.upperBound...] {
        case "citi":
            self = .citiPoints
        case let value:
            self = .other(String(value))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PaymentInformation.CodingKeys.self)
        try container.encode(type, forKey: .type)
    }

}

extension PaymentInformation.MobileBanking: CaseIterable, CustomStringConvertible {
    public typealias AllCases = [PaymentInformation.MobileBanking]
    public static var allCases: PaymentInformation.MobileBanking.AllCases = [
        .scb, .kbank, .bay, .bbl, .ktb
    ]

    /// Omise Source Type value using in the Omise API
    public var type: String {
        switch self {
        case .scb:
            return SourceTypeValue.mobileBankingSCB.rawValue
        case .kbank:
            return SourceTypeValue.mobileBankingKBank.rawValue
        case .bay:
            return SourceTypeValue.mobileBankingBAY.rawValue
        case .bbl:
            return SourceTypeValue.mobileBankingBBL.rawValue
        case .ktb:
            return SourceTypeValue.mobileBankingKTB.rawValue
        case .other(let value):
            return PaymentInformation.MobileBanking.paymentMethodTypePrefix + value
        }
    }

    public var description: String {
        switch self {
        case .scb:
            return "SCB"
        case .kbank:
            return "KBank"
        case .bay:
            return "BAY"
        case .bbl:
            return "BBL"
        case .ktb:
            return "KTB"
        case .other(let value):
            return value
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PaymentInformation.CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        guard type.hasPrefix(PaymentInformation.MobileBanking.paymentMethodTypePrefix),
            let typePrefixRange = type.range(of: PaymentInformation.MobileBanking.paymentMethodTypePrefix) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .type,
                    in: container,
                    debugDescription: "Invalid mobile banking source type value"
                )
        }

        switch type[typePrefixRange.upperBound...] {
        case "scb":
            self = .scb
        case "kbank":
            self = .kbank
        case "bay":
            self = .bay
        case "bbl":
            self = .bbl
        case "ktb":
            self = .ktb
        case let value:
            self = .other(String(value))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PaymentInformation.CodingKeys.self)
        try container.encode(type, forKey: .type)
    }
}

extension PaymentInformation.DuitNowOBW.Bank: CaseIterable, CustomStringConvertible {
    public typealias AllCases = [PaymentInformation.DuitNowOBW.Bank]
    public static var allCases: PaymentInformation.DuitNowOBW.Bank.AllCases = [
        .affin, .alliance, .agro, .ambank, .cimb, .islam, .rakyat, .muamalat, .bsn,
        .hongleong, .hsbc, .kfh, .maybank2u, .ocbc, .publicBank, .rhb, .sc, .uob
    ]
    
    public var description: String {
        switch self {
        case .affin:
            return "affin"
        case .alliance:
            return "alliance"
        case .agro:
            return "agro"
        case .ambank:
            return "ambank"
        case .cimb:
            return "cimb"
        case .islam:
            return "islam"
        case .rakyat:
            return "rakyat"
        case .muamalat:
            return "muamalat"
        case .bsn:
            return "bsn"
        case .hongleong:
            return "hongleong"
        case .hsbc:
            return "hsbc"
        case .kfh:
            return "kfh"
        case .maybank2u:
            return "maybank2u"
        case .ocbc:
            return "ocbc"
        case .publicBank:
            return "public"
        case .rhb:
            return "rhb"
        case .sc:
            return "sc"
        case .uob:
            return "uob"
        case .other(let value):
            return value
        }
    }
}
