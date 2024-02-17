import Foundation

class ChoosePaymentMethodViewModel {
    typealias ViewContext = ChoosePaymentMethodController.ViewContext

    var flowSession: PaymentCreatorFlowSession?
    var showsCreditCardPayment = true
    var paymentAmount: Int64 = 0
    var paymentCurrency: String = ""

    var completion: PaymentResultClosure = { _ in }
    var usePaymentMethodsFromCapability: Bool = false {
        didSet {
            if usePaymentMethodsFromCapability {
                loadCapabilities()
            }
        }
    }
    var client: Client? {
        didSet {
            if usePaymentMethodsFromCapability {
                loadCapabilities()
            }
        }
    }

    var allowedPaymentMethods: [SourceType] = [] {
        didSet {
            viewContexts = generateViewContexts(from: allowedPaymentMethods)
        }
    }

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

    func loadCapabilities() {
        guard let client = client, usePaymentMethodsFromCapability else {
            return
        }

        if let capability = client.latestLoadedCapability {
            allowedPaymentMethods(from: capability)
        }
        client.capability { [weak self] result in
            if let capability = try? result.get() {
                self?.allowedPaymentMethods(from: capability)
            }
        }
    }

    func allowedPaymentMethods(from capability: Capability) {
        showsCreditCardPayment = capability.cardPaymentMethod != nil

        allowedPaymentMethods = capability.paymentMethods.compactMap {
            SourceType(rawValue: $0.name)
        }
    }
}

private extension ChoosePaymentMethodViewModel {
    func generateViewContexts(from sourceTypes: [SourceType]) -> [ViewContext] {
        var list = PaymentOption.from(sourceTypes)

        if showsCreditCardPayment {
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

        let viewContexts = list.map {
            ViewContext(icon: $0.listIcon, title: $0.localizedTitle, accessoryIcon: $0.accessoryIcon)
        }

        return viewContexts
    }
}
