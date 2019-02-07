import Foundation


public struct Capability: Object {    
    public let location: String
    public let object: String
    
    public let supportedBanks: Set<String>
    public let chargeLimit: Limit
    public let transferLimit: Limit
    
    public let supportedBackends: [Backend]
    
    private let backends: [Capability.Backend.Key: Backend]
    
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
        
        let isValidValue = (backend.limit ?? lhs.chargeLimit) ~= rhs.amount
            && backend.supportedCurrencies.contains(rhs.currency)
        
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
    public struct Limit : Codable, Equatable, Hashable {
        public let max: Int64
        public let min: Int64
        
        public var range: ClosedRange<Int64> {
            return min...max
        }
        
        public init(min: Int64, max: Int64) {
            self.max = Swift.max(min, max)
            self.min = Swift.min(min, max)
        }
        
        public static func ~=(lhs: Capability.Limit, rhs: Int64) -> Bool {
            return lhs.min <= rhs && rhs <= lhs.max
        }
    }
    
    public struct Backend: Codable, Equatable {
        public let payment: Payment
        public let supportedCurrencies: Set<Currency>
        public let limit: Limit?
        
        public enum Payment : Equatable {
            case card(Set<CardBrand>)
            case installment(PaymentInformation.Installment.Brand, availableNumberOfTerms: IndexSet)
            case internetBanking(PaymentInformation.InternetBanking)
            case alipay
            case unknownSource(String, configurations: [String: Any])
        }
    }
}


extension Capability: Codable {
    private enum CodingKeys: String, CodingKey {
        case object
        case location
        case supportedBanks = "banks"
        case limits
        case paymentBackends = "payment_backends"
    }
    
    private enum LimitCodingKeys: String, CodingKey {
        case charge = "charge_amount"
        case transfer = "transfer_amount"
    }
}


extension Capability.Backend {
    private enum CodingKeys: String, CodingKey {
        case type
        case supportedCurrencies = "currencies"
        case limit = "amount"
    }
    
    private enum ConfigurationCodingKeys: String, CodingKey {
        case allowedInstallmentTerms = "allowed_installment_terms"
        case brands
    }
}

extension Capability.Backend.Payment {
    public static func == (lhs: Capability.Backend.Payment, rhs: Capability.Backend.Payment) -> Bool {
        switch (lhs, rhs) {
        case (.card, .card), (.alipay, .alipay):
            return true
        case (.installment(let lhsValue), .installment(let rhsValue)):
            return lhsValue == rhsValue
        case (.internetBanking(let lhsValue), .internetBanking(let rhsValue)):
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
        
        let limitsContainer = try container.nestedContainer(keyedBy: LimitCodingKeys.self, forKey: .limits)
        chargeLimit = try limitsContainer.decode(Limit.self, forKey: .charge)
        transferLimit = try limitsContainer.decode(Limit.self, forKey: .transfer)
        
        var backendsContainer = try container.nestedUnkeyedContainer(forKey: .paymentBackends)
        
        var backends: Array<Capability.Backend> = []
        while !backendsContainer.isAtEnd {
            backends.append(try backendsContainer.decode(Capability.Backend.self))
        }
        self.supportedBackends = backends
        
        self.backends = Dictionary(uniqueKeysWithValues: zip(backends.map({ Capability.Backend.Key(payment: $0.payment) }), backends))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(location, forKey: .location)
        try container.encode(object, forKey: .object)
        
        try container.encode(supportedBanks, forKey: .supportedBanks)
        
        var limitsContainer = container.nestedContainer(keyedBy: LimitCodingKeys.self, forKey: .limits)
        try limitsContainer.encode(chargeLimit, forKey: .charge)
        try limitsContainer.encode(transferLimit, forKey: .transfer)
        
        var backendsContainer = container.nestedUnkeyedContainer(forKey: .paymentBackends)
        try supportedBackends.forEach({ backend in
            try backendsContainer.encode(backend)
        })
    }
}

extension Capability.Backend {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Capability.Backend.Key.self)
        
        guard let sourceTypeKey = container.allKeys.first else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid backend type")
            )
        }
        
        let backendConfigurations = try container.nestedContainer(keyedBy: Capability.Backend.CodingKeys.self, forKey: sourceTypeKey)
        supportedCurrencies = try backendConfigurations.decode(Set<Currency>.self, forKey: .supportedCurrencies)
        limit = try backendConfigurations.decodeIfPresent(Capability.Limit.self, forKey: .limit)
        
        let type = try backendConfigurations.decode(String.self, forKey: .type)
        guard sourceTypeKey.type == type else {
            throw DecodingError.dataCorruptedError(
                forKey: Capability.Backend.CodingKeys.type, in: backendConfigurations,
                debugDescription: "Invalid payment backend type value"
            )
        }
        
        switch sourceTypeKey {
        case .card:
            let paymentConfigurations = try container.nestedContainer(keyedBy: Capability.Backend.ConfigurationCodingKeys.self, forKey: sourceTypeKey)
            let supportedBrand = try paymentConfigurations.decode(Set<CardBrand>.self, forKey: .brands)
            self.payment = .card(supportedBrand)
        case .source(let value) where value.isInstallmentSource:
            let paymentConfigurations = try container.nestedContainer(keyedBy: Capability.Backend.ConfigurationCodingKeys.self, forKey: sourceTypeKey)
            let allowedInstallmentTerms = IndexSet(try paymentConfigurations.decode(Array<Int>.self, forKey: .allowedInstallmentTerms))
            self.payment = .installment(value.installmentBrand!, availableNumberOfTerms: allowedInstallmentTerms)
        case .source(.alipay):
            self.payment = .alipay
        case .source(let value) where value.isInternetBankingSource:
            self.payment = .internetBanking(value.internetBankingSource!)
        case .source(let value):
            let configurations = try container.nestedContainer(keyedBy: SkippingKeyCodingKeys<Capability.Backend.CodingKeys>.self, forKey: sourceTypeKey).decodeJSONDictionary()
            self.payment = .unknownSource(value.rawValue, configurations: configurations)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Capability.Backend.Key.self)
        
        let sourceTypeKey = Capability.Backend.Key(payment: self.payment)
        
        switch payment {
        case .card(let brands):
            var paymentConfigurations = container.nestedContainer(keyedBy: CombineCodingKeys<Capability.Backend.CodingKeys, Capability.Backend.ConfigurationCodingKeys>.self, forKey: sourceTypeKey)
            try paymentConfigurations.encode(brands, forKey: .right(.brands))
            
            try paymentConfigurations.encode(Array(supportedCurrencies), forKey: .left(.supportedCurrencies))
            try paymentConfigurations.encodeIfPresent(limit, forKey: .left(.limit))
            try paymentConfigurations.encode(sourceTypeKey.stringValue, forKey: .left(.type))
        case .installment(_, availableNumberOfTerms: let availableNumberOfTerms):
            var paymentConfigurations = container.nestedContainer(keyedBy: CombineCodingKeys<Capability.Backend.CodingKeys, Capability.Backend.ConfigurationCodingKeys>.self, forKey: sourceTypeKey)
            try paymentConfigurations.encode(Array(availableNumberOfTerms), forKey: .right(.allowedInstallmentTerms))
            
            try paymentConfigurations.encode(Array(supportedCurrencies), forKey: .left(.supportedCurrencies))
            try paymentConfigurations.encodeIfPresent(limit, forKey: .left(.limit))
            try paymentConfigurations.encode(sourceTypeKey.stringValue, forKey: .left(.type))
        case .unknownSource(_, configurations: let configurations):
            var configurationContainers = container.nestedContainer(keyedBy: CombineCodingKeys<Capability.Backend.CodingKeys, JSONCodingKeys>.self, forKey: sourceTypeKey)
            try configurations.forEach({ (key, value) in
                let key = JSONCodingKeys(key: key)
                switch value {
                case let value as Bool:
                    try configurationContainers.encode(value, forKey: .right(key))
                case let value as Int:
                    try configurationContainers.encode(value, forKey: .right(key))
                case let value as String:
                    try configurationContainers.encode(value, forKey: .right(key))
                case let value as Double:
                    try configurationContainers.encode(value, forKey: .right(key))
                case let value as Dictionary<String, Any>:
                    try configurationContainers.encode(value, forKey: .right(key))
                case let value as Array<Any>:
                    try configurationContainers.encode(value, forKey: .right(key))
                case Optional<Any>.none:
                    try configurationContainers.encodeNil(forKey: .right(key))
                default:
                    throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: configurationContainers.codingPath + [key], debugDescription: "Invalid JSON value"))
                }
            })

            try configurationContainers.encode(Array(supportedCurrencies), forKey: .left(.supportedCurrencies))
            try configurationContainers.encodeIfPresent(limit, forKey: .left(.limit))
            try configurationContainers.encode(sourceTypeKey.stringValue, forKey: .left(.type))
        case .internetBanking, .alipay:
            var backendConfigurations = container.nestedContainer(keyedBy: Capability.Backend.CodingKeys.self, forKey: sourceTypeKey)
            
            try backendConfigurations.encode(Array(supportedCurrencies), forKey: .supportedCurrencies)
            try backendConfigurations.encodeIfPresent(limit, forKey: .limit)
            try backendConfigurations.encode(sourceTypeKey.stringValue, forKey: .type)
        }
    }
}


private let creditCardBackendTypeValue = "credit_card"
extension Capability.Backend {
    fileprivate enum Key : CodingKey, Hashable {
        case card
        case source(OMSSourceTypeValue)
        
        var stringValue: String {
            switch self {
            case .card:
                return creditCardBackendTypeValue
            case .source(let sourceType):
                return sourceType.rawValue
            }
        }
        
        init?(stringValue: String) {
            switch stringValue {
            case creditCardBackendTypeValue:
                self = .card
            case let value:
                self = .source(OMSSourceTypeValue(value))
            }
        }
        
        var intValue: Int? { return nil }
        init?(intValue: Int) { return nil }
        
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
            case .unknownSource(let sourceType, configurations: _):
                self = .source(.init(sourceType))
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

