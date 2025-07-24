import XCTest
import UIKit
@testable import OmiseSDK

class SelectDuitNowOBWBankVMTests: XCTestCase {
    private var sut: SelectDuitNowOBWBankViewModel!
    private var mockDelegate: MockSelectSourcePaymentDelegate!
    
    override func setUp() {
        super.setUp()
        // use all available banks so we have at least one
        let banks = Source.Payment.DuitNowOBW.Bank.allCases
        mockDelegate = MockSelectSourcePaymentDelegate()
        sut = SelectDuitNowOBWBankViewModel(banks: banks, delegate: mockDelegate)
    }
    
    func testViewOnDataReloadHandler_invokesImmediately() {
        var invoked = false
        sut.viewOnDataReloadHandler {
            invoked = true
        }
        XCTAssertTrue(invoked, "Assigning the reload handler should fire it immediately")
    }
    
    func testNumberOfViewContexts_returnsBankCount() {
        XCTAssertEqual(sut.numberOfViewContexts, Source.Payment.DuitNowOBW.Bank.allCases.count)
    }
    
    func testViewNavigationTitle_isDuitNowOBWTitle() {
        XCTAssertEqual(sut.viewNavigationTitle, SourceType.duitNowOBW.localizedTitle)
    }
    
    func testViewContext_validIndex_returnsCellContext() {
        let index = 0
        guard
            let ctx = sut.viewContext(at: index),
            let firstBank = Source.Payment.DuitNowOBW.Bank.allCases.first
        else {
            return XCTFail("Expected a non-nil context for index 0")
        }
        XCTAssertEqual(ctx.title, firstBank.localizedTitle)
        XCTAssertNotNil(ctx.icon, "Icon should not be nil")
        XCTAssertNotNil(ctx.accessoryIcon, "Accessory icon should not be nil")
    }
    
    func testViewContext_outOfBounds_returnsNil() {
        XCTAssertNil(sut.viewContext(at: 999))
    }
    
    func testViewDidSelectCell_callsDelegate_andFiresCompletion() {
        let index = 0
        var completionFired = false
        
        sut.viewDidSelectCell(at: index) {
            completionFired = true
        }
        
        // Delegate should have been called
        XCTAssertTrue(mockDelegate.didSelectCalled)
        // Payment passed should wrap the correct bank
        if case let .duitNowOBW(payload) = mockDelegate.selectedPayment {
            XCTAssertEqual(payload.bank, Source.Payment.DuitNowOBW.Bank.allCases[index])
        } else {
            XCTFail("Expected a .duitNowOBW payment")
        }
        // And the completion closure should have run
        XCTAssertTrue(completionFired)
    }
    
    func testViewShouldAnimateSelectedCell_alwaysTrue() {
        XCTAssertTrue(sut.viewShouldAnimateSelectedCell(at: 0))
        XCTAssertTrue(sut.viewShouldAnimateSelectedCell(at: 999))
    }
}
