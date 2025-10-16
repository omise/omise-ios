import Foundation
import UIKit

enum PaymentMethod: CaseIterable, Equatable, Hashable {
    case creditCard
    case installment
    case mobileBanking
    case eContextConbini
    case eContextNetBanking
    case eContextPayEasy
    case sourceType(_ type: SourceType)

    var sourceType: SourceType? {
        switch self {
        case .sourceType(let sourceType):
            return sourceType
        default:
            return nil
        }
    }

    static var allCases: [PaymentMethod] = from(sourceTypes: SourceType.allCases)

    /// List of payment methods to be placed above other payment methods in a given order
    static let topList: [PaymentMethod] = [
        .creditCard,
        .sourceType(.payNow),
        .sourceType(.promptPay),
        .sourceType(.trueMoneyWallet),
        .sourceType(.trueMoneyJumpApp),
        .mobileBanking,
        .sourceType(.alipay),
        .installment,
        .sourceType(.ocbcDigital),
        .sourceType(.rabbitLinepay),
        .sourceType(.shopeePay),
        .sourceType(.shopeePayJumpApp),
        .sourceType(.alipayCN),
        .sourceType(.alipayHK)
    ]

    var requiresAdditionalDetails: Bool {
        switch self {
        case .creditCard,
                .installment,
                .mobileBanking,
                .eContextConbini,
                .eContextPayEasy,
                .eContextNetBanking,
                .sourceType(.atome),
                .sourceType(.barcodeAlipay),
                .sourceType(.duitNowOBW),
                .sourceType(.fpx),
                .sourceType(.trueMoneyWallet),
                .sourceType(.applePay):
            return true
        default:
            return false
        }
    }
}

extension PaymentMethod {
    /// Creates a list of Payment Options with given list of Source Type
    static func from(sourceTypes: [SourceType]) -> [Self] {
        var list = Set<PaymentMethod>()
        for sourceType in sourceTypes {
            paymentMethods(for: sourceType).forEach {
                list.insert($0)
            }
        }
        return Array(list)
    }

    static func paymentMethods(for sourceType: SourceType) -> [PaymentMethod] {
        switch sourceType {
        case _ where sourceType.isInstallment:
            return [.installment]
        case _ where sourceType.isMobileBanking:
            return [.mobileBanking]
        case .eContext:
            return [.eContextConbini, .eContextNetBanking, .eContextPayEasy]
        case .barcodeAlipay:
            return []
        default:
            return [.sourceType(sourceType)]
        }
    }

    /// List of payment methods in localized alphabetical order
    static func alphabetical(from: [PaymentMethod]) -> [PaymentMethod] {
        from.sorted {
            $0.description.localizedCaseInsensitiveCompare($1.description) == .orderedAscending
        }
    }

    static func topListed(from: [PaymentMethod]) -> [PaymentMethod] {
        var source = from
        var sorted = [PaymentMethod]()
        for top in topList where source.contains(top) {
            sorted.append(top)
            source.removeAll { $0 == top }
        }
        sorted.append(contentsOf: source)
        return sorted
    }

    /// Sorted list of all payment methods
    static func sorted(from: [PaymentMethod]) -> [PaymentMethod] {
        topListed(from: alphabetical(from: from))
    }

    /// Generates Payment Methods with given Capability
    static func createPaymentMethods(with capability: Capability) -> [PaymentMethod] {
        let sourceTypes = capability.paymentMethods.compactMap {
            SourceType(rawValue: $0.name)
        }

        let showsCreditCard = capability.cardPaymentMethod != nil
        let paymentMethods = createPaymentMethods(from: sourceTypes, showsCreditCard: showsCreditCard)
        return paymentMethods
    }

    /// Generates PaymenOption list with given list of SourceType and allowedCardPayment option
    static func createPaymentMethods(from sourceTypes: [SourceType], showsCreditCard: Bool) -> [PaymentMethod] {
        var list = PaymentMethod.from(sourceTypes: sourceTypes)

        if showsCreditCard {
            list.append(.creditCard)
        }

        // Remove .trueMoneyWallet if .trueMoneyJumpApp is present
        if list.contains(.sourceType(.trueMoneyJumpApp)) {
            list.removeAll { $0 == .sourceType(.trueMoneyWallet) }
        }

        // Remove .shopeePay if .shopeePayJumpApp is present
        if list.contains(.sourceType(.shopeePayJumpApp)) {
            list.removeAll { $0 == .sourceType(.shopeePay) }
        }

        // Sort and filter
        list = PaymentMethod.sorted(from: list)
        return list
    }
}

extension PaymentMethod {
    static func createViewContexts(from paymentMethods: [PaymentMethod]) -> [TableCellContext] {
        let viewContexts = paymentMethods.map {
            TableCellContext(
                title: $0.localizedTitle,
                subtitle: $0.localizedSubtitle,
                icon: UIImage(omise: $0.iconName),
                accessoryIcon: UIImage($0.accessoryIcon)
            )
        }

        return viewContexts
    }
}
