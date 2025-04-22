@testable import OmiseSDK
import XCTest

final class EContextPaymentFormControllerTests: XCTestCase {
    
    var sut: EContextPaymentFormController!
    var mockViewModel: MockEContextPaymentFormViewModel!
    
    override func setUp() {
        super.setUp()
        mockViewModel = MockEContextPaymentFormViewModel()
        sut = EContextPaymentFormController(viewModel: mockViewModel)
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        mockViewModel = nil
        super.tearDown()
    }
    
    func testInitialState_submitButtonDisabledAndIndicatorNotAnimating() {
        guard let submitButton = sut.view.view(withAccessibilityIdentifier: "EContextForm.submitButton") as? UIButton else {
            XCTFail("Submit button not found")
            return
        }
        guard let indicator = sut.view.view(withAccessibilityIdentifier: "EContextForm.requestingIndicator")
                as? UIActivityIndicatorView else {
            XCTFail("Indicator not found")
            return
        }
        
        XCTAssertFalse(submitButton.isEnabled)
        XCTAssertFalse(indicator.isAnimating)
        XCTAssertTrue(sut.view.isUserInteractionEnabled)
    }
    
    func testSubmitAction_callsViewModelStartPaymentWithTrimmedText() {
        guard let nameField = sut.view.view(withAccessibilityIdentifier: "EContextForm.nameTextField") as? OmiseTextField,
              let emailField = sut.view.view(withAccessibilityIdentifier: "EContextForm.emailTextField") as? OmiseTextField,
              let phoneField = sut.view.view(withAccessibilityIdentifier: "EContextForm.phoneTextField") as? OmiseTextField else {
            XCTFail("Form fields not found")
            return
        }
        nameField.text  = " John  Doe "
        emailField.text = " john@example.com "
        phoneField.text = " 0123456789 "
        
        sut.submitEContextForm(UIButton())
        
        XCTAssertTrue(mockViewModel.startPaymentCalled)
        XCTAssertEqual(mockViewModel.capturedName, "John  Doe")
        XCTAssertEqual(mockViewModel.capturedEmail, "john@example.com")
        XCTAssertEqual(mockViewModel.capturedPhone, "0123456789")
    }
    
    func testLoadingHandler_togglesIndicatorAndInteractionAndButton() {
        guard let submitButton = sut.view.view(withAccessibilityIdentifier: "EContextForm.submitButton") as? UIButton else {
            XCTFail("Submit button not found")
            return
        }
        guard let indicator = sut.view.view(withAccessibilityIdentifier: "EContextForm.requestingIndicator")
                as? UIActivityIndicatorView else {
            XCTFail("Indicator not found")
            return
        }
        // Ensure loadingHandler was set
        XCTAssertNotNil(mockViewModel.loadingClosure)
        sut.submitEContextForm(submitButton)
        
        mockViewModel.loadingClosure?(true)
        XCTAssertTrue(indicator.isAnimating)
        XCTAssertFalse(sut.view.isUserInteractionEnabled)
        XCTAssertFalse(submitButton.isEnabled)
        
        mockViewModel.loadingClosure?(false)
        XCTAssertFalse(indicator.isAnimating)
        XCTAssertTrue(sut.view.isUserInteractionEnabled)
        XCTAssertTrue(submitButton.isEnabled)
    }
    
    func testValidateField_emptyName_hidesErrorLabel() {
        guard let nameField = sut.view.view(withAccessibilityIdentifier: "EContextForm.nameTextField") as? OmiseTextField,
              let errorLabel = sut.view.view(withAccessibilityIdentifier: "EContextForm.nameError") as? UILabel else {
            XCTFail("Name field or error label not found")
            return
        }
        nameField.text = "#"
        sut.validateField(nameField)
        XCTAssertEqual(errorLabel.text, "Name error")
        XCTAssertEqual(errorLabel.alpha, 1.0)
    }
    
    func testValidateField_invalidEmail_showsEmailError() {
        guard let emailField = sut.view.view(withAccessibilityIdentifier: "EContextForm.emailTextField") as? OmiseTextField,
              let errorLabel = sut.view.view(withAccessibilityIdentifier: "EContextForm.emailError") as? UILabel else {
            XCTFail("Email field or error label not found")
            return
        }
        
        emailField.text = "not an email"
        sut.validateField(emailField)
        XCTAssertEqual(errorLabel.text, "Email error")
        XCTAssertEqual(errorLabel.alpha, 1.0)
    }
    
    func testValidateField_validPhone_hidesErrorLabel() {
        guard let phoneField = sut.view.view(withAccessibilityIdentifier: "EContextForm.phoneTextField") as? OmiseTextField,
              let errorLabel = sut.view.view(withAccessibilityIdentifier: "EContextForm.phoneError") as? UILabel else {
            XCTFail("Phone field or error label not found")
            return
        }
        phoneField.text = "ABC"
        sut.validateField(phoneField)
        XCTAssertEqual(errorLabel.text, "Phone error")
        XCTAssertEqual(errorLabel.alpha, 1.0)
    }
    
    func test_textFieldEditingDidBegin() {
        guard let nameField = sut.view.view(withAccessibilityIdentifier: "EContextForm.nameTextField") as? OmiseTextField else {
            XCTFail("Name field or error label not found")
            return
        }
        nameField.text = "#"
        sut.updateNavigationButtons(for: nameField)
        XCTAssertFalse(sut.omiseFormToolbar.previousButton.isEnabled)
        XCTAssertTrue(sut.omiseFormToolbar.nextButton.isEnabled)
    }
}
