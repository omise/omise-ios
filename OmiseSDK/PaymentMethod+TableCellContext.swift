import Foundation

extension PaymentMethod {
    static func paymentOptions(for sourceType: SourceType) -> [PaymentMethod] {
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
    static func from(sourceTypes: [SourceType]) -> [Self] {
        var list = Set<PaymentMethod>()
        for sourceType in sourceTypes {
            paymentOptions(for: sourceType).forEach {
                list.insert($0)
            }
        }
        return Array(list)
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
}
