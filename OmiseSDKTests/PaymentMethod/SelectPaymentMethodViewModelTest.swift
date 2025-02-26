import Foundation
import XCTest
@testable import OmiseSDK

class SelectPaymentMethodViewModelTest: XCTestCase {
    
    var sut: SelectPaymentMethodViewModel!
    var mockClient: MockClient!
    var mockselectPaymentMethodDelegate: MockSelectPaymentMethodDelegate!
    
    override func setUp() {
        super.setUp()
        mockClient = MockClient()
        mockselectPaymentMethodDelegate = MockSelectPaymentMethodDelegate()
        sut = SelectPaymentMethodViewModel(client: mockClient,
                                           filter: .init(sourceTypes: [], isCardPaymentAllowed: true, isForced: false),
                                           delegate: mockselectPaymentMethodDelegate)
    }
    
    override func tearDown() {
        super.tearDown()
        mockClient = nil
        sut = nil
        mockselectPaymentMethodDelegate = nil
    }
    
    func test_viewDidSelectCell_callsDelegate() {
        sut.viewDidSelectCell(at: 0) { }
        XCTAssertEqual(mockselectPaymentMethodDelegate.calls.count, 1)
        XCTAssertEqual(mockselectPaymentMethodDelegate.calls[0], .didSelectPaymentMethod)
    }
    
    func test_viewDidTapClose() {
        sut.viewDidTapClose()
        XCTAssertEqual(mockselectPaymentMethodDelegate.calls.count, 1)
        XCTAssertEqual(mockselectPaymentMethodDelegate.calls[0], .didCancelPayment)
    }
    
    func test_sourcetype_viewpresentable() throws {
        let cell = sut.viewContext(at: 1)
        
        XCTAssertEqual(cell?.title, SourceType.trueMoneyJumpApp.localizedTitle)
        XCTAssertEqual(cell?.subtitle, SourceType.trueMoneyJumpApp.localizedSubtitle)
        XCTAssertNotNil(cell?.icon)
    }
}
