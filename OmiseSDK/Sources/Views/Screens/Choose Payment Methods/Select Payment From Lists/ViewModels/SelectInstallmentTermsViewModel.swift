import UIKit

class SelectInstallmentTermsViewModel {
    weak var delegate: SelectSourcePaymentDelegate?
    let sourceType: SourceType

    private var viewOnDataReloadHandler: () -> Void = { /* Non-optional default empty implementation */ } {
        didSet {
            self.viewOnDataReloadHandler()
        }
    }

    private var values: [Int] = [] {
        didSet {
            viewOnDataReloadHandler()
        }
    }

    private let zeroInterestInstallments: Bool

    init(sourceType: SourceType, zeroInterestInstallments: Bool, delegate: SelectSourcePaymentDelegate) {
        self.sourceType = sourceType
        self.zeroInterestInstallments = zeroInterestInstallments
        self.values = Source.Payment.Installment.availableTerms(for: sourceType)
        self.delegate = delegate
    }
}

extension SelectInstallmentTermsViewModel: SelectPaymentPresentableProtocol {
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
        let accessoryIcon = sourceType.isWhiteLabelInstallment ? Assets.Icon.next : Assets.Icon.redirect
        return TableCellContext(
            title: String.localizedStringWithFormat(numberOfTermsTitleFormat, value),
            icon: nil,
            accessoryIcon: UIImage(accessoryIcon)
        )
    }

    func viewDidSelectCell(at index: Int, completion: @escaping () -> Void) {
        guard let value = values.at(index) else { return }
        let payment = Source.Payment.Installment(
            installmentTerm: value,
            zeroInterestInstallments: zeroInterestInstallments,
            sourceType: sourceType
        )
        delegate?.didSelectSourcePayment(.installment(payment), completion: completion)
    }

    func viewShouldAnimateSelectedCell(at index: Int) -> Bool {
        if sourceType.isWhiteLabelInstallment {
            return false
        } else {
            return true
        }
    }
}
