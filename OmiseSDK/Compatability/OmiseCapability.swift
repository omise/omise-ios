import Foundation


@objc(OMSCapability) public
class __OmiseCapability: NSObject {
    let capability: Capability
    
    @objc lazy public var location: String = capability.location
    @objc lazy public var object: String = capability.object
    
    @objc lazy public var supportedBanks: Set<String> = capability.supportedBanks
    
    @objc lazy public var supportedBackends: [__OmiseCapabilityBackend] =
        capability.supportedBackends.map(__OmiseCapabilityBackend.init)
    
    init(capability: Capability) {
        self.capability = capability
    }
}


@objc(OMSCapabilityBackend) public
class __OmiseCapabilityBackend: NSObject {
    private let backend: Capability.Backend
    
    @objc lazy public var payment: __OmiseCapabilityBackendPayment =
        __OmiseCapabilityBackendPayment.makeCapabilityBackend(from: backend.payment)
    @objc lazy public var supportedCurrencyCodes: Set<String> = Set(backend.supportedCurrencies.map({ $0.code }))
    
    required init(_ backend: Capability.Backend) {
        self.backend = backend
    }
}

@objc(OMSCapabilityBackendPayment) public
class __OmiseCapabilityBackendPayment: NSObject {}


@objc(OMSCapabilityCardBackend) public
class __OmiseCapabilityCardBackendPayment: __OmiseCapabilityBackendPayment {
    @objc public let supportedBrands: Set<String>
    
    init(supportedBrands: Set<String>) {
        self.supportedBrands = supportedBrands
    }
}

@objc(OMSCapabilitySourceBackend) public
class __OmiseCapabilitySourceBackendPayment: __OmiseCapabilityBackendPayment {
    @objc public let type: OMSSourceTypeValue
    
    init(sourceType: OMSSourceTypeValue) {
        self.type = sourceType
    }
    
    static let alipaySourceBackendPayment =
        __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.alipay)

    static let promptpaySourceBackendPayment =
    __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.promptPay)
    
    static let paynowSourceBackendPayment =
    __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.payNow)
    
    static let truemoneySourceBackendPayment =
    __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.trueMoney)
    
    static let cityPointsSourceBackendPayment =
    __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.pointsCiti)
    
    static let eContextSourceBackendPayment =
    __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.eContext)
    
    static func makeInternetBankingSourceBackendPayment(
        bank: PaymentInformation.InternetBanking
        ) -> __OmiseCapabilitySourceBackendPayment {
        return __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue(bank.type))
    }
}

@objc(OMSCapabilityInstallmentBackend) public
class __OmiseCapabilityInstallmentBackendPayment: __OmiseCapabilitySourceBackendPayment {
    @objc public let availableNumberOfTerms: IndexSet
    
    init(sourceType: OMSSourceTypeValue, availableNumberOfTerms: IndexSet) {
        self.availableNumberOfTerms = availableNumberOfTerms
        super.init(sourceType: sourceType)
    }
}

@objc(OMSCapabilityUnknownSourceBackend) public
class __OmiseCapabilityUnknownSourceBackendPayment: __OmiseCapabilitySourceBackendPayment {
    @objc public let parameters: [String: Any]
    init(sourceType: String, parameters: [String: Any]) {
        self.parameters = parameters
        super.init(sourceType: OMSSourceTypeValue(rawValue: sourceType))
    }
}

extension __OmiseCapabilityBackendPayment {
    static func makeCapabilityBackend(from payment: Capability.Backend.Payment) -> __OmiseCapabilityBackendPayment {
        switch payment {
        case .card(let brands):
            return __OmiseCapabilityCardBackendPayment(supportedBrands: Set(brands.map({ $0.description })))
        case .installment(let brand, availableNumberOfTerms: let availableNumberOfTerms):
            return __OmiseCapabilityInstallmentBackendPayment(
                sourceType: OMSSourceTypeValue(brand.type), availableNumberOfTerms: availableNumberOfTerms
            )
        case .internetBanking(let bank):
            return __OmiseCapabilitySourceBackendPayment.makeInternetBankingSourceBackendPayment(bank: bank)
        case .billPayment(let billPayment):
            return __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue(billPayment.type))
        case .alipay:
            return __OmiseCapabilitySourceBackendPayment.alipaySourceBackendPayment
        case .promptpay:
            return __OmiseCapabilitySourceBackendPayment.promptpaySourceBackendPayment
        case .paynow:
            return __OmiseCapabilitySourceBackendPayment.paynowSourceBackendPayment
        case .truemoney:
            return __OmiseCapabilitySourceBackendPayment.truemoneySourceBackendPayment
        case .points(let points):
            return __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue(points.type))
        case .eContext:
            return __OmiseCapabilitySourceBackendPayment.eContextSourceBackendPayment
        case .unknownSource(let type, let configurations):
            return __OmiseCapabilityUnknownSourceBackendPayment(sourceType: type, parameters: configurations)
        }
    }
}

