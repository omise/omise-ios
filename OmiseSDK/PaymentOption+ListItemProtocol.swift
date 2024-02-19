import Foundation

extension ChoosePaymentMethodViewModel.PaymentMethod: CustomStringConvertible {
    var description: String { localizedTitle }
}

extension ChoosePaymentMethodViewModel.PaymentMethod: ListItemProtocol {
    /// Localized title for given payment option
    public var localizedTitle: String {
        let prefixCode = "paymentMethod"
        switch self {
        case .creditCard:
            return localized("\(prefixCode).creditCard", text: "Credit Card")
        case .installment:
            return localized("\(prefixCode).installments", text: "Installments")
        case .internetBanking:
            return localized("\(prefixCode).internetBanking", text: "Internet Banking")
        case .mobileBanking:
            return localized("\(prefixCode).mobileBanking", text: "Mobile Banking")
        case .eContextConbini:
            return localized("\(prefixCode).eContext.conbini", text: "Conbini")
        case .eContextPayEasy:
            return localized("\(prefixCode).eContext.payEasy", text: "PayEasy")
        case .eContextNetBanking:
            return localized("\(prefixCode).eContext.netBanking", text: "NetBanking")
        case .sourceType(let sourceType):
            return sourceType.localizedTitle
        }
    }

    /// icon for given payment option
    public var iconName: String {
        switch self {
        case .creditCard: return "Card"
        case .installment: return "Installment"
        case .internetBanking: return "Banking"
        case .mobileBanking: return "MobileBanking"
        case .eContextConbini: return "Conbini"
        case .eContextPayEasy: return "Payeasy"
        case .eContextNetBanking: return "Netbank"
        case .sourceType(let sourceType): return sourceType.iconName
        }
    }
}
