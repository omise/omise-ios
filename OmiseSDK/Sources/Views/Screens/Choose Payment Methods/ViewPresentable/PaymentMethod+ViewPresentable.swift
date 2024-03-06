import Foundation

extension PaymentMethod: CustomStringConvertible {
    var description: String { localizedTitle }
}

extension PaymentMethod: ViewPresentable {
    /// Localized title for given payment option
    public var localizedSubtitle: String? {
        if case .sourceType(let sourceType) = self {
            return sourceType.localizedSubtitle
        } else {
            return nil
        }
    }

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
            return localized("\(prefixCode).eContext.conbini", text: "Konbini")
        case .eContextPayEasy:
            return localized("\(prefixCode).eContext.payEasy", text: "Pay-easy")
        case .eContextNetBanking:
            return localized("\(prefixCode).eContext.netBanking", text: "Net Bank")
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
        case .eContextConbini: return "Konbini"
        case .eContextPayEasy: return "Payeasy"
        case .eContextNetBanking: return "Netbank"
        case .sourceType(let sourceType): return sourceType.iconName
        }
    }

    var accessoryIcon: Assets.Icon {
        requiresAdditionalDetails ? Assets.Icon.next : Assets.Icon.redirect
    }
}
