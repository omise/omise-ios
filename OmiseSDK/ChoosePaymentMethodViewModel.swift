import Foundation

/// Contains properties and functions to generate data for ViewController and process user actions that requires data processing or screen navigation
class ChoosePaymentMethodViewModel: ViewAttachable {
    typealias ViewContext = TableCellContext
    private var usePaymentMethodsFromCapability = true
    private var allowedPaymentMethods: [SourceType] = []
    private var allowedCardPayment = false
    private var client: Client?

    /// Payment method options used in UI mapped from SourceType
    private var paymentMethods: [PaymentMethod] = [] {
        didSet {
            onPaymentMethodsUpdated(createViewContexts())
        }
    }

    /// Returns payment method at given index
    func paymentMethod(at index: Int) -> PaymentMethod? {
        paymentMethods.at(index)
    }

    /// Should be used to reload UI on payment methods list changed
    /// Instantly calls on assign
    var onPaymentMethodsUpdated: ([ViewContext]) -> Void = { _ in } {
        didSet {
            onPaymentMethodsUpdated(createViewContexts())
        }
    }

    /// Setup payment information, Payment Methods will be taken from Capability API
    func setupCapabilityPaymentMethods(client: Client) {
        self.client = client
        self.usePaymentMethodsFromCapability = true
    }

    /// Setup payment information with given list of Payment Methods and allowedCardPayment flag
    func setupAllowedPaymentMethods(_ allowedPaymentMethods: [SourceType], allowedCardPayment: Bool, client: Client) {
        self.client = client
        self.allowedPaymentMethods = allowedPaymentMethods
        self.allowedCardPayment = allowedCardPayment
        self.usePaymentMethodsFromCapability = false
    }

    func reloadPaymentMethods() {
        if usePaymentMethodsFromCapability {
            if let latestLoadedCapability = client?.latestLoadedCapability {
                paymentMethods = PaymentMethod.createPaymentMethods(with: latestLoadedCapability)
            } else {
                loadCapabilities()
            }
        } else {
            paymentMethods = PaymentMethod.createPaymentMethods(from: allowedPaymentMethods, showsCreditCard: allowedCardPayment)
        }
    }

    func showsActivityForSelectedPaymentMethod(at index: Int) -> Bool {
        guard let payment = paymentMethods.at(index) else {
            return false
        }
        return !payment.requiresAdditionalDetails
    }
}

// MARK: Private
private extension ChoosePaymentMethodViewModel {
    func createViewContexts() -> [ViewContext] {
        paymentMethods.map { payment in
            ViewContext(
                icon: payment.listIcon,
                title: payment.localizedTitle,
                accessoryIcon: payment.accessoryIcon
            )
        }
    }

    /// Loads Payment Methods from Capability API
    func loadCapabilities() {
        guard let client = client, usePaymentMethodsFromCapability else {
            return
        }

        client.capability { [weak self] result in
            if let capability = try? result.get() {
                self?.paymentMethods = PaymentMethod.createPaymentMethods(with: capability)
            }
        }
    }
}

extension PaymentMethod {
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

    static func createViewContexts(from paymentMethods: [PaymentMethod]) -> [TableCellContext] {
        let viewContexts = paymentMethods.map {
            TableCellContext(icon: $0.listIcon, title: $0.localizedTitle, accessoryIcon: $0.accessoryIcon)
        }

        return viewContexts
    }
}
