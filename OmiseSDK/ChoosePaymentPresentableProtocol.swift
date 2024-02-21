import Foundation

protocol ChoosePaymentPresentableProtocol {
    var numberOfViewContexts: Int { get }
    var viewNavigationTitle: String { get }
    var viewDisplayLargeTitle: Bool { get }
    var viewShowsCloseButton: Bool { get }

    func viewOnDataReloadHandler(_ handler: @escaping () -> Void)
    func viewContext(at: Int) -> TableCellContext?
    func viewDidSelectCell(at: Int)
    func viewShouldAnimateSelectedCell(at: Int) -> Bool
    func viewDidTapClose()
}

// Default implementation for most common cases
extension ChoosePaymentPresentableProtocol {
    var viewShowsCloseButton: Bool { false }
    var viewDisplayLargeTitle: Bool { false }
    func viewDidTapClose() {}
}
