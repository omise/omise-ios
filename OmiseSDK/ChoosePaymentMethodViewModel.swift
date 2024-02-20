import Foundation

class ChoosePaymentMethodViewModel {
    let client: Client

    weak var delegate: PaymentMethodDelegate?

    private var viewOnDataReloadHandler: () -> Void = { } {
        didSet {
            self.viewOnDataReloadHandler()
        }
    }

    private var paymentMethods: [PaymentMethod] = [] {
        didSet {
            viewOnDataReloadHandler()
        }
    }

    init(client: Client, delegate: PaymentMethodDelegate) {
        self.client = client
        self.delegate = delegate
    }

    func setupAllowedPaymentMethods(_ paymentMethods: [SourceType], isCardEnabled: Bool) {
        self.paymentMethods = PaymentMethod.createPaymentMethods(
            from: paymentMethods,
            showsCreditCard: isCardEnabled
        )
    }

    func setupCapability() {
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
    
    func viewDidSelectCell(at index: Int) {
        guard let paymentMethod = paymentMethod(at: index) else { return }
        delegate?.didSelectPaymentMethod(paymentMethod)
    }
    
    func viewShouldAnimateSelectedCell(at index: Int) -> Bool {
        guard let payment = paymentMethod(at: index) else { return false }
        return !payment.requiresAdditionalDetails
    }
    
    func viewDidTapClose() {
        delegate?.didCancelPayment()
    }
}
