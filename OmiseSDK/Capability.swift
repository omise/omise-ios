// swiftlint:disable file_length
import Foundation

public struct Capability: Object {
    public let countryCode: String
    public let location: String
    public let object: String

    public let supportedBanks: Set<String>

    public let supportedBackends: [Backend]

    private let backends: [Capability.Backend.BackendType: Backend]

    public var creditCardBackend: Capability.Backend? {
        return backends[.card]
    }

    public subscript(type: SourceTypeValue) -> Capability.Backend? {
        return backends[.source(type)]
    }
}

extension Capability {
    public static func ~= (lhs: Capability, rhs: CreateSourceParameter) -> Bool {
        func backend(from capability: Capability, for payment: PaymentInformation) -> Backend? {
            if let paymentSourceType = SourceTypeValue(payment.sourceType) {
                return capability[paymentSourceType]
            } else {
                return nil
            }
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
        public let banks: [Bank]?

        public enum Payment: Equatable {
            case card(Set<CardBrand>)
            case installment(PaymentInformation.Installment.Brand, availableNumberOfTerms: IndexSet)
            case internetBanking(PaymentInformation.InternetBanking)
            case mobileBanking(PaymentInformation.MobileBanking)
            case billPayment(PaymentInformation.BillPayment)
            case alipay
            case alipayCN
            case alipayHK
            case atome
            case dana
            case gcash
            case kakaoPay
            case touchNGoAlipayPlus
            case touchNGo
            case promptpay
            case paynow
            case truemoney
            case truemoneyJumpApp
            case points(PaymentInformation.Points)
            case eContext
            case fpx
            case rabbitLinepay
            case ocbcPao
            case ocbcDigital
            case grabPay
            case grabPayRms
            case boost
            case shopeePay
            case shopeePayJumpApp
            case maybankQRPay
            case duitNowQR
            case duitNowOBW
            case payPay
            case weChat
            case unknownSource(String, configurations: [String: Any])
        }

        public struct Bank: Codable, Equatable {
            // swiftlint:disable:next nesting
            enum CodingKeys: String, CodingKey {
                case name, code
                case isActive = "active"
            }

            public let name: String
            public let code: String
            public let isActive: Bool
        }
    }
}

extension Capability: Codable {
    private enum CodingKeys: String, CodingKey {
        case countryCode = "country"
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
        case banks
        case provider
    }
}

extension Capability.Backend.Payment {
    // swiftlint:disable:next function_body_length
    public static func == (lhs: Capability.Backend.Payment, rhs: Capability.Backend.Payment) -> Bool {
        switch (lhs, rhs) {
        case (.card, .card), (.alipay, .alipay), (.alipayCN, .alipayCN), (.alipayHK, .alipayHK):
            return true
        case (.atome, .atome):
            return true
        case (.dana, .dana), (.gcash, .gcash), (.kakaoPay, .kakaoPay), (.touchNGoAlipayPlus, .touchNGoAlipayPlus):
            return true
        case (.touchNGo, .touchNGo):
            return true
        case (.promptpay, .promptpay), (.paynow, .paynow):
            return true
        case (.truemoney, .truemoney):
            return true
        case (.eContext, .eContext):
            return true
        case (.points(let lhsValue), .points(let rhsValue)):
            return lhsValue == rhsValue
        case (.installment(let lhsValue, _), .installment(let rhsValue, _)):
            return lhsValue == rhsValue
        case (.internetBanking(let lhsValue), .internetBanking(let rhsValue)):
            return lhsValue == rhsValue
        case (.mobileBanking(let lhsValue), .mobileBanking(let rhsValue)):
            return lhsValue == rhsValue
        case (.billPayment(let lhsValue), .billPayment(let rhsValue)):
            return lhsValue == rhsValue
        case (.fpx, .fpx):
            return true
        case (.rabbitLinepay, .rabbitLinepay):
            return true
        case (.ocbcPao, .ocbcPao):
            return true
        case (.ocbcDigital, .ocbcDigital):
            return true
        case (.grabPay, .grabPay):
            return true
        case (.grabPayRms, .grabPayRms):
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
        case (.duitNowOBW, .duitNowOBW):
            return true
        case (.payPay, .payPay):
            return true
        case (.weChat, .weChat):
            return true
        default:
            return false
        }
    }
}

extension Capability {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        location = try container.decode(String.self, forKey: .location)
        countryCode = try container.decode(String.self, forKey: .countryCode)
        object = try container.decode(String.self, forKey: .object)

        supportedBanks = try container.decode(Set<String>.self, forKey: .supportedBanks)

        var backendsContainer = try container.nestedUnkeyedContainer(forKey: .paymentBackends)

        var backends: [Capability.Backend] = []
        
        while !backendsContainer.isAtEnd {
            let backend = try backendsContainer.decode(Capability.Backend.self)
            backends.append(backend)
        }

        self.supportedBackends = backends

        let backendTypes = backends.compactMap { Capability.Backend.BackendType(payment: $0.payment) }
        self.backends = Dictionary(uniqueKeysWithValues: zip(backendTypes, backends))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(location, forKey: .location)
        try container.encode(countryCode, forKey: .countryCode)
        try container.encode(object, forKey: .object)

        try container.encode(supportedBanks, forKey: .supportedBanks)

        var backendsContainer = container.nestedUnkeyedContainer(forKey: .paymentBackends)
        try supportedBackends.forEach { backend in
            try backendsContainer.encode(backend)
        }
    }
}

extension Capability.Backend {
    // swiftlint:disable:next function_body_length
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let type = try container.decode(BackendType.self, forKey: .name)
        let provider = try container.decodeIfPresent(Provider.self, forKey: .provider)
        supportedCurrencies = try container.decode(Set<Currency>.self, forKey: .supportedCurrencies)

        switch type {
        case .unknown(let sourceType):
            self.payment = .unknownSource(sourceType, configurations: [:])
        case .card:
            let supportedBrand = try container.decode(Set<CardBrand>.self, forKey: .cardBrands)
            self.payment = .card(supportedBrand)
        case .source(let value) where value.isInstallmentSource:
            let allowedInstallmentTerms = IndexSet(try container.decode(Array<Int>.self, forKey: .allowedInstallmentTerms))
            // swiftlint:disable:next force_unwrapping
            self.payment = .installment(value.installmentBrand!, availableNumberOfTerms: allowedInstallmentTerms)
        case .source(.alipay):
            self.payment = .alipay
        case .source(.alipayCN):
            self.payment = .alipayCN
        case .source(.alipayHK):
            self.payment = .alipayHK
        case .source(.atome):
            self.payment = .atome
        case .source(.dana):
            self.payment = .dana
        case .source(.gcash):
            self.payment = .gcash
        case .source(.kakaoPay):
            self.payment = .kakaoPay
        case .source(.touchNGo):
            switch provider {
            case .alipayPlus:
                self.payment = .touchNGoAlipayPlus
            default:
                self.payment = .touchNGo
            }
        case .source(let value) where value.isInternetBankingSource:
            // swiftlint:disable:next force_unwrapping
            self.payment = .internetBanking(value.internetBankingSource!)
        case .source(let value) where value.isMobileBankingSource:
            // swiftlint:disable:next force_unwrapping
            self.payment = .mobileBanking(value.mobileBankingSource!)
        case .source(.promptPay):
            self.payment = .promptpay
        case .source(.payNow):
            self.payment = .paynow
        case .source(.trueMoney):
            self.payment = .truemoney
        case .source(.trueMoneyJumpApp):
            self.payment = .truemoneyJumpApp
        case .source(.pointsCiti):
            self.payment = .points(.citiPoints)
        case .source(.billPaymentTescoLotus):
            self.payment = .billPayment(.tescoLotus)
        case .source(.eContext):
            self.payment = .eContext
        case .source(.fpx):
            self.payment = .fpx
        case .source(.rabbitLinepay):
            self.payment = .rabbitLinepay
        case .source(.mobileBankingOCBCPAO):
            self.payment = .ocbcPao
        case .source(.mobileBankingOCBC):
            self.payment = .ocbcDigital
        case .source(.grabPay):
            switch provider {
            case .rms:
                self.payment = .grabPayRms
            default:
                self.payment = .grabPay
            }
        case .source(.boost):
            self.payment = .boost
        case .source(.shopeePay):
            self.payment = .shopeePay
        case .source(.shopeePayJumpApp):
            self.payment = .shopeePayJumpApp
        case .source(.maybankQRPay):
            self.payment = .maybankQRPay
        case .source(.duitNowQR):
            self.payment = .duitNowQR
        case .source(.duitNowOBW):
            self.payment = .duitNowOBW
        case .source(.payPay):
            self.payment = .payPay
        case .source(.weChat):
            self.payment = .weChat
        case .source(let value):
            let configurations = try container.decodeJSONDictionary()
            self.payment = .unknownSource(value.rawValue, configurations: configurations)
        }

        banks = try? container.decode([Bank].self, forKey: .banks)
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
        case .internetBanking, .alipay, .alipayCN, .alipayHK, .atome, .dana, .gcash, .kakaoPay, .touchNGoAlipayPlus, .touchNGo, .promptpay, .paynow, .truemoney, .truemoneyJumpApp, .points, .billPayment, .eContext, .mobileBanking, .fpx, .rabbitLinepay, .ocbcPao, .ocbcDigital, .grabPay, .grabPayRms, .boost, .shopeePay, .shopeePayJumpApp, .maybankQRPay, .duitNowQR, .duitNowOBW, .payPay, .weChat:
            // swiftlint:disable:previous line_length
            try container.encode(Array(supportedCurrencies), forKey: .supportedCurrencies)
        case .unknownSource(_, configurations: let configurations):
            try encoder.encodeJSONDictionary(configurations)
            try container.encode(Array(supportedCurrencies), forKey: .supportedCurrencies)
        }
    }
}

private let creditCardBackendTypeValue = "card"
extension Capability.Backend {
    fileprivate enum BackendType: Codable, Hashable {
        case card
        case source(SourceTypeValue)
        case unknown(sourceType: String)

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            switch try container.decode(String.self) {
            case creditCardBackendTypeValue:
                self = .card
            case let value:
                if let sourceType = SourceTypeValue(value) {
                    self = .source(sourceType)
                } else {
                    self = .unknown(sourceType: value)
                }
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            let type: String
            switch self {
            case .unknown(let sourceType):
                type = sourceType
            case .card:
                type = creditCardBackendTypeValue
            case .source(let sourceType):
                type = sourceType.rawValue
            }

            try container.encode(type)
        }

        init?(sourceType string: String) {
            if let sourceType = SourceTypeValue(string) {
                self = .source(sourceType)
            } else {
                return nil
            }
        }

        // swiftlint:disable:next function_body_length
        init?(payment: Capability.Backend.Payment) {
            switch payment {
            case .card:
                self = .card
            case .alipay:
                self = .source(.alipay)
            case .alipayCN:
                self = .source(.alipayCN)
            case .alipayHK:
                self = .source(.alipayHK)
            case .atome:
                self = .source(.atome)
            case .dana:
                self = .source(.dana)
            case .gcash:
                self = .source(.gcash)
            case .kakaoPay:
                self = .source(.kakaoPay)
            case .touchNGoAlipayPlus:
                self = .source(.touchNGoAlipayPlus)
            case .touchNGo:
                self = .source(.touchNGo)
            case .installment(let brand, availableNumberOfTerms: _):
                self.init(sourceType: brand.type)
            case .internetBanking(let banking):
                self.init(sourceType: banking.type)
            case .mobileBanking(let banking):
                self.init(sourceType: banking.type)
            case .billPayment(let billPayment):
                self.init(sourceType: billPayment.type)
            case .promptpay:
                self = .source(.promptPay)
            case .paynow:
                self = .source(.payNow)
            case .truemoney:
                self = .source(.trueMoney)
            case .truemoneyJumpApp:
                self = .source(.trueMoneyJumpApp)
            case .points(let points):
                self.init(sourceType: points.type)
            case .eContext:
                self = .source(.eContext)
            case .fpx:
                self = .source(.fpx)
            case .rabbitLinepay:
                self = .source(.rabbitLinepay)
            case .ocbcPao:
                self = .source(.mobileBankingOCBCPAO)
            case .ocbcDigital:
                self = .source(.mobileBankingOCBC)
            case .grabPay:
                self = .source(.grabPay)
            case .grabPayRms:
                self = .source(.grabPayRms)
            case .boost:
                self = .source(.boost)
            case .shopeePay:
                self = .source(.shopeePay)
            case .shopeePayJumpApp:
                self = .source(.shopeePayJumpApp)
            case .maybankQRPay:
                self = .source(.maybankQRPay)
            case .duitNowQR:
                self = .source(.duitNowQR)
            case .duitNowOBW:
                self = .source(.duitNowOBW)
            case .payPay:
                self = .source(.payPay)
            case .weChat:
                self = .source(.weChat)
            case .unknownSource(let sourceType, configurations: _):
                self.init(sourceType: sourceType)
            }
        }

        var type: String {
            switch self {
            case .unknown(let sourceType):
                return sourceType
            case .card:
                return "card"
            case .source(let sourceType):
                let sourceTypeValuePrefix = sourceType.sourceTypePrefix
                if sourceTypeValuePrefix.hasSuffix("_") {
                    return sourceTypeValuePrefix
                        .lastIndex(of: "_")
                        .map(sourceTypeValuePrefix.prefix(upTo:))
                        .map(String.init) ?? sourceTypeValuePrefix
                } else {
                    return sourceTypeValuePrefix
                }
            }
        }
    }
}

extension Capability.Backend {
    fileprivate enum Provider: String, Codable, Hashable {
        case alipayPlus = "Alipay_plus"
        case rms = "RMS"
    }
}
