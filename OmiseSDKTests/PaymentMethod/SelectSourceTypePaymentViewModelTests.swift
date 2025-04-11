import XCTest
import UIKit
@testable import OmiseSDK

extension Array {
    func at(_ index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

class SelectSourceTypePaymentViewModelTests: XCTestCase {
    var sut: SelectSourceTypePaymentViewModel!
    var mockDelegate: MockSelectSourceTypeDelegate!
    
    var sampleSourceTypes: [SourceType]!
    
    override func setUp() {
        super.setUp()
        mockDelegate = MockSelectSourceTypeDelegate()
        sampleSourceTypes = [.alipay, .trueMoneyJumpApp, .boost, .grabPay]
        sut = SelectSourceTypePaymentViewModel(title: "Test Title",
                                               sourceTypes: sampleSourceTypes,
                                               delegate: mockDelegate)
    }
    
    override func tearDown() {
        sut = nil
        mockDelegate = nil
        sampleSourceTypes = nil
        super.tearDown()
    }
    
    func test_viewNavigationTitle_returnsInitializationTitle() {
        XCTAssertEqual(sut.viewNavigationTitle, "Test Title")
    }
    
    func test_numberOfViewContexts_returnsCorrectCount() {
        XCTAssertEqual(sut.numberOfViewContexts, sampleSourceTypes.count)
    }
    
    func test_viewContext_returnsValidTableCellContext_forValidIndex() {
        let index = 0
        let context = sut.viewContext(at: index)
        XCTAssertNotNil(context)
        
        let expectedTitle = sampleSourceTypes[index].localizedTitle
        XCTAssertEqual(context?.title, expectedTitle)
        
        XCTAssertNotNil(context?.icon)
        XCTAssertNotNil(context?.accessoryIcon)
    }
    
    func test_viewContext_returnsNil_forInvalidIndex() {
        let outOfRangeIndex = sampleSourceTypes.count
        let context = sut.viewContext(at: outOfRangeIndex)
        XCTAssertNil(context)
    }
    
    func test_viewDidSelectCell_callsDelegate_withValidIndex() {
        let index = 1
        let delegateExpectation = expectation(description: "Delegate method should be called")
        
        sut.viewDidSelectCell(at: index) {
            delegateExpectation.fulfill()
        }
        
        XCTAssertTrue(mockDelegate.didSelectCalled)
        XCTAssertEqual(mockDelegate.selectedSourceType?.localizedTitle,
                       sampleSourceTypes[index].localizedTitle)
        
        wait(for: [delegateExpectation], timeout: 1.0)
        XCTAssertTrue(mockDelegate.completionWasCalled)
    }
    
    func test_viewDidSelectCell_doesNotCallDelegate_forInvalidIndex() {
        let invalidIndex = sampleSourceTypes.count
        mockDelegate.didSelectCalled = false
        
        sut.viewDidSelectCell(at: invalidIndex) {
            XCTFail("Completion closure should not be called for an invalid index")
        }
        
        XCTAssertFalse(mockDelegate.didSelectCalled)
    }
    
    func test_viewShouldAnimateSelectedCell_returnsExpectedValue() {
        let index = 0
        let sourceType = sampleSourceTypes[index]
        let expectedAnimation = !sourceType.requiresAdditionalDetails
        XCTAssertEqual(sut.viewShouldAnimateSelectedCell(at: index),
                       expectedAnimation)
        
        let invalidIndex = sampleSourceTypes.count
        XCTAssertFalse(sut.viewShouldAnimateSelectedCell(at: invalidIndex))
    }
    
    func test_viewOnDataReloadHandler_isCalledImmediately_whenSet() {
        var reloadCallCount = 0
        sut.viewOnDataReloadHandler {
            reloadCallCount += 1
        }
        XCTAssertEqual(reloadCallCount, 1)
        sut.viewOnDataReloadHandler {
            reloadCallCount += 1
        }
        XCTAssertEqual(reloadCallCount, 2)
    }
}
