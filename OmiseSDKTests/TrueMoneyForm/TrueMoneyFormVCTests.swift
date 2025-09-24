@testable import OmiseSDK
import XCTest

final class TrueMoneyFormViewControllerTests: XCTestCase {
    
    var sut: TrueMoneyPaymentFormController!
    var mockViewModel: MockTrueMoneyFormViewModel!
    
    override func setUp() {
        super.setUp()
        mockViewModel = MockTrueMoneyFormViewModel()
        sut = TrueMoneyPaymentFormController(viewModel: mockViewModel)
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        mockViewModel = nil
        super.tearDown()
    }
    
    func testInitialState_submitButtonDisabledAndIndicatorNotAnimating() {
        guard let submitButton = sut.view.view(withAccessibilityIdentifier: "TrueMoneyPaymentForm.submitButton") as? UIButton else {
            XCTFail("Submit button not found")
            return
        }
        guard let indicator = sut.view.view(withAccessibilityIdentifier: "BaseForm.requestingIndicator")
                as? UIActivityIndicatorView else {
            XCTFail("Indicator not found")
            return
        }
        
        XCTAssertFalse(submitButton.isEnabled)
        XCTAssertFalse(indicator.isAnimating)
        XCTAssertTrue(sut.view.isUserInteractionEnabled)
    }
    
    func testSubmitAction_callsViewModelStartPaymentWithTrimmedText() {
        guard let phoneField = sut.view.view(withAccessibilityIdentifier: "TrueMoneyPaymentForm.phoneTextField") as? OmiseTextField else {
            XCTFail("Form fields not found")
            return
        }
        phoneField.text = " 0123456789 "
        
        sut.submitTrueMoneyForm(UIButton())
        
        XCTAssertTrue(mockViewModel.startPaymentCalled)
        XCTAssertEqual(mockViewModel.capturedPhone, "0123456789")
    }
    
    func testLoadingHandler_togglesIndicatorAndInteractionAndButton() {
        guard let submitButton = sut.view.view(withAccessibilityIdentifier: "TrueMoneyPaymentForm.submitButton") as? UIButton else {
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
        sut.submitTrueMoneyForm(submitButton)
        
        mockViewModel.loadingClosure?(true)
        XCTAssertTrue(indicator.isAnimating)
        XCTAssertFalse(sut.view.isUserInteractionEnabled)
        XCTAssertFalse(submitButton.isEnabled)
        
        mockViewModel.loadingClosure?(false)
        XCTAssertFalse(indicator.isAnimating)
        XCTAssertTrue(sut.view.isUserInteractionEnabled)
        XCTAssertTrue(submitButton.isEnabled)
    }
    
    func testValidateField_validPhone_hidesErrorLabel() {
        guard let phoneField = sut.view.view(withAccessibilityIdentifier: "TrueMoneyPaymentForm.phoneTextField") as? OmiseTextField,
              let errorLabel = sut.view.view(withAccessibilityIdentifier: "TrueMoneyPaymentForm.phoneError") as? UILabel else {
            XCTFail("Phone field or error label not found")
            return
        }
        phoneField.text = " ABC "
        sut.validateField(phoneField)
        XCTAssertEqual(errorLabel.text, "Phone error")
        XCTAssertEqual(errorLabel.alpha, 1.0)
    }
    
    func testValidateField_validPhone_NoError() {
        guard let phoneField = sut.view.view(withAccessibilityIdentifier: "TrueMoneyPaymentForm.phoneTextField") as? OmiseTextField,
              let errorLabel = sut.view.view(withAccessibilityIdentifier: "TrueMoneyPaymentForm.phoneError") as? UILabel else {
            XCTFail("Phone field or error label not found")
            return
        }
        phoneField.text = "09459234233"
        sut.validateField(phoneField)
        XCTAssertEqual(errorLabel.text, "-")
        XCTAssertEqual(errorLabel.alpha, 0.0)
    }
    
    func testValidateTextFieldDataOf() {
        let omiseField = OmiseTextField()
        sut.validateTextFieldDataOf(omiseField)
        XCTAssertEqual(omiseField.borderColor?.hexString, UIColor.omiseSecondary.hexString)
    }
    
    func testTextFieldEditingDidBegin() {
        guard let errorLabel = sut.view.view(withAccessibilityIdentifier: "TrueMoneyPaymentForm.phoneError") as? UILabel else {
            XCTFail("Phone field or error label not found")
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
        XCTAssertEqual(sut.contentView.verticalScrollIndicatorInsets.bottom, 0)
        
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
        XCTAssertEqual(sut.contentView.verticalScrollIndicatorInsets.bottom, keyboardHeight)
    }
}
