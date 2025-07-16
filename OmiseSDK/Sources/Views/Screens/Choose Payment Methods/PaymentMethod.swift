import Foundation
import UIKit

enum PaymentMethod: CaseIterable, Equatable, Hashable {
    case creditCard
    case installment
    case internetBanking
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
        case _ where sourceType.isInternetBanking:
            return [.internetBanking]
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
}
