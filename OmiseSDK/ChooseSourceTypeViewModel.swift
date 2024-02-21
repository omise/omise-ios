import UIKit

protocol ChooseSourceTypeViewModelDelegate: AnyObject {
    func didSelectSourceType(_ sourceType: SourceType)
}

class ChooseSourceTypeViewModel {

    weak var delegate: ChooseSourceTypeViewModelDelegate?
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

    init(title: String, sourceTypes: [SourceType], delegate: ChooseSourceTypeViewModelDelegate) {
        self.sourceTypes = sourceTypes
        self.title = title
        self.delegate = delegate
    }
}

extension ChooseSourceTypeViewModel: ChoosePaymentPresentableProtocol {
    func viewOnDataReloadHandler(_ handler: @escaping () -> Void) {
        self.viewOnDataReloadHandler = handler
    }

    var numberOfViewContexts: Int {
        sourceTypes.count
    }

    var viewNavigationTitle: String {
        title
    }

    func viewContext(at index: Int) -> TableCellContext? {
        guard let sourceType = sourceTypes.at(index) else { return nil }
        return TableCellContext(
            title: sourceType.localizedTitle,
            icon: UIImage(omise: sourceType.iconName),
            accessoryIcon: UIImage(sourceType.accessoryIcon)
        )
    }

    func viewDidSelectCell(at index: Int) {
        guard let sourceType = sourceTypes.at(index) else { return }
        delegate?.didSelectSourceType(sourceType)
    }

    func viewShouldAnimateSelectedCell(at index: Int) -> Bool {
        guard let sourceType = sourceTypes.at(index) else { return false }
        return !sourceType.requiresAdditionalDetails
    }
}
