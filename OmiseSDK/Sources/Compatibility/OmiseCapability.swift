import Foundation

@objc(OMSCapability)
// swiftlint:disable:next attributes type_name
public class __OmiseCapability: NSObject {
    let capability: Capability

    @objc public lazy var location: String = capability.location
    @objc public lazy var object: String = capability.object

    @objc public lazy var supportedBanks: Set<String> = capability.supportedBanks

    @objc public lazy var supportedBackends: [__OmiseCapabilityBackend] =
        capability.supportedBackends.map(__OmiseCapabilityBackend.init)

    init(capability: Capability) {
        self.capability = capability
    }
}

@objc(OMSCapabilityBackend)
// swiftlint:disable:next attributes type_name
public class __OmiseCapabilityBackend: NSObject {
    private let backend: Capability.Backend

    @objc public lazy var payment: __OmiseCapabilityBackendPayment =
        __OmiseCapabilityBackendPayment.makeCapabilityBackend(from: backend.payment)
    @objc public lazy var supportedCurrencyCodes: Set<String> = Set(backend.supportedCurrencies.map { $0.code })

    required init(_ backend: Capability.Backend) {
        self.backend = backend
    }
}

@objc(OMSCapabilityBackendPayment)
// swiftlint:disable:next attributes type_name
public class __OmiseCapabilityBackendPayment: NSObject {}

@objc(OMSCapabilityCardBackend)
// swiftlint:disable:next attributes type_name
public class __OmiseCapabilityCardBackendPayment: __OmiseCapabilityBackendPayment {
    @objc public let supportedBrands: Set<String>

    init(supportedBrands: Set<String>) {
        self.supportedBrands = supportedBrands
    }
}

@objc(OMSCapabilitySourceBackend)
// swiftlint:disable:next attributes type_name
public class __OmiseCapabilitySourceBackendPayment: __OmiseCapabilityBackendPayment {
    public let type: OMSSourceTypeValue

    init(sourceType: OMSSourceTypeValue) {
        self.type = sourceType
    }

    static let alipaySourceBackendPayment =
        __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.alipay)

    static let alipayCNSourceBackendPayment =
        __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.alipayCN)

    static let alipayHKSourceBackendPayment =
        __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.alipayHK)
    
    static let atomeSourceBackendPayment =
        __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.atome)

    static let danaSourceBackendPayment =
        __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.dana)

    static let gcashSourceBackendPayment =
        __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.gcash)

    static let kakaoPaySourceBackendPayment =
        __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.kakaoPay)

    static let touchNGoSourceBackendPayment =
        __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.touchNGo)

    static let promptpaySourceBackendPayment =
    __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.promptPay)

    static let paynowSourceBackendPayment =
    __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.payNow)

    static let truemoneySourceBackendPayment =
    __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.trueMoney)

    static let truemoneyJumpAppSourceBackendPayment =
    __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.trueMoneyJumpApp)

    static let cityPointsSourceBackendPayment =
    __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.pointsCiti)

    static let eContextSourceBackendPayment =
    __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.eContext)

    static let FPXSourceBackendPayment =
        __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.fpx)
    
    static let rabbitLinepaySourceBackendPayment =
        __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.rabbitLinepay)
    
    static let ocbcDigitalSourceBackendPayment =
        __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.mobileBankingOCBC)

    static let grabPaySourceBackendPayment =
        __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.grabPay)

    static let boostSourceBackendPayment =
        __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.boost)

    static let shopeePaySourceBackendPayment =
        __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.shopeePay)
    
    static let shopeePayJumpAppSourceBackendPayment =
        __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.shopeePayJumpApp)

    static let maybankQRPaySourceBackendPayment =
        __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.maybankQRPay)

    static let duitNowQRSourceBackendPayment =
        __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.duitNowQR)

    static let duitNowOBWSourceBackendPayment =
        __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.duitNowOBW)
    
    static let payPaySourceBackendPayment =
    __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.payPay)

    static let weChatSourceBackendPayment =
    __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue.weChat)

    static func makeInternetBankingSourceBackendPayment(
        bank: PaymentInformation.InternetBanking
        ) -> __OmiseCapabilitySourceBackendPayment {
        return __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue(bank.type))
    }

    static func makeMobileBankingSourceBackendPayment(
        bank: PaymentInformation.MobileBanking
        ) -> __OmiseCapabilitySourceBackendPayment {
        return __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue(bank.type))
    }
}

@objc(OMSCapabilityInstallmentBackend)
// swiftlint:disable:next attributes type_name
public class __OmiseCapabilityInstallmentBackendPayment: __OmiseCapabilitySourceBackendPayment {
    @objc public let availableNumberOfTerms: IndexSet

    init(sourceType: OMSSourceTypeValue, availableNumberOfTerms: IndexSet) {
        self.availableNumberOfTerms = availableNumberOfTerms
        super.init(sourceType: sourceType)
    }
}

@objc(OMSCapabilityUnknownSourceBackend)
// swiftlint:disable:next attributes type_name
public class __OmiseCapabilityUnknownSourceBackendPayment: __OmiseCapabilitySourceBackendPayment {
    @objc public let parameters: [String: Any]
    init(sourceType: String, parameters: [String: Any]) {
        self.parameters = parameters
        super.init(sourceType: OMSSourceTypeValue(sourceType))
    }
}

extension __OmiseCapabilityBackendPayment {
    // swiftlint:disable:next function_body_length
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
        case .mobileBanking(let bank):
            return __OmiseCapabilitySourceBackendPayment.makeMobileBankingSourceBackendPayment(bank: bank)
        case .billPayment(let billPayment):
            return __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue(billPayment.type))
        case .alipay:
            return __OmiseCapabilitySourceBackendPayment.alipaySourceBackendPayment
        case .alipayCN:
            return __OmiseCapabilitySourceBackendPayment.alipayCNSourceBackendPayment
        case .alipayHK:
            return __OmiseCapabilitySourceBackendPayment.alipayHKSourceBackendPayment
        case .atome:
            return __OmiseCapabilitySourceBackendPayment.atomeSourceBackendPayment
        case .dana:
            return __OmiseCapabilitySourceBackendPayment.danaSourceBackendPayment
        case .gcash:
            return __OmiseCapabilitySourceBackendPayment.gcashSourceBackendPayment
        case .kakaoPay:
            return __OmiseCapabilitySourceBackendPayment.kakaoPaySourceBackendPayment
        case .touchNGoAlipayPlus, .touchNGo:
            return __OmiseCapabilitySourceBackendPayment.touchNGoSourceBackendPayment
        case .promptpay:
            return __OmiseCapabilitySourceBackendPayment.promptpaySourceBackendPayment
        case .paynow:
            return __OmiseCapabilitySourceBackendPayment.paynowSourceBackendPayment
        case .truemoney:
            return __OmiseCapabilitySourceBackendPayment.truemoneySourceBackendPayment
        case .truemoneyJumpApp:
            return __OmiseCapabilitySourceBackendPayment.truemoneyJumpAppSourceBackendPayment
        case .points(let points):
            return __OmiseCapabilitySourceBackendPayment(sourceType: OMSSourceTypeValue(points.type))
        case .eContext:
            return __OmiseCapabilitySourceBackendPayment.eContextSourceBackendPayment
        case .fpx:
            return __OmiseCapabilitySourceBackendPayment.FPXSourceBackendPayment
        case .rabbitLinepay:
            return __OmiseCapabilitySourceBackendPayment.rabbitLinepaySourceBackendPayment
        case .ocbcDigital:
            return __OmiseCapabilitySourceBackendPayment.ocbcDigitalSourceBackendPayment
        case .grabPay, .grabPayRms:
            return __OmiseCapabilitySourceBackendPayment.grabPaySourceBackendPayment
        case .boost:
            return __OmiseCapabilitySourceBackendPayment.boostSourceBackendPayment
        case .shopeePay:
            return __OmiseCapabilitySourceBackendPayment.shopeePaySourceBackendPayment
        case .shopeePayJumpApp:
            return __OmiseCapabilitySourceBackendPayment.shopeePayJumpAppSourceBackendPayment
        case .maybankQRPay:
            return __OmiseCapabilitySourceBackendPayment.maybankQRPaySourceBackendPayment
        case .duitNowQR:
            return __OmiseCapabilitySourceBackendPayment.duitNowQRSourceBackendPayment
        case .duitNowOBW:
            return __OmiseCapabilitySourceBackendPayment.duitNowOBWSourceBackendPayment
        case .payPay:
            return __OmiseCapabilitySourceBackendPayment.payPaySourceBackendPayment
        case .weChat:
            return __OmiseCapabilitySourceBackendPayment.weChatSourceBackendPayment
        case .unknownSource(let type, let configurations):
            return __OmiseCapabilityUnknownSourceBackendPayment(sourceType: type, parameters: configurations)
        }
    }
}
