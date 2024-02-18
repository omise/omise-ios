import Foundation

enum ChoosePaymentMethodResult {
    case selectedPayment(ChoosePaymentMethodController.ViewModel.PaymentMethod)
    case cancelled
}

extension ChoosePaymentMethodController {
    /// Contains properties and functions to generate data for ViewController and process user actions that requires data processing or screen navigation
    class ViewModel {
        typealias ViewContext = ChoosePaymentMethodController.ViewContext

        private var amount: Int64 = 0
        private var currency: String = ""

        private var usePaymentMethodsFromCapability = true
        private var allowedPaymentMethods: [SourceType] = []
        private var allowedCardPayment = false
        private var client: Client?
        private var completionHandler: (ChoosePaymentMethodResult) -> Void = { _ in }
        private var paymentOptions: [PaymentMethod] = [] {
            didSet {
                onPaymentMethodChanged()
            }
        }

        /// Should be used to reload UI on payment methods list changed
        var onPaymentMethodChanged: () -> Void = { }

        /// Convenient setter to hide `completionHandler` from public access but still able to set it when it's required
        func completionHandler(_ completionHandler: @escaping (ChoosePaymentMethodResult) -> Void) {
            self.completionHandler = completionHandler
        }

        /// Setup payment information, Payment Methods will be taken from Capability API
        func setup(amount: Int64, currenct: String, client: Client) {
            self.amount = amount
            self.currency = currenct
            self.client = client
            self.usePaymentMethodsFromCapability = true
        }

        /// Setup payment information with given list of Payment Methods and allowedCardPayment flag
        func setupAllowedPaymentMethods(_ allowedPaymentMethods: [SourceType], allowedCardPayment: Bool, amount: Int64, currenct: String, client: Client) {
            self.amount = amount
            self.currency = currenct
            self.client = client
            self.allowedPaymentMethods = allowedPaymentMethods
            self.allowedCardPayment = allowedCardPayment
            self.usePaymentMethodsFromCapability = false
        }
    }

}

// MARK: View Controller accessible
extension ChoosePaymentMethodController.ViewModel {
    func reloadPaymentMethods() {
        if usePaymentMethodsFromCapability {
            if let latestLoadedCapability = client?.latestLoadedCapability {
                reload(with: latestLoadedCapability)
            } else {
                loadCapabilities()
            }
        } else {
            reload(with: allowedPaymentMethods, allowedCardPayment)
        }
    }

    var numberOfViewContexts: Int {
        return paymentOptions.count
    }

    func viewContext(at index: Int) -> ViewContext? {
        guard let payment = paymentOptions.at(index) else { return nil }
        return ViewContext(
            icon: payment.listIcon,
            title: payment.localizedTitle,
            accessoryIcon: payment.accessoryIcon
        )
    }

    /// Should be called when user select one of Payment Method in the list
    func didSelectPaymentMethod(at index: Int) {
        if let payment = paymentOptions.at(index) {
            completionHandler(.selectedPayment(payment))
        }
    }

    func showsActivityOnPaymentMethodSelected(at index: Int) -> Bool {
        guard let payment = paymentOptions.at(index) else {
            return false
        }
        return !payment.requiresAdditionalDetails
    }

    func didCancel() {
        completionHandler(.cancelled)
    }
}

// MARK: Private
private extension ChoosePaymentMethodController.ViewModel {
    /// Loads Payment Methods from Capability API
    func loadCapabilities() {
        guard let client = client, usePaymentMethodsFromCapability else {
            return
        }

        client.capability { [weak self] result in
            if let capability = try? result.get() {
                self?.reload(with: capability)
            }
        }
    }

    /// Generates Payment Methods with given Capability
    func reload(with capability: Capability) {
        let sourceTypes = capability.paymentMethods.compactMap {
            SourceType(rawValue: $0.name)
        }

        let showsCreditCard = capability.cardPaymentMethod != nil
        paymentOptions = createPaymentOptions(from: sourceTypes, showsCreditCard: showsCreditCard)
    }

    /// Generate Payment Methods with given list of SourceType and allowedCardPayment option
    func reload(with sourceTypes: [SourceType], _ cardPayment: Bool) {
        paymentOptions = createPaymentOptions(from: sourceTypes, showsCreditCard: cardPayment)
    }

    /// Generates PaymenOption list with given list of SourceType and allowedCardPayment option
    func createPaymentOptions(from sourceTypes: [SourceType], showsCreditCard: Bool) -> [PaymentMethod] {
        var list = PaymentMethod.from(sourceTypes)

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

    func createViewContexts(from paymentOptions: [PaymentMethod]) -> [ViewContext] {
        let viewContexts = paymentOptions.map {
            ViewContext(icon: $0.listIcon, title: $0.localizedTitle, accessoryIcon: $0.accessoryIcon)
        }

        return viewContexts
    }
}

