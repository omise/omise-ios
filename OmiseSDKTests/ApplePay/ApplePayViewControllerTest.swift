import XCTest
import PassKit
@testable import OmiseSDK

// MARK: - ApplePayViewController Tests
@MainActor
class ApplePayViewControllerTests: XCTestCase {
    var mockViewModel: MockApplePayViewModel!
    var viewController: ApplePayViewController!
    private func pumpMainQueue(times: Int = 1, timeout: TimeInterval = 1) {
        for index in 0..<times {
            let expectation = expectation(description: "main-queue-\(index)")
            DispatchQueue.main.async { expectation.fulfill() }
            wait(for: [expectation], timeout: timeout)
        }
    }
    
    override func setUp() {
        super.setUp()
        XCTAssertTrue(Thread.isMainThread, "setUp must execute on the main thread")
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
        
        // Drain the main queue to allow the completion path to re-enable the button.
        pumpMainQueue(times: 2)
        XCTAssertTrue(viewController.applePayButton.isEnabled, "Button should be re-enabled after payment completion")
        XCTAssertTrue(mockViewModel.startPaymentCalled, "startPayment should be invoked")
    }
}
