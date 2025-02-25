import XCTest
import PassKit
@testable import OmiseSDK

// MARK: - ApplePayViewController Tests
@available(iOS 11.0, *)
class ApplePayViewControllerTests: XCTestCase {
    var mockViewModel: MockApplePayViewModel!
    var viewController: ApplePayViewController!
    
    override func setUp() {
        super.setUp()
        // Initialize the mock view model with default values.
        mockViewModel = MockApplePayViewModel()
        // Create the view controller using the mock view model.
        viewController = ApplePayViewController(viewModel: mockViewModel)
        // Trigger view loading.
        viewController.loadViewIfNeeded()
    }
    
    override func tearDown() {
        mockViewModel = nil
        viewController = nil
        super.tearDown()
    }
    
    /// Test that when Apple Pay is available, the view controller adds the Apple Pay button.
    func testApplePayButtonIsAddedWhenAvailable() {
        // By default, mock ViewModel.canMakeApplePayPayment is true.
        // In viewDidLoad, setupApplePayButton should add the applePayButton.
        XCTAssertTrue(viewController.view.subviews.contains(viewController.applePayButton),
                      "applePayButton should be added when Apple Pay is available")
        XCTAssertFalse(viewController.view.subviews.contains(viewController.errorLabel),
                       "errorLabel should not be added when Apple Pay is available")
    }
    
    /// Test that when Apple Pay is not available, the view controller adds the error label.
    func testErrorLabelIsAddedWhenApplePayNotAvailable() {
        // Simulate Apple Pay being unavailable.
        mockViewModel.setApplePayPaymentModel(false)
        // Force re-run of setupApplePayButton.
        viewController.setupApplePayButton()
        
        XCTAssertTrue(viewController.view.subviews.contains(viewController.errorLabel),
                      "errorLabel should be added when Apple Pay is not available")
        XCTAssertFalse(viewController.view.subviews.contains(viewController.applePayButton),
                       "applePayButton should not be added when Apple Pay is not available")
    }
    
    /// Test that tapping the Apple Pay button disables it and then re-enables it after payment.
    func testPayPressedDisablesAndEnablesButton() {
        // Ensure the button is initially enabled.
        XCTAssertTrue(viewController.applePayButton.isEnabled, "Button should be enabled initially")
        
        // Simulate a tap on the button.
        viewController.payPressed()
        // Immediately after tapping, the button should be disabled.
        XCTAssertFalse(viewController.applePayButton.isEnabled, "Button should be disabled immediately after tap")
        
        // Wait for the asynchronous completion to re-enable the button.
        let expectation = self.expectation(description: "Button re-enabled after payment completion")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertTrue(self.viewController.applePayButton.isEnabled, "Button should be re-enabled after payment completion")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
