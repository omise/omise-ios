@testable import OmiseSDK
import XCTest

final class FPXPaymentFormViewModelTests: XCTestCase {
    var sut: FPXPaymentFormViewModel!
    var mockDelegate: MockFPXPaymentFormControllerDelegate!
    
    override func setUp() {
        super.setUp()
        sut = FPXPaymentFormViewModel()
        mockDelegate = MockFPXPaymentFormControllerDelegate()
        sut.delegate = mockDelegate
    }
    
    override func tearDown() {
        sut = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    func testInputAndOutputReferToSameInstance() {
        XCTAssertIdentical(sut.input as AnyObject, sut)
        XCTAssertIdentical(sut.output as AnyObject, sut)
    }
    
    func testLoadingHandlerAndDelegateAreCalled() {
        var loadingStates = [Bool]()
        sut.input.set { isLoading in
            loadingStates.append(isLoading)
        }
        
        sut.input.startPayment(email: "johndoe@example.com")
        
        XCTAssertEqual(loadingStates, [true, false])
        
        XCTAssertTrue(mockDelegate.didCompleteCalled)
    }
    
    func testOutputErrorMessagesMatchFallbackValues() {
        XCTAssertEqual(sut.output.emailError, "Email is invalid")
    }
    
    func testViewWillAppear() {
        let expectation = self.expectation(description: "loading closure should be called")
        var isLoading: Bool = true
        sut.input.set { loading in
            isLoading = loading
            expectation.fulfill()
        }
        sut.input.viewWillAppear()
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertFalse(isLoading)
    }
}
