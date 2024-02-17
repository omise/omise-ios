import Foundation

class ChoosePaymentMethodViewModel {
    enum Completion {
        case paymentSelected(PaymentOption)
        case cancelled
    }

    typealias ViewContext = ChoosePaymentMethodController.ViewContext

    var flowSession: PaymentCreatorFlowSession?

    var amount: Int64 = 0
    var currency: String = ""

    var usePaymentMethodsFromCapability = false
    var allowedPaymentMethods: [SourceType] = []
    var showsCreditCardPayment = false
    var client: Client?
    var completion: (Completion) -> Void = { _ in }

    private var paymentOptions: [PaymentOption] = []
    var onViewContextChanged: ([ViewContext]) -> Void = { _ in }
    private var viewContexts: [ViewContext] = [] {
        didSet {
            onViewContextChanged(viewContexts)
        }
    }

    var numberOfViewContexts: Int {
        return viewContexts.count
    }

    func viewContext(at index: Int) -> ViewContext? {
        guard index < viewContexts.count, index >= 0 else {
            return nil
        }
        return viewContexts[index]
    }

    private func loadCapabilities() {
        guard let client = client, usePaymentMethodsFromCapability else {
            return
        }

        client.capability { [weak self] _ in
            self?.updateViewContexts()
        }

        if client.latestLoadedCapability != nil {
            updateViewContexts()
        }
    }

    func didSelect(index: Int) {
        if let payment = paymentOptions.at(index) {
            completion(.paymentSelected(payment))
        }
    }

    func reload() {
        if usePaymentMethodsFromCapability {
            loadCapabilities()
        }

        updateViewContexts()
    }
}

private extension ChoosePaymentMethodViewModel {

    func updateViewContexts() {
        if usePaymentMethodsFromCapability {
            guard let capability = client?.latestLoadedCapability else {
                return
            }

            let capabilitySourceTypes = capability.paymentMethods.compactMap {
                SourceType(rawValue: $0.name)
            }

            let showsCreditCard = capability.cardPaymentMethod != nil
            print("showsCreditCard: \(showsCreditCard)")
            self.viewContexts = generateViewContexts(from: capabilitySourceTypes, showsCreditCard: showsCreditCard)
        } else {
            print("2. showsCreditCard: \(showsCreditCardPayment)")
            self.viewContexts = generateViewContexts(from: allowedPaymentMethods, showsCreditCard: showsCreditCardPayment)
        }
    }

    func generateViewContexts(from sourceTypes: [SourceType], showsCreditCard: Bool) -> [ViewContext] {
        var list = PaymentOption.from(sourceTypes)

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
        list = PaymentOption.sorted(from: list)

        paymentOptions = list

        let viewContexts = list.map {
            ViewContext(icon: $0.listIcon, title: $0.localizedTitle, accessoryIcon: $0.accessoryIcon)
        }

        return viewContexts
    }
}
