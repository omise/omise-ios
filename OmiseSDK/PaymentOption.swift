import Foundation
import UIKit

enum PaymentOption: CaseIterable, Equatable, Hashable {
    case creditCard
    case installment
    case internetBanking
    case mobileBanking
    case eContextConbini
    case eContextNetBanking
    case eContextPayEasy
    case sourceType(_ type: SourceType)

    static var allCases: [PaymentOption] = from()

    /// List of payment methods to be placed above other payment methods in a given order
    static let topList: [PaymentOption] = [
        .creditCard,
        .sourceType(.payNow),
        .sourceType(.promptPay),
        .sourceType(.trueMoneyWallet),
        .sourceType(.trueMoneyJumpApp),
        .mobileBanking,
        .internetBanking,
        .sourceType(.alipay),
        .installment,
        .sourceType(.ocbcDigital),
        .sourceType(.rabbitLinepay),
        .sourceType(.shopeePay),
        .sourceType(.shopeePayJumpApp),
        .sourceType(.alipayCN),
        .sourceType(.alipayHK)
    ]

    var listIcon: UIImage? {
        return UIImage(named: iconName, in: .omiseSDK, compatibleWith: nil)
    }

    var requiresAdditionalDetails: Bool {
        switch self {
        case .creditCard,
                .installment,
                .internetBanking,
                .mobileBanking,
                .eContextConbini,
                .eContextPayEasy,
                .eContextNetBanking,
                .sourceType(.atome),
                .sourceType(.barcodeAlipay),
                .sourceType(.duitNowOBW),
                .sourceType(.fpx),
                .sourceType(.trueMoneyWallet):
            return true
        default:
            return false
        }
    }

    var accessoryIcon: UIImage? {
        if requiresAdditionalDetails {
            return UIImage(named: "Next", in: .omiseSDK, compatibleWith: nil)
        } else {
            return UIImage(named: "Redirect", in: .omiseSDK, compatibleWith: nil)
        }
    }
}

extension PaymentOption {
    static func paymentOptions(for sourceType: SourceType) -> [PaymentOption] {
        switch sourceType {
        case _ where sourceType.isInstallment:
            return [.installment]
        case _ where sourceType.isInternetBanking:
            return [.internetBanking]
        case _ where sourceType.isMobileBanking:
            return [.mobileBanking]
        case .eContext:
            return [.eContextConbini, .eContextNetBanking, .eContextPayEasy]
        default:
            return [.sourceType(sourceType)]
        }
    }
    /// Creates a list of Payment Options with given list of Source Type
    static func from(_ sourceTypes: [SourceType] = SourceType.allCases) -> [Self] {
        var list = Set<PaymentOption>()
        for sourceType in sourceTypes {
            paymentOptions(for: sourceType).forEach {
                list.insert($0)
            }
        }
        return Array(list)
    }

    /// List of payment methods in localized alphabetical order
    static func alphabetical(from: [PaymentOption]) -> [PaymentOption] {
        from.sorted {
            $0.description.localizedCaseInsensitiveCompare($1.description) == .orderedAscending
        }
    }

    static func topListed(from: [PaymentOption]) -> [PaymentOption] {
        var source = from
        var sorted = [PaymentOption]()
        for top in topList where source.contains(top) {
            sorted.append(top)
            source.removeAll { $0 == top }
        }
        sorted.append(contentsOf: source)
        return sorted
    }

    /// Sorted list of all payment methods
    static func sorted(from: [PaymentOption]) -> [PaymentOption] {
        topListed(from: alphabetical(from: from))
    }
}
