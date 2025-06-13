import XCTest
import UIKit
@testable import OmiseSDK

private class MockViewModel: SelectPaymentPresentableProtocol {
    var numberOfViewContexts: Int = 0
    var viewNavigationTitle: String = ""
    var viewDisplayLargeTitle: Bool = false
    var viewShowsCloseButton: Bool = false
    var errorMessage: String?
    
    /// contexts to return from viewContext(at:)
    var contexts: [TableCellContext?] = []
    /// Whether each row should animate
    var animateFlags: [Int: Bool] = [:]
    
    private var reloadHandler: (() -> Void)?
    private(set) var didTapCloseCalled = false
    private(set) var selectedIndex: Int?
    
    func viewOnDataReloadHandler(_ handler: @escaping () -> Void) {
        reloadHandler = handler
    }
    
    func viewContext(at row: Int) -> TableCellContext? {
        guard row < contexts.count else { return nil }
        return contexts[row]
    }
    
    func viewDidSelectCell(at index: Int, completion: @escaping () -> Void) {
        selectedIndex = index
        completion()
    }
    
    func viewShouldAnimateSelectedCell(at index: Int) -> Bool {
        return animateFlags[index] ?? false
    }
    
    func viewDidTapClose() {
        didTapCloseCalled = true
    }
    
    func triggerReload() {
        reloadHandler?()
    }
}

// MARK: – Tests
class SelectPaymentControllerTests: XCTestCase {
    private var vm: MockViewModel!
    var sut: SelectPaymentController!
    
    override func setUp() {
        super.setUp()
        vm = MockViewModel()
        sut = SelectPaymentController(viewModel: vm)
        sut.loadViewIfNeeded()
    }
    
    // MARK: viewDidLoad
    
    func test_viewDidLoad_setsUpNavigationAndTableView() {
        vm.viewNavigationTitle = "MyTitle"
        vm.viewDisplayLargeTitle = true
        vm.viewShowsCloseButton = true
        sut = SelectPaymentController(viewModel: vm)
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.navigationItem.title, "MyTitle")
        if #available(iOS 11.0, *) {
            XCTAssertEqual(sut.navigationItem.largeTitleDisplayMode, .always)
        }
        XCTAssertNotNil(sut.navigationItem.rightBarButtonItem)
        XCTAssertEqual(sut.tableView.separatorColor?.hexString, UIColor.omiseSecondary.hexString)
        XCTAssertEqual(sut.tableView.rowHeight, 64)
        XCTAssertEqual(sut.tableView.backgroundColor, .background)
    }
    
    func test_viewDidLoad_withErrorMessage_showsBackgroundLabel() {
        vm.errorMessage = "Oops!"
        sut = SelectPaymentController(viewModel: vm)
        sut.loadViewIfNeeded()
        
        let bg = sut.tableView.backgroundView as? UILabel
        XCTAssertEqual(bg?.text, "Oops!")
        XCTAssertEqual(sut.tableView.separatorStyle, .none)
    }
    
    func test_didTapClose_callsViewModel() {
        vm.viewShowsCloseButton = true
        sut = SelectPaymentController(viewModel: vm)
        sut.loadViewIfNeeded()
        
        // simulate tap
        sut.perform(#selector(SelectPaymentController.didTapClose))
        XCTAssertTrue(vm.didTapCloseCalled)
    }
    
    func test_numberOfRows_matchesViewModel() {
        vm.numberOfViewContexts = 7
        XCTAssertEqual(
            sut.tableView(sut.tableView, numberOfRowsInSection: 0),
            7
        )
    }
    
    func test_cellForRowAtIndexPath_populatesAllFieldsAndCallsCustomization() {
        vm.numberOfViewContexts = 1
        let icon = UIImage()
        let acc = UIImage()
        vm.contexts = [ TableCellContext(title: "T", subtitle: "S", icon: icon, accessoryIcon: acc) ]
        
        var didCustomize = false
        var capturedIndex: IndexPath?
        var capturedCell: UITableViewCell?
        sut.customizeCellAtIndexPathClosure = { cell, idx in
            didCustomize = true
            capturedIndex = idx
            capturedCell = cell
        }
        
        let cell = sut.tableView(
            sut.tableView,
            cellForRowAt: IndexPath(row: 0, section: 0)
        )
        
        XCTAssertEqual(cell.textLabel?.text, "T")
        XCTAssertEqual(cell.detailTextLabel?.text, "S")
        XCTAssertEqual(cell.imageView?.image, icon)
        let accessoryView = cell.accessoryView as? UIImageView
        XCTAssertEqual(accessoryView?.image, acc)
        XCTAssertEqual(accessoryView?.tintColor.hexString, UIColor.omiseSecondary.hexString)
        XCTAssertTrue(didCustomize)
        XCTAssertEqual(capturedIndex, IndexPath(row: 0, section: 0))
        XCTAssert(capturedCell === cell)
    }
    
    func test_didSelectRow_whenAnimateFalse_onlyNotifiesViewModel() {
        vm.numberOfViewContexts = 1
        vm.contexts = [ TableCellContext(title: "x", subtitle: nil, icon: nil, accessoryIcon: nil) ]
        vm.animateFlags = [ 0: false ]
        
        sut.tableView.reloadData()
        
        let idx = IndexPath(row: 0, section: 0)
        sut.tableView.delegate?.tableView?(sut.tableView, didSelectRowAt: idx)
        
        XCTAssertEqual(vm.selectedIndex, 0)
        XCTAssertTrue(sut.view.isUserInteractionEnabled)
    }
    
    func test_didSelectRow_whenAnimateTrue_startsAndStopsActivity() {
        vm.numberOfViewContexts = 1
        vm.contexts = [ TableCellContext(title: "x", subtitle: nil, icon: nil, accessoryIcon: nil) ]
        vm.animateFlags = [ 0: true ]
        
        sut.tableView.reloadData()
        let idx = IndexPath(row: 0, section: 0)
        XCTAssertTrue(sut.view.isUserInteractionEnabled)
        
        sut.tableView.delegate?.tableView?(sut.tableView, didSelectRowAt: idx)
        XCTAssertEqual(vm.selectedIndex, idx.row)
        XCTAssertTrue(sut.view.isUserInteractionEnabled)
    }
    
    func test_reloadHandler_reloadsTableViewAndReflectsNewCount() {
        vm.numberOfViewContexts = 1
        vm.contexts = [ TableCellContext(title: "1", subtitle: nil, icon: nil, accessoryIcon: nil) ]
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 1)
        
        // change model and trigger reload
        vm.numberOfViewContexts = 2
        vm.contexts.append( TableCellContext(title: "2", subtitle: nil, icon: nil, accessoryIcon: nil) )
        vm.triggerReload()
        
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 2)
    }
}
