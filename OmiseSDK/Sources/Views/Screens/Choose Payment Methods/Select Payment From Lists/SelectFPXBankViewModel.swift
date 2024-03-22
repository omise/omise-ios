import UIKit

class SelectFPXBankViewModel {
    weak var delegate: SelectSourcePaymentDelegate?
    let email: String?

    let errorMessage: String?

    private var viewOnDataReloadHandler: () -> Void = { } {
        didSet {
            self.viewOnDataReloadHandler()
        }
    }

    private var banks: [Capability.PaymentMethod.Bank] = [] {
        didSet {
            viewOnDataReloadHandler()
        }
    }

    init(email: String?, banks: [Capability.PaymentMethod.Bank], delegate: SelectSourcePaymentDelegate) {
        self.email = email
        self.banks = banks
        self.delegate = delegate

        errorMessage = banks.isEmpty ? localized("fpx.bank-chooser.no-banks-available.text") : nil
    }
}

extension SelectFPXBankViewModel: SelectPaymentPresentableProtocol {
    func viewOnDataReloadHandler(_ handler: @escaping () -> Void) {
        self.viewOnDataReloadHandler = handler
    }

    var numberOfViewContexts: Int {
        banks.count
    }

    var viewNavigationTitle: String {
        SourceType.fpx.localizedTitle
    }

    func viewContext(at index: Int) -> TableCellContext? {
        guard let bank = banks.at(index) else { return nil }
        let fpxBank = Source.Payment.FPX.Bank(rawValue: bank.code)
        return TableCellContext(
            title: bank.name,
            icon: UIImage(omise: fpxBank?.iconName ?? "FPX/unknown"),
            accessoryIcon: UIImage(Assets.Icon.redirect)
        )
    }

    func viewDidSelectCell(at index: Int, completion: @escaping () -> Void) {
        guard let bank = banks.at(index) else { return }

        let payment = Source.Payment.FPX(bank: bank.code, email: email)
        delegate?.didSelectSourcePayment(.fpx(payment), completion: completion)
    }

    func viewShouldAnimateSelectedCell(at index: Int) -> Bool {
        true
    }
}
