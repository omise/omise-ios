import UIKit

protocol ChooseInstallmentTermsViewModelDelegate: AnyObject {
    func didSelectInstallmentPayment(_ installment: Source.Payment.Installment)
}

class ChooseInstallmentTermsViewModel {
    weak var delegate: ChooseInstallmentTermsViewModelDelegate?
    let sourceType: SourceType

    private var viewOnDataReloadHandler: () -> Void = { } {
        didSet {
            self.viewOnDataReloadHandler()
        }
    }

    private var values: [Int] = [] {
        didSet {
            viewOnDataReloadHandler()
        }
    }

    init(sourceType: SourceType, delegate: ChooseInstallmentTermsViewModelDelegate) {
        self.sourceType = sourceType
        self.values = Source.Payment.Installment.availableTerms(for: sourceType)
        self.delegate = delegate
    }
}

extension ChooseInstallmentTermsViewModel: ChoosePaymentPresentableProtocol {
    func viewOnDataReloadHandler(_ handler: @escaping () -> Void) {
        self.viewOnDataReloadHandler = handler
    }

    var numberOfViewContexts: Int {
        values.count
    }

    var viewNavigationTitle: String {
        sourceType.localizedTitle
    }
    
    func viewContext(at index: Int) -> TableCellContext? {
        guard let value = values.at(index) else { return nil }
        let numberOfTermsTitleFormat = localized("installments.number-of-terms.text", "%d months")
        return TableCellContext(
            title: String.localizedStringWithFormat(numberOfTermsTitleFormat, value),
            icon: nil,
            accessoryIcon: UIImage(Assets.Icon.redirect)
        )
    }

    func viewDidSelectCell(at index: Int) {
        guard let value = values.at(index) else { return }
        let payment = Source.Payment.Installment(
            installmentTerm: value,
            zeroInterestInstallments: nil,
            sourceType: sourceType
        )
        delegate?.didSelectInstallmentPayment(payment)
    }

    func viewShouldAnimateSelectedCell(at index: Int) -> Bool {
        true
    }
}
