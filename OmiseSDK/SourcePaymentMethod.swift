import Foundation


public protocol PaymentMethod: Equatable, Codable {
    static var paymentMethodTypePrefix: String { get }
    var type: String { get }
}

func ~=<T: PaymentMethod>(methodType: T.Type, type: String) -> Bool {
    return type.hasPrefix(methodType.paymentMethodTypePrefix)
}


/// Represents the payment information of a Source
public enum PaymentInformation: Codable, Equatable {

    /// The code of the bank for the Internet Bankning Payment
    public enum InternetBanking: PaymentMethod {
        public static let paymentMethodTypePrefix: String = "internet_banking_"
        
        case bay
        case ktb
        case scb
        case bbl
        case other(String)
    }
    /// Internet Banking Payment Source
    case internetBanking(InternetBanking)
    
    /// Online Alipay Payment Source
    case alipay
    
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
                return OMSSourceTypeValue.barcodeAlipay.rawValue
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
            case ktc
            case kBank
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
            case .ktc:
                return IndexSet([ 3, 4, 5, 6, 7, 8, 9, 10 ])
            case .kBank:
                return IndexSet([ 3, 4, 6, 10 ])
            case .other:
                return IndexSet(1...60)
            }
        }
        
        init(brand: Brand, numberOfTerms: Int) {
            self.brand = brand
            self.numberOfTerms = numberOfTerms
        }
    }
    /// Installments Payment Source
    case installment(Installment)
    
    /// The EContext customer information
    public struct EContext: PaymentMethod, Codable, Equatable {
        public static var paymentMethodTypePrefix: String = OMSSourceTypeValue.eContext.rawValue
        
        public let type: String = OMSSourceTypeValue.eContext.rawValue
        
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
    
    /// The TrueMoney customer information
    public struct TrueMoney: PaymentMethod {
        
        public static var paymentMethodTypePrefix: String = OMSSourceTypeValue.trueMoney.rawValue
        
        public var type: String = OMSSourceTypeValue.trueMoney.rawValue
        
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
    
    /// The name of the supported services to process the Points Payment
    public enum Points: PaymentMethod {
        public static let paymentMethodTypePrefix: String = "points_"
        
        case citiPoints
        case other(String)
    }
    
    /// Points Payment Source
    case points(Points)
    
    /// Other Payment Source
    case other(type: String, parameters: [String: Any])
    
    
    fileprivate enum CodingKeys: String, CodingKey {
        case type
    }
    
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
        case OMSSourceTypeValue.alipay.rawValue:
            self = .alipay
        case OMSSourceTypeValue.promptPay.rawValue:
            self = .promptpay
        case OMSSourceTypeValue.payNow.rawValue:
            self = .paynow
        case OMSSourceTypeValue.trueMoney.rawValue:
            self = .truemoney(try TrueMoney(from: decoder))
        case PaymentInformation.Points.self:
            self = .points(try Points(from: decoder))
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
            try container.encode(OMSSourceTypeValue.alipay.rawValue, forKey: .type)
        case .eContext(let eContext):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(OMSSourceTypeValue.eContext.rawValue, forKey: .type)
            try eContext.encode(to: encoder)
        case .promptpay:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(OMSSourceTypeValue.promptPay.rawValue, forKey: .type)
        case .paynow:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(OMSSourceTypeValue.payNow.rawValue, forKey: .type)
        case .truemoney(let trueMoney):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(OMSSourceTypeValue.trueMoney.rawValue, forKey: .type)
            try trueMoney.encode(to: encoder)
        case .points(let points):
            try points.encode(to: encoder)
        case .other(type: let type, parameters: let parameters):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            try encoder.encodeJSONDictionary(parameters)
        }
    }
    
    public static func == (lhs: PaymentInformation, rhs: PaymentInformation) -> Bool {
        switch (lhs, rhs) {
        case (.internetBanking(let lhsValue), .internetBanking(let rhsValue)):
            return lhsValue == rhsValue
        case (.alipay, .alipay):
            return true
        case (.promptpay, .promptpay), (.paynow, .paynow):
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
        self.init(parameter: CreateSourceParameter(
            paymentInformation: paymentInformation,
            amount: amount, currency: currency)
        )
    }
}


extension PaymentInformation {
    /// Omise Source Type value using in the Omise API
    public var sourceType: String {
        switch self {
        case .alipay:
            return OMSSourceTypeValue.alipay.rawValue
        case .barcode(let barcode):
            return barcode.type
        case .billPayment(let billPayment):
            return billPayment.type
        case .installment(let installment):
            return installment.type
        case .internetBanking(let bank):
            return bank.type
        case .eContext:
            return OMSSourceTypeValue.eContext.rawValue
        case .promptpay:
            return OMSSourceTypeValue.promptPay.rawValue
        case .paynow:
            return OMSSourceTypeValue.payNow.rawValue
        case .truemoney:
            return OMSSourceTypeValue.trueMoney.rawValue
        case .points(let points):
            return points.type
        case .other(let value, _):
            return value
        }
    }
}


extension PaymentInformation.InternetBanking : StaticElementIterable, CustomStringConvertible {
    public typealias AllCases = Array<PaymentInformation.InternetBanking>
    public static var allCases: PaymentInformation.InternetBanking.AllCases = [
        .bay, .ktb, .scb, .bbl
    ]
    
    /// Omise Source Type value using in the Omise API
    public var type: String {
        switch self {
        case .bay:
            return OMSSourceTypeValue.internetBankingBAY.rawValue
        case .ktb:
            return OMSSourceTypeValue.internetBankingKTB.rawValue
        case .scb:
            return OMSSourceTypeValue.internetBankingSCB.rawValue
        case .bbl:
            return OMSSourceTypeValue.internetBankingBBL.rawValue
        case .other(let value):
            return PaymentInformation.InternetBanking.paymentMethodTypePrefix + value
        }
    }
    
    public var description: String {
        switch self {
        case .bay:
            return "BAY"
        case .ktb:
            return "KTB"
        case .scb:
            return "SCB"
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
                throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid internet banking source type value")
        }
        
        switch type[typePrefixRange.upperBound...] {
        case "bay":
            self = .bay
        case "ktb":
            self = .ktb
        case "scb":
            self = .scb
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
            return OMSSourceTypeValue.installmentBAY.rawValue
        case .firstChoice:
            return OMSSourceTypeValue.installmentFirstChoice.rawValue
        case .bbl:
            return OMSSourceTypeValue.installmentBBL.rawValue
        case .ktc:
            return OMSSourceTypeValue.installmentKTC.rawValue
        case .kBank:
            return OMSSourceTypeValue.installmentKBank.rawValue
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
                throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid installments source type value")
        }
        
        let brand: Brand
        switch type[typePrefixRange.upperBound...] {
        case "bay":
            brand = .bay
        case "first_choice":
            brand = .firstChoice
        case "bbl":
            brand = .bbl
        case "ktc":
            brand = .ktc
        case "kbank":
            brand = .kBank
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

extension PaymentInformation.Installment.Brand : StaticElementIterable, CustomStringConvertible {
    public typealias AllCases = Array<PaymentInformation.Installment.Brand>
    public static var allCases: PaymentInformation.Installment.Brand.AllCases = [
        .bay, .firstChoice, .bbl, .ktc, .kBank
    ]
    
    public var description: String {
        switch self {
        case .bay:
            return "BAY"
        case .firstChoice:
            return "First Choice"
        case .bbl:
            return "BBL"
        case .ktc:
            return "KTC"
        case .kBank:
            return "K-Bank"
        case .other(let value):
            return value
        }
    }
    
    public var type: String {
        switch self {
        case .bay:
            return OMSSourceTypeValue.installmentBAY.rawValue
        case .firstChoice:
            return OMSSourceTypeValue.installmentFirstChoice.rawValue
        case .bbl:
            return OMSSourceTypeValue.installmentBBL.rawValue
        case .ktc:
            return OMSSourceTypeValue.installmentKTC.rawValue
        case .kBank:
            return OMSSourceTypeValue.installmentKBank.rawValue
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
            return OMSSourceTypeValue.billPaymentTescoLotus.rawValue
        case .other(let value):
            return PaymentInformation.BillPayment.paymentMethodTypePrefix + value
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PaymentInformation.CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        guard type.hasPrefix(PaymentInformation.BillPayment.paymentMethodTypePrefix),
            let typePrefixRange = type.range(of: PaymentInformation.BillPayment.paymentMethodTypePrefix) else {
                throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid bill payment source type value")
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
                throw DecodingError.keyNotFound(CodingKeys.storeID, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Alipay Barcode store name is present but store id informaiton is missing"))
            case (.some, nil):
                throw DecodingError.keyNotFound(CodingKeys.storeName, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Alipay Barcode store id is present but store name informaiton is missing"))
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
        case OMSSourceTypeValue.alipay.rawValue:
            self = .alipay(try AlipayBarcode.init(from: decoder))
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
    
    public static func ==(lhs: PaymentInformation.Barcode, rhs: PaymentInformation.Barcode) -> Bool {
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
            return OMSSourceTypeValue.pointsCiti.rawValue
        case .other(let value):
            return PaymentInformation.Points.paymentMethodTypePrefix + value
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PaymentInformation.CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        guard type.hasPrefix(PaymentInformation.Points.paymentMethodTypePrefix),
            let typePrefixRange = type.range(of: PaymentInformation.Points.paymentMethodTypePrefix) else {
                throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid points payment source type value")
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

