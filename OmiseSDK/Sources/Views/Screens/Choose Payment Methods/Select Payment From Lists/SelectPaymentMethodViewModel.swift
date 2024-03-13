import Foundation
import UIKit.UIImage

class SelectPaymentMethodViewModel {
    struct Filter {
        let sourceTypes: [SourceType]
        let isCardPaymentAllowed: Bool
        let isForced: Bool
    }

    private let client: ClientProtocol
    private let filter: Filter
    private weak var delegate: SelectPaymentMethodDelegate?

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

    init(client: ClientProtocol, filter: Filter, delegate: SelectPaymentMethodDelegate) {
        self.client = client
        self.delegate = delegate
        self.filter = filter

        if !filter.sourceTypes.isEmpty, filter.isForced {
            self.paymentMethods = PaymentMethod.createPaymentMethods(
                from: filter.sourceTypes,
                showsCreditCard: filter.isCardPaymentAllowed
            )
        } else {

            setupCapability(client.latestLoadedCapability)
        }
    }

    func setupCapability(_ capability: Capability? = nil) {
        guard let capability = capability else {
            client.capability { [weak self] result in
                if let capability = try? result.get() {
                    self?.setupCapability(capability)
                }
            }
            return
        }
        let sourceTypes = capability.paymentMethods.compactMap { SourceType(rawValue: $0.name) }
        let isCardPaymentAllowed = capability.cardPaymentMethod != nil
        setupPaymentMethodsAndFilter(sourceTypes: sourceTypes, isCardPaymentAllowed: isCardPaymentAllowed)
    }

    func setupPaymentMethodsAndFilter(sourceTypes: [SourceType], isCardPaymentAllowed: Bool) {
        let filterSourceTypes = filter.sourceTypes

        let isCardEnabled = isCardPaymentAllowed && filter.isCardPaymentAllowed
        let allowedPaymentMethods = sourceTypes.filter { [filterSourceTypes] sourceType in
            if filterSourceTypes.isEmpty {
                return true
            } else {
                return filterSourceTypes.contains(sourceType)
            }
        }

        self.paymentMethods = PaymentMethod.createPaymentMethods(
            from: allowedPaymentMethods,
            showsCreditCard: isCardEnabled
        )
    }
}

extension SelectPaymentMethodViewModel: SelectPaymentPresentableProtocol {
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
        guard let payment = paymentMethods.at(index) else { return nil }
        return TableCellContext(
            title: payment.localizedTitle,
            subtitle: payment.localizedSubtitle,
            icon: UIImage(omise: payment.iconName),
            accessoryIcon: UIImage(payment.accessoryIcon)
        )
    }
    
    func viewDidSelectCell(at index: Int, completion: @escaping () -> Void) {
        guard let paymentMethod = paymentMethods.at(index) else { return }
        delegate?.didSelectPaymentMethod(paymentMethod, completion: completion)
    }
    
    func viewShouldAnimateSelectedCell(at index: Int) -> Bool {
        guard let payment = paymentMethods.at(index) else { return false }
        return !payment.requiresAdditionalDetails
    }
    
    func viewDidTapClose() {
        delegate?.didCancelPayment()
    }
}
