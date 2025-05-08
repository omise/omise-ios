@testable import OmiseSDK
import XCTest

final class FPXPaymentFormControllerTests: XCTestCase {
    
    var sut: FPXPaymentFormController!
    var mockViewModel: MockFPXPaymentFormViewModel!
    
    override func setUp() {
        super.setUp()
        mockViewModel = MockFPXPaymentFormViewModel()
        sut = FPXPaymentFormController(viewModel: mockViewModel)
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        mockViewModel = nil
        super.tearDown()
    }
    
    func testInitialState_submitButtonDisabledAndIndicatorNotAnimating() {
        guard let submitButton = sut.view.view(withAccessibilityIdentifier: "fpx.submitButton") as? UIButton else {
            XCTFail("Submit button not found")
            return
        }
        guard let indicator = sut.view.view(withAccessibilityIdentifier: "BaseForm.requestingIndicator")
                as? UIActivityIndicatorView else {
            XCTFail("Indicator not found")
            return
        }
        
        XCTAssertTrue(submitButton.isEnabled)
        XCTAssertFalse(indicator.isAnimating)
        XCTAssertTrue(sut.view.isUserInteractionEnabled)
    }
    
    func testSubmitAction_callsViewModelStartPaymentWithTrimmedText() {
        guard let emailField = sut.view.view(withAccessibilityIdentifier: "fpx.emailTextField") as? OmiseTextField else {
            XCTFail("Form fields not found")
            return
        }
        emailField.text = " johndoe@example.com "
        
        sut.submitForm(UIButton())
        
        XCTAssertTrue(mockViewModel.startPaymentCalled)
        XCTAssertEqual(mockViewModel.capturedEmail, "johndoe@example.com")
    }
    
    func testLoadingHandler_togglesIndicatorAndInteractionAndButton() {
        guard let submitButton = sut.view.view(withAccessibilityIdentifier: "fpx.submitButton") as? UIButton else {
            XCTFail("Submit button not found")
            return
        }
        guard let indicator = sut.view.view(withAccessibilityIdentifier: "BaseForm.requestingIndicator")
                as? UIActivityIndicatorView else {
            XCTFail("Indicator not found")
            return
        }
        // Ensure loadingHandler was set
        XCTAssertNotNil(mockViewModel.loadingClosure)
        sut.submitForm(submitButton)
        
        mockViewModel.loadingClosure?(true)
        XCTAssertTrue(indicator.isAnimating)
        XCTAssertFalse(sut.view.isUserInteractionEnabled)
        XCTAssertFalse(submitButton.isEnabled)
        
        mockViewModel.loadingClosure?(false)
        XCTAssertFalse(indicator.isAnimating)
        XCTAssertTrue(sut.view.isUserInteractionEnabled)
        XCTAssertTrue(submitButton.isEnabled)
    }
    
    func testValidateField_validEmail_hidesErrorLabel() {
        guard let emailField = sut.view.view(withAccessibilityIdentifier: "fpx.emailTextField") as? OmiseTextField,
              let errorLabel = sut.view.view(withAccessibilityIdentifier: "fpx.emailError") as? UILabel else {
            XCTFail("email field or error label not found")
            return
        }
        emailField.text = " ABC "
        sut.validateField(emailField)
        XCTAssertEqual(errorLabel.text, "Email error")
        XCTAssertEqual(errorLabel.alpha, 1.0)
    }
    
    func testValidateField_validEmail_NoError() {
        guard let emailField = sut.view.view(withAccessibilityIdentifier: "fpx.emailTextField") as? OmiseTextField,
              let errorLabel = sut.view.view(withAccessibilityIdentifier: "fpx.emailError") as? UILabel else {
            XCTFail("Email field or error label not found")
            return
        }
        emailField.text = ""
        sut.validateField(emailField)
        XCTAssertEqual(errorLabel.text, "-")
        XCTAssertEqual(errorLabel.alpha, 0.0)
    }
    
    func testValidateTextFieldDataOf() {
        let omiseField = OmiseTextField()
        sut.validateTextFieldDataOf(omiseField)
        XCTAssertEqual(omiseField.borderColor?.hexString, UIColor.omiseSecondary.hexString)
    }
    
    func testTextFieldEditingDidBegin() {
        guard let errorLabel = sut.view.view(withAccessibilityIdentifier: "fpx.emailError") as? UILabel else {
            XCTFail("Email field or error label not found")
            return
        }
        let omiseField = OmiseTextField()
        sut.textFieldEditingDidBegin(omiseField)
        
        XCTAssertEqual(omiseField.borderColor?.hexString, sut.view.tintColor.hexString)
        XCTAssertEqual(errorLabel.alpha, 0.0)
    }
    
    func testDoneEditing() {
        sut.doneEditing()
        XCTAssertFalse(sut.view.isFirstResponder)
    }
    
    func testKeyboardWillChangeFrame_updatesContentInsets() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = sut
        window.makeKeyAndVisible()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.contentView.contentInset.bottom, 0)
        XCTAssertEqual(sut.contentView.scrollIndicatorInsets.bottom, 0)
        
        let keyboardHeight: CGFloat = 300
        let frameEnd = CGRect(
            x: 0,
            y: sut.view.bounds.height - keyboardHeight,
            width: sut.view.bounds.width,
            height: keyboardHeight
        )
        let noti = Notification(
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            userInfo: [
                UIResponder.keyboardFrameEndUserInfoKey: NSValue(cgRect: frameEnd)
            ]
        )
        
        sut.keyboardWillChangeFrame(noti)
        
        XCTAssertEqual(sut.contentView.contentInset.bottom, keyboardHeight)
        XCTAssertEqual(sut.contentView.scrollIndicatorInsets.bottom, keyboardHeight)
    }
}
