import Foundation


public struct Capability: Object {    
    public let location: String
    public let object: String
    
    public let supportedBanks: Set<String>
    
    public let supportedBackends: [Backend]
    
    private let backends: [Capability.Backend.BackendType: Backend]
    
    public var creditCardBackend: Capability.Backend? {
        return backends[.card]
    }
    
    public subscript(type: OMSSourceTypeValue) -> Capability.Backend? {
        return backends[.source(type)]
    }
}


extension Capability {
    public static func ~=(lhs: Capability, rhs: CreateSourceParameter) -> Bool {
        func backend(from capability: Capability, for payment: PaymentInformation) -> Backend? {
            let paymentSourceType = OMSSourceTypeValue(payment.sourceType)
            return capability[paymentSourceType]
        }
        
        guard let backend = backend(from: lhs, for: rhs.paymentInformation) else {
            return false
        }
        
        let isValidValue = backend.supportedCurrencies.contains(rhs.currency)
        
        let isPaymentValid: Bool
        switch backend.payment {
        case .installment(_, availableNumberOfTerms: let availableNumberofTerms):
            if case .installment(let installment) = rhs.paymentInformation {
                isPaymentValid = availableNumberofTerms.contains(installment.numberOfTerms)
            } else {
                isPaymentValid = false
            }
        default:
            isPaymentValid = true
        }
        
        return isValidValue && isPaymentValid
    }
}


extension Capability {
    
    public struct Backend: Codable, Equatable {
        public let payment: Payment
        public let supportedCurrencies: Set<Currency>
        
        public enum Payment : Equatable {
            case card(Set<CardBrand>)
            case installment(PaymentInformation.Installment.Brand, availableNumberOfTerms: IndexSet)
            case internetBanking(PaymentInformation.InternetBanking)
            case billPayment(PaymentInformation.BillPayment)
            case alipay
            case promptpay
            case paynow
            case truemoney
            case points(PaymentInformation.Points)
            case eContext
            case unknownSource(String, configurations: [String: Any])
        }
    }
}


extension Capability: Codable {
    private enum CodingKeys: String, CodingKey {
        case object
        case location
        case supportedBanks = "banks"
        case paymentBackends = "payment_methods"
    }
}


extension Capability.Backend {
    private enum CodingKeys: String, CodingKey {
        case object
        case name
        case supportedCurrencies = "currencies"
        case allowedInstallmentTerms = "installment_terms"
        case cardBrands = "card_brands"
    }
}

extension Capability.Backend.Payment {
    public static func == (lhs: Capability.Backend.Payment, rhs: Capability.Backend.Payment) -> Bool {
        switch (lhs, rhs) {
        case (.card, .card), (.alipay, .alipay):
            return true
        case (.promptpay, .promptpay), (.paynow, .paynow):
            return true
        case (.truemoney, .truemoney):
            return true
        case (.eContext, .eContext):
            return true
        case (.points(let lhsValue), .points(let rhsValue)):
            return lhsValue == rhsValue
        case (.installment(let lhsValue), .installment(let rhsValue)):
            return lhsValue == rhsValue
        case (.internetBanking(let lhsValue), .internetBanking(let rhsValue)):
            return lhsValue == rhsValue
        case (.billPayment(let lhsValue), .billPayment(let rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
    
}

extension Capability {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        location = try container.decode(String.self, forKey: .location)
        object = try container.decode(String.self, forKey: .object)
        
        supportedBanks = try container.decode(Set<String>.self, forKey: .supportedBanks)
        
        var backendsContainer = try container.nestedUnkeyedContainer(forKey: .paymentBackends)
        
        var backends: Array<Capability.Backend> = []
        while !backendsContainer.isAtEnd {
            backends.append(try backendsContainer.decode(Capability.Backend.self))
        }
        self.supportedBackends = backends
        
        self.backends = Dictionary(uniqueKeysWithValues: zip(backends.map({ Capability.Backend.BackendType(payment: $0.payment) }), backends))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(location, forKey: .location)
        try container.encode(object, forKey: .object)
        
        try container.encode(supportedBanks, forKey: .supportedBanks)
        
        var backendsContainer = container.nestedUnkeyedContainer(forKey: .paymentBackends)
        try supportedBackends.forEach({ backend in
            try backendsContainer.encode(backend)
        })
    }
}

extension Capability.Backend {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try container.decode(BackendType.self, forKey: .name)
        supportedCurrencies = try container.decode(Set<Currency>.self, forKey: .supportedCurrencies)

        switch type {
        case .card:
            let supportedBrand = try container.decode(Set<CardBrand>.self, forKey: .cardBrands)
            self.payment = .card(supportedBrand)
        case .source(let value) where value.isInstallmentSource:
            let allowedInstallmentTerms = IndexSet(try container.decode(Array<Int>.self, forKey: .allowedInstallmentTerms))
            self.payment = .installment(value.installmentBrand!, availableNumberOfTerms: allowedInstallmentTerms)
        case .source(.alipay):
            self.payment = .alipay
        case .source(let value) where value.isInternetBankingSource:
            self.payment = .internetBanking(value.internetBankingSource!)
        case .source(.promptPay):
            self.payment = .promptpay
        case .source(.payNow):
            self.payment = .paynow
        case .source(.trueMoney):
            self.payment = .truemoney
        case .source(.pointsCiti):
            self.payment = .points(.citiPoints)
        case .source(.billPaymentTescoLotus):
            self.payment = .billPayment(.tescoLotus)
        case .source(.eContext):
            self.payment = .eContext
        case .source(let value):
            let configurations = try container.decodeJSONDictionary()
            self.payment = .unknownSource(value.rawValue, configurations: configurations)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(BackendType(payment: payment), forKey: .name)
        
        switch payment {
        case .card(let brands):
            try container.encode(brands, forKey: .cardBrands)
            try container.encode(Array(supportedCurrencies), forKey: .supportedCurrencies)
        case .installment(_, availableNumberOfTerms: let availableNumberOfTerms):
            try container.encode(Array(availableNumberOfTerms), forKey: .allowedInstallmentTerms)
            try container.encode(Array(supportedCurrencies), forKey: .supportedCurrencies)
        case .unknownSource(_, configurations: let configurations):
            try encoder.encodeJSONDictionary(configurations)
            try container.encode(Array(supportedCurrencies), forKey: .supportedCurrencies)
        case .internetBanking, .alipay, .promptpay, .paynow, .truemoney, .points, .billPayment, .eContext:
            try container.encode(Array(supportedCurrencies), forKey: .supportedCurrencies)
        }
    }
}


private let creditCardBackendTypeValue = "card"
extension Capability.Backend {
    fileprivate enum BackendType: Codable, Hashable {
        case card
        case source(OMSSourceTypeValue)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            switch try container.decode(String.self) {
            case creditCardBackendTypeValue:
                self = .card
            case let value:
                self = .source(OMSSourceTypeValue(value))
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            let type: String
            switch self {
            case .card:
                type = creditCardBackendTypeValue
            case .source(let sourceType):
                type = sourceType.rawValue
            }

            try container.encode(type)
        }
        
        init(payment: Capability.Backend.Payment) {
            switch payment {
            case .card:
                self = .card
            case .alipay:
                self = .source(.alipay)
            case .installment(let brand, availableNumberOfTerms: _):
                self = .source(OMSSourceTypeValue(brand.type))
            case .internetBanking(let banking):
                self = .source(OMSSourceTypeValue(banking.type))
            case .billPayment(let billPayment):
                self = .source(OMSSourceTypeValue(billPayment.type))
            case .unknownSource(let sourceType, configurations: _):
                self = .source(.init(sourceType))
            case .promptpay:
                self = .source(.promptPay)
            case .paynow:
                self = .source(.payNow)
            case .truemoney:
                self = .source(.trueMoney)
            case .points(let points):
                self = .source(OMSSourceTypeValue(points.type))
            case .eContext:
                self = .source(.eContext)
            }
        }
        
        var type: String {
            switch self {
            case .card:
                return "card"
            case .source(let sourceType):
                let sourceTypeValuePrefix = sourceType.sourceTypePrefix
                if sourceTypeValuePrefix.hasSuffix("_") {
                    return sourceTypeValuePrefix.lastIndex(of: "_").map(sourceTypeValuePrefix.prefix(upTo:)).map(String.init) ?? sourceTypeValuePrefix
                } else {
                    return sourceTypeValuePrefix
                }
            }
        }
    }
}

