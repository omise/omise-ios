import UIKit

class SelectFPXBankViewModel {
    weak var delegate: SelectSourcePaymentDelegate?
    let email: String?

    private var viewOnDataReloadHandler: () -> Void = { } {
        didSet {
            self.viewOnDataReloadHandler()
        }
    }

    private var values: [Capability.PaymentMethod.Bank] = [] {
        didSet {
            viewOnDataReloadHandler()
        }
    }

    init(email: String?, banks: [Capability.PaymentMethod.Bank], delegate: SelectSourcePaymentDelegate) {
        self.email = email
        self.values = banks
        self.delegate = delegate
    }
}

extension SelectFPXBankViewModel: SelectPaymentPresentableProtocol {
    func viewOnDataReloadHandler(_ handler: @escaping () -> Void) {
        self.viewOnDataReloadHandler = handler
    }

    var numberOfViewContexts: Int {
        values.count
    }

    var viewNavigationTitle: String {
        SourceType.fpx.localizedTitle
    }

    func viewContext(at index: Int) -> TableCellContext? {
        guard let bank = values.at(index) else { return nil }
        let fpxBank = Source.Payment.FPX.Bank(rawValue: bank.code)
        return TableCellContext(
            title: bank.name,
            icon: UIImage(omise: fpxBank?.iconName ?? "FPX/unknown"),
            accessoryIcon: UIImage(Assets.Icon.redirect)
        )
    }

    func viewDidSelectCell(at index: Int, completion: @escaping () -> Void) {
        guard let bank = values.at(index) else { return }

        let payment = Source.Payment.FPX(bank: bank.code, email: email)
        delegate?.didSelectSourcePayment(.fpx(payment), completion: completion)
    }

    func viewShouldAnimateSelectedCell(at index: Int) -> Bool {
        true
    }
}
