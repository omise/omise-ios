import UIKit

protocol SourceTypePaymentViewModelDelegate: AnyObject {
    func didSelectSourcePayment(_ payment: Source.Payment)
}

class SourceTypePaymentViewModel {

    weak var delegate: SourceTypePaymentViewModelDelegate?
    let title: String

    private var viewOnDataReloadHandler: () -> Void = { } {
        didSet {
            self.viewOnDataReloadHandler()
        }
    }

    private var sourceTypes: [SourceType] = [] {
        didSet {
            viewOnDataReloadHandler()
        }
    }

    init(sourceTypes: [SourceType], title: String, delegate: SourceTypePaymentViewModelDelegate) {
        self.sourceTypes = sourceTypes
        self.title = title
        self.delegate = delegate
    }
}

extension SourceTypePaymentViewModel: PaymentListViewModelProtocol {
    func viewOnDataReloadHandler(_ handler: @escaping () -> Void) {
        self.viewOnDataReloadHandler = handler
    }

    var numberOfViewContexts: Int {
        sourceTypes.count
    }

    var viewNavigationTitle: String {
        title
    }

    var viewDisplayLargeTitle: Bool {
        false
    }

    var viewShowsCloseButton: Bool {
        false
    }

    func viewContext(at index: Int) -> TableCellContext? {
        guard let sourceType = sourceTypes.at(index) else { return nil }
        return TableCellContext(
            icon: UIImage(omise: sourceType.iconName),
            title: sourceType.localizedTitle,
            accessoryIcon: UIImage(omise: sourceType.accessoryIconName)
        )
    }

    func viewDidSelectCell(at index: Int) {
        guard let sourceType = sourceTypes.at(index) else { return }
        delegate?.didSelectSourcePayment(.sourceType(sourceType))
    }

    func viewShouldAnimateSelectedCell(at index: Int) -> Bool {
        true
    }

    func viewDidTapClose() {
    }
}
