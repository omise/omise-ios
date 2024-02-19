import Foundation

/// Contains properties and functions to generate data for ViewController and process user actions that requires data processing or screen navigation
class ChoosePaymentMethodViewModel2: ViewAttachable {

    enum DataSource {
        case capability
        case paymentMethods([SourceType], isCardEnabled: Bool)
    }

    typealias ViewContext = TableCellContext
    private var client: Client
    private var dataSource: DataSource

    init(client: Client, dataSource: DataSource) {
        self.client = client
        self.dataSource = dataSource
    }

    private var paymentMethods: [PaymentMethod] = [] {
        didSet {
            onPaymentMethodsReloadHandler(createViewContexts())
        }
    }

    func paymentMethod(at index: Int) -> PaymentMethod? {
        paymentMethods.at(index)
    }

    var onPaymentMethodsReloadHandler: ([ViewContext]) -> Void = { _ in } {
        didSet {
            onPaymentMethodsReloadHandler(createViewContexts())
        }
    }

    func reload() {
        switch dataSource {
        case .capability:
            if let latestLoadedCapability = client.latestLoadedCapability {
                paymentMethods = PaymentMethod.createPaymentMethods(with: latestLoadedCapability)
            } else {
                client.capability { [weak self] result in
                    if let capability = try? result.get() {
                        self?.paymentMethods = PaymentMethod.createPaymentMethods(with: capability)
                    }
                }
            }
        case .paymentMethods(let paymentMethods, let isCardEnabled):
            self.paymentMethods = PaymentMethod.createPaymentMethods(
                from: paymentMethods,
                showsCreditCard: isCardEnabled
            )
        }
    }

    func showsActivityForSelectedPaymentMethod(at index: Int) -> Bool {
        paymentMethods.at(index)?.requiresAdditionalDetails ?? false
    }
}

// MARK: Private
private extension ChoosePaymentMethodViewModel2 {
    func createViewContexts() -> [ViewContext] {
        paymentMethods.map { payment in
            ViewContext(
                icon: payment.listIcon,
                title: payment.localizedTitle,
                accessoryIcon: payment.accessoryIcon
            )
        }
    }
}
