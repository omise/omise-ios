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

    var listIcon: UIImage? {
        return UIImage(omise: iconName)
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
            return UIImage(omise: "Next")
        } else {
            return UIImage(omise: "Redirect")
        }
    }
}
