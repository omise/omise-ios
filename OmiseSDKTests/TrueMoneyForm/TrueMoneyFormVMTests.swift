@testable import OmiseSDK
import XCTest

final class TrueMoneyFormViewModelTests: XCTestCase {
    var sut: TrueMoneyPaymentFormViewModel!
    var mockDelegate: MockSelectSourcePaymentDelegate!
    
    override func setUp() {
        super.setUp()
        sut = TrueMoneyPaymentFormViewModel()
        mockDelegate = MockSelectSourcePaymentDelegate()
        sut.delegate = mockDelegate
    }
    
    override func tearDown() {
        sut = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    func testInputAndOutputReferToSameInstance() {
        XCTAssertTrue(sut.input as AnyObject === sut)
        XCTAssertTrue(sut.output as AnyObject === sut)
    }
    
    func testLoadingHandlerAndDelegateAreCalled() {
        var loadingStates = [Bool]()
        sut.input.set { isLoading in
            loadingStates.append(isLoading)
        }
        
        sut.input.startPayment(for: "0123456789")
        
        XCTAssertEqual(loadingStates, [true, false])
        
        XCTAssertTrue(mockDelegate.didSelectCalled)
        XCTAssertNotNil(mockDelegate.selectedPayment)
    }
    
    func testOutputErrorMessagesMatchFallbackValues() {
        XCTAssertEqual(sut.output.phoneError, "Phone number is invalid")
    }
}
