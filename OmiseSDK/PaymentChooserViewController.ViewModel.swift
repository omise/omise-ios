import Foundation

extension PaymentChooserController {
    class ViewModel: PaymentSourceChooser {
        typealias ViewContext = PaymentChooserController.ViewContext
        var flowSession: PaymentCreatorFlowSession?

        var showsCreditCardPayment = true

        var allowedPaymentMethods: [SourceType] = [] {
            didSet {
                viewContexts = generateViewContexts(from: allowedPaymentMethods)
            }
        }

        func allowedPaymentMethods(from capability: Capability) {
            showsCreditCardPayment = capability.cardPaymentMethod != nil

            allowedPaymentMethods = capability.paymentMethods.compactMap {
                SourceType(rawValue: $0.name)
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


        init(flowSession: PaymentCreatorFlowSession? = nil, allowedPaymentMethods: [SourceType] = []) {
            self.flowSession = flowSession
            self.allowedPaymentMethods = allowedPaymentMethods
        }
    }
}

private extension PaymentChooserController.ViewModel {
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
