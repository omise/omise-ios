import UIKit

class SelectSourceTypePaymentViewModel {
    private weak var delegate: SelectSourceTypeDelegate?
    private let title: String

    private var viewOnDataReloadHandler: () -> Void = { /* Non-optional default empty implementation */ } {
        didSet {
            self.viewOnDataReloadHandler()
        }
    }

    private var sourceTypes: [SourceType] = [] {
        didSet {
            viewOnDataReloadHandler()
        }
    }

    init(title: String, sourceTypes: [SourceType], delegate: SelectSourceTypeDelegate) {
        self.sourceTypes = sourceTypes
        self.title = title
        self.delegate = delegate
    }
}

extension SelectSourceTypePaymentViewModel: SelectPaymentPresentableProtocol {
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

    func viewDidSelectCell(at index: Int, completion: @escaping () -> Void) {
        guard let sourceType = sourceTypes.at(index) else { return }
        delegate?.didSelectSourceType(sourceType, completion: completion)
    }

    func viewShouldAnimateSelectedCell(at index: Int) -> Bool {
        guard let sourceType = sourceTypes.at(index) else { return false }
        return !sourceType.requiresAdditionalDetails
    }
}
