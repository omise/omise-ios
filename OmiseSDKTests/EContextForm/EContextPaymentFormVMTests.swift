@testable import OmiseSDK
import XCTest

final class EContextPaymentFormViewModelTests: XCTestCase {
    var sut: EContextPaymentFormViewModel!
    var mockDelegate: MockSelectSourcePaymentDelegate!
    
    override func setUp() {
        super.setUp()
        sut = EContextPaymentFormViewModel()
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
        
        sut.input.startPayment(
            name: "John Doe",
            email: "john@example.com",
            phone: "0123456789"
        )
        
        XCTAssertEqual(loadingStates, [true, false])
        
        XCTAssertTrue(mockDelegate.didSelectCalled)
        XCTAssertNotNil(mockDelegate.selectedPayment)
    }
    
    func testOutputErrorMessagesMatchFallbackValues() {
        XCTAssertEqual(sut.output.nameError, "Customer name is invalid")
        XCTAssertEqual(sut.output.emailError, "Email is invalid")
        XCTAssertEqual(sut.output.phoneError, "Phone number is invalid")
    }
}
