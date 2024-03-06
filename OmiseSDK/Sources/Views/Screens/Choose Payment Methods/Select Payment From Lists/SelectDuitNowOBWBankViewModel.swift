import UIKit

class SelectDuitNowOBWBankViewModel {
    private weak var delegate: SelectSourcePaymentDelegate?

    private var viewOnDataReloadHandler: () -> Void = { } {
        didSet {
            self.viewOnDataReloadHandler()
        }
    }

    private var banks: [Source.Payment.DuitNowOBW.Bank] = [] {
        didSet {
            viewOnDataReloadHandler()
        }
    }

    init(banks: [Source.Payment.DuitNowOBW.Bank], delegate: SelectSourcePaymentDelegate) {
        self.banks = banks
        self.delegate = delegate
    }
}

extension SelectDuitNowOBWBankViewModel: SelectPaymentPresentableProtocol {
    func viewOnDataReloadHandler(_ handler: @escaping () -> Void) {
        self.viewOnDataReloadHandler = handler
    }

    var numberOfViewContexts: Int {
        banks.count
    }

    var viewNavigationTitle: String {
        SourceType.duitNowOBW.localizedTitle
    }

    func viewContext(at index: Int) -> TableCellContext? {
        guard let bank = banks.at(index) else { return nil }
        return TableCellContext(
            title: bank.localizedTitle,
            icon: UIImage(omise: bank.iconName) ?? UIImage(omise: "FPX/unknown"),
            accessoryIcon: UIImage(bank.accessoryIcon)
        )
    }

    func viewDidSelectCell(at index: Int, completion: @escaping () -> Void) {
        guard let bank = banks.at(index) else { return }
        let payment: Source.Payment = .duitNowOBW(.init(bank: bank))
        delegate?.didSelectSourcePayment(payment, completion: completion)
    }

    func viewShouldAnimateSelectedCell(at index: Int) -> Bool {
        return true
    }
}
