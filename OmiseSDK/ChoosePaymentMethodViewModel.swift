import Foundation

class ChoosePaymentMethodViewModel {
    let client: Client

    private var viewOnDataReloadHandler: () -> Void = { } {
        didSet {
            viewOnDataReloadHandler()
        }
    }

//    var onPaymentMethodsReloadHandler: () -> Void = {} {
//        didSet {
//            onPaymentMethodsReloadHandler()
//        }
//    }

    private var paymentMethods: [PaymentMethod] = [] {
        didSet {
//            onPaymentMethodsReloadHandler()
            viewOnDataReloadHandler()
        }
    }

    init(client: Client, allowedPaymentMethods: [SourceType], isCardEnabled: Bool, useCapability: Bool) {
        self.client = client

        if useCapability {
            setupCapability()
        } else {
            self.paymentMethods = PaymentMethod.createPaymentMethods(
                from: allowedPaymentMethods,
                showsCreditCard: isCardEnabled
            )
        }
    }

    private func setupCapability() {
        var allowedPaymentMethods: [SourceType] = []
        var isCardEnabled = false

        if let capability = client.latestLoadedCapability {
            isCardEnabled = capability.cardPaymentMethod != nil
            allowedPaymentMethods = capability.paymentMethods.compactMap {
                SourceType(rawValue: $0.name)
            }
        } else {
            client.capability { [weak self] result in
                if let capability = try? result.get() {
                    self?.paymentMethods = PaymentMethod.createPaymentMethods(with: capability)
                }
            }
        }

        self.paymentMethods = PaymentMethod.createPaymentMethods(
            from: allowedPaymentMethods,
            showsCreditCard: isCardEnabled
        )
    }

    func paymentMethod(at index: Int) -> PaymentMethod? {
        paymentMethods.at(index)
    }

}

extension ChoosePaymentMethodViewModel: PaymentListViewModelProtocol {
    func viewOnDataReloadHandler(_ handler: @escaping () -> Void) {
        self.viewOnDataReloadHandler = handler
    }
    
    var numberOfViewContexts: Int {
        paymentMethods.count
    }
    
    var viewNavigationTitle: String {
        localized("paymentMethods.title", text: "Payment Methods")
    }
    
    var viewDisplayLargeTitle: Bool {
        true
    }
    
    var viewShowsCloseButton: Bool {
        true
    }
    
    func viewContext(at index: Int) -> TableCellContext? {
        guard let payment = paymentMethod(at: index) else { return nil }
        return TableCellContext(
            icon: payment.listIcon,
            title: payment.localizedTitle,
            accessoryIcon: payment.accessoryIcon
        )
    }
    
    func viewDidSelectCell(at: Int) {
        print("Selected at \(at)")
    }
    
    func viewShouldAnimateSelectedCell(at index: Int) -> Bool {
        guard let payment = paymentMethod(at: index) else { return false }
        return !payment.requiresAdditionalDetails
    }
    
    func viewDidTapClose() {
        print("close")
    }
}
