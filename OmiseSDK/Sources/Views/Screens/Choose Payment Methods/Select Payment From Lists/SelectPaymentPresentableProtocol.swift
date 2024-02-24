import Foundation

protocol SelectPaymentPresentableProtocol {
    var numberOfViewContexts: Int { get }
    var viewNavigationTitle: String { get }
    var viewDisplayLargeTitle: Bool { get }
    var viewShowsCloseButton: Bool { get }

    func viewOnDataReloadHandler(_ handler: @escaping () -> Void)
    func viewContext(at: Int) -> TableCellContext?
    func viewDidSelectCell(at: Int, completion: @escaping () -> Void)
    func viewShouldAnimateSelectedCell(at: Int) -> Bool
    func viewDidTapClose()
}

// Default implementation for most common cases
extension SelectPaymentPresentableProtocol {
    var viewShowsCloseButton: Bool { false }
    var viewDisplayLargeTitle: Bool { false }
    func viewDidTapClose() {}
}
