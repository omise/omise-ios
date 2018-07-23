import Foundation


public protocol PaymentMethod: Equatable, Codable {
    static var paymentMethodTypePrefix: String { get }
    var type: String { get }
}

func ~=<T: PaymentMethod>(methodType: T.Type, type: String) -> Bool {
    return type.hasPrefix(methodType.paymentMethodTypePrefix)
}


public enum PaymentInformation: Codable, Equatable {

    public enum InternetBanking: PaymentMethod {
        public static let paymentMethodTypePrefix: String = "internet_banking_"
        
        case bay
        case ktb
        case scb
        case bbl
        case other(String)
    }
    case internetBanking(InternetBanking)
    
    case alipay
    
    public enum BillPayment: PaymentMethod {
        public static let paymentMethodTypePrefix: String = "bill_payment_"
        
        case tescoLotus
        case other(String)
    }
    
    case billPayment(BillPayment)
    
    public enum Barcode: PaymentMethod {
        public static let paymentMethodTypePrefix: String = "barcode_"
        
        case alipay(AlipayBarcode)
        case other(String, parameters: [String: Any])
        
        public var type: String {
            switch self {
            case .alipay:
                return Barcode.paymentMethodTypePrefix + "alipay"
            case .other(let value, _):
                return Barcode.paymentMethodTypePrefix + value
            }
        }
        
    }
    case barcode(Barcode)
    
    public struct Installment: PaymentMethod {
        public static let paymentMethodTypePrefix: String = "installment_"
        
        public enum Brand: Equatable {
            case bay
            case firstChoice
            case bbl
            case ktc
            case kBank
            case other(String)
        }
        
        public let brand: Brand
        public let numberOfTerms: Int
        
        public static func availableTerms(for brand: Brand) -> IndexSet {
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
                return IndexSet()
            }
        }
    }
    case installment(Installment)
    
    case other(type: String, parameters: [String: Any])
    
    
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
        case "alipay":
            self = .alipay
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
            try container.encode("alipay", forKey: .type)
        case .other(type: let type, parameters: let parameters):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            try encoder.encodeJSONDictionary(parameters)
        }
    }
    
    fileprivate enum CodingKeys: String, CodingKey {
        case type
    }
    
    public static func == (lhs: PaymentInformation, rhs: PaymentInformation) -> Bool {
        switch (lhs, rhs) {
        case (.internetBanking(let lhsValue), .internetBanking(let rhsValue)):
            return lhsValue == rhsValue
        case (.alipay, .alipay):
            return true
        case (.billPayment(let lhsValue), .billPayment(let rhsValue)):
            return lhsValue == rhsValue
        case (.barcode(let lhsValue), .barcode(let rhsValue)):
            return lhsValue == rhsValue
        case (.installment(let lhsValue), .installment(let rhsValue)):
            return lhsValue == rhsValue
        case (.other(let lhsType, let lhsParameters), .other(let rhsType, let rhsParameters)):
            return lhsType == rhsType &&
                Set(lhsParameters.keys) == Set(rhsParameters.keys)
        default: return false
        }
    }
    
}


extension Request where T == Source {
    public init (sourceType: PaymentInformation, amount: Int64, currency: Currency) {
        self.init(parameter: CreateSourceParameter(
            paymentInformation: sourceType,
            amount: amount, currency: currency)
        )
    }
}


extension PaymentInformation {
    public var sourceType: String {
        switch self {
        case .alipay:
            return "alipay"
        case .barcode(let barcode):
            return barcode.type
        case .billPayment(let billPayment):
            return billPayment.type
        case .installment(let installment):
            return installment.type
        case .internetBanking(let bank):
            return bank.type
        case .other(let value, _):
            return value
        }
    }
}


extension PaymentInformation.InternetBanking {
    
    public var type: String {
        switch self {
        case .bay:
            return PaymentInformation.InternetBanking.paymentMethodTypePrefix + "bay"
        case .ktb:
            return PaymentInformation.InternetBanking.paymentMethodTypePrefix + "ktb"
        case .scb:
            return PaymentInformation.InternetBanking.paymentMethodTypePrefix + "scb"
        case .bbl:
            return PaymentInformation.InternetBanking.paymentMethodTypePrefix + "bbl"
        case .other(let value):
            return PaymentInformation.InternetBanking.paymentMethodTypePrefix + value
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
    
    public var type: String {
        switch brand {
        case .bay:
            return PaymentInformation.Installment.paymentMethodTypePrefix + "bay"
        case .firstChoice:
            return PaymentInformation.Installment.paymentMethodTypePrefix + "first_choice"
        case .bbl:
            return PaymentInformation.Installment.paymentMethodTypePrefix + "bbl"
        case .ktc:
            return PaymentInformation.Installment.paymentMethodTypePrefix + "ktc"
        case .kBank:
            return PaymentInformation.Installment.paymentMethodTypePrefix + "kbank"
        case .other(let value):
            return PaymentInformation.Installment.paymentMethodTypePrefix + value
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case installmentTerms = "installment_terms"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PaymentInformation.CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        guard type.hasPrefix(PaymentInformation.InternetBanking.paymentMethodTypePrefix),
            let typePrefixRange = type.range(of: PaymentInformation.InternetBanking.paymentMethodTypePrefix) else {
                throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid internet banking source type value")
        }
        
        let brand: Brand
        switch type[typePrefixRange.upperBound...] {
        case "bay":
            brand = .bay
        case "firstChoice":
            brand = .firstChoice
        case "bbl":
            brand = .bbl
        case "ktc":
            brand = .ktc
        case "kBank":
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
    }
}

extension PaymentInformation.BillPayment {
    
    public var type: String {
        switch self {
        case .tescoLotus:
            return PaymentInformation.BillPayment.paymentMethodTypePrefix + "tesco_lotus"
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
    public struct AlipayBarcode: Codable, Equatable {
        public let barcode: String
        
        public struct StoreInformation: Codable, Equatable {
            public let storeID: String
            public let storeName: String
            
            public init(storeID: String, storeName: String) {
                self.storeID = storeID
                self.storeName = storeName
            }
        }
        
        public let storeInformation: StoreInformation?
        
        public var storeID: String? {
            return storeInformation?.storeID
        }
        
        public var storeName: String? {
            return storeInformation?.storeName
        }
        
        public let terminalID: String?
        private enum CodingKeys: String, CodingKey {
            case barcode
            case storeID = "store_id"
            case storeName = "store_name"
            case terminalID = "terminal_id"
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
        
        public init(barcode: String, storeInformation: StoreInformation?, terminalID: String?) {
            self.storeInformation = storeInformation
            self.terminalID = terminalID
            self.barcode = barcode
        }
        
        public init(barcode: String, storeID: String, storeName: String, terminalID: String?) {
            self.init(barcode: barcode, storeInformation: StoreInformation(storeID: storeID, storeName: storeName), terminalID: terminalID)
        }
        
        public init(barcode: String, terminalID: String?) {
            self.init(barcode: barcode, storeInformation: nil, terminalID: terminalID)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PaymentInformation.CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        guard type.hasPrefix(PaymentInformation.Barcode.paymentMethodTypePrefix),
            let typePrefixRange = type.range(of: PaymentInformation.Barcode.paymentMethodTypePrefix) else {
                throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid barcode source type value")
        }
        switch type[typePrefixRange.upperBound...] {
        case "alipay":
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

