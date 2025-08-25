import XCTest
import UIKit
@testable import OmiseSDK

final class AtomePaymentInputsFormControllerTests: XCTestCase {
    
    var sut: AtomePaymentInputsFormController!
    var mockVM: AtomePaymentFormViewModelMockup!
    var nav: UINavigationController!
    
    override func setUp() {
        super.setUp()
        mockVM = AtomePaymentFormViewModelMockup()
            .withAllTitles()
            .withAllFields()
        mockVM.isSubmitButtonEnabledReturn = false
        sut = AtomePaymentInputsFormController(viewModel: mockVM)
        nav = UINavigationController(rootViewController: sut)
        
        UIApplication.shared.keyWindow?.rootViewController = nav
        
        _ = sut.view
    }
    
    override func tearDown() {
        nav = nil
        sut = nil
        mockVM = nil
        super.tearDown()
    }
    
    private func inputView(for field: AtomePaymentFormViewContext.Field) -> TextFieldView? {
        return sut.input(for: field)
    }
    
    private var submitButton: MainActionButton {
        return sut.submitButton as! MainActionButton // swiftlint:disable:this force_cast
    }
    
    private var billingCheckbox: OmiseCheckbox {
        return sut.billingAddressCheckbox
    }
    
    private var billingInputs: [TextFieldView] {
        return mockVM.billingAddressFields.compactMap { sut.input(for: $0) }
    }
    
    func test_initialState_billingFieldsHidden_and_submitDisabled() {
        for input in billingInputs {
            XCTAssertTrue(input.isHidden, "Expected billing input \(input.identifier) to be hidden initially")
        }
        XCTAssertTrue(sut.billingAddressLabel.isHidden)
        XCTAssertFalse(submitButton.isEnabled)
    }
    
    func test_togglingCheckbox_showsAndHidesBillingInputs() {
        
        for input in billingInputs {
            XCTAssertTrue(input.isHidden)
        }
        XCTAssertTrue(sut.billingAddressLabel.isHidden)
        
        _ = billingCheckbox.intrinsicContentSize
        billingCheckbox.onToggle?(false)
        
        for input in billingInputs {
            XCTAssertFalse(input.isHidden, "Expected billing input \(input.identifier) to be visible after toggling off")
        }
        XCTAssertFalse(sut.billingAddressLabel.isHidden, "Expected billing address header label to be visible after toggling off")
        
        billingCheckbox.onToggle?(true)
        
        for input in billingInputs {
            XCTAssertTrue(input.isHidden, "Expected billing input \(input.identifier) to be hidden after toggling on")
            XCTAssertEqual(input.text, "", "Expected billing input text to be cleared when hidden")
        }
        XCTAssertTrue(sut.billingAddressLabel.isHidden, "Expected billing address header to be hidden after toggling on")
    }
    
    func test_toggleChecked_viaButton_sendsOnToggle_andUpdatesIsChecked() {
        // initial state
        XCTAssertTrue(billingCheckbox.isChecked)
        
        let exp = expectation(description: "onToggle called")
        var callbackValue: Bool = true
        billingCheckbox.onToggle = { newValue in
            callbackValue = newValue
            exp.fulfill()
        }
        billingCheckbox.toggleChecked()
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertFalse(billingCheckbox.isChecked)
        XCTAssertFalse(callbackValue)
    }
    
    func test_submitButton_becomesEnabled_whenViewModelSaysValid() {
        XCTAssertFalse(submitButton.isEnabled)
        mockVM.isSubmitButtonEnabledReturn = true
        
        for field in mockVM.fields {
            guard let input = inputView(for: field) else { continue }
            input.text = "dummy"
        }
        
        mockVM.isSubmitButtonEnabledReturn = true
        sut.updateSubmitButtonState()
        let becameEnabled = mockVM.isSubmitButtonEnabled(sut.makeViewContext())
        XCTAssertTrue(becameEnabled, "validateFieldData() should return true when all fields are valid")
        XCTAssertTrue(submitButton.isEnabled, "Submit button must become enabled")
        
        mockVM.isSubmitButtonEnabledReturn = false
        sut.updateSubmitButtonState()
        let becameDisabled = mockVM.isSubmitButtonEnabled(sut.makeViewContext())
        XCTAssertFalse(becameDisabled)
        XCTAssertFalse(submitButton.isEnabled)
    }
    
    func test_tappingSubmit_invokesViewModel_onSubmitButtonPressed() {
        mockVM.isSubmitButtonEnabledReturn = true
        for field in mockVM.fields {
            inputView(for: field)?.text = "XYZ"
        }
        sut.updateSubmitButtonState()
        XCTAssertTrue(submitButton.isEnabled)
        
        sut.onSubmitButtonTapped()
        
        XCTAssertEqual(mockVM.submitCalledCount, 1, "Expected onSubmitButtonPressed(_) to be called once")
        
        let vc = mockVM.lastViewContext! // swiftlint:disable:this force_unwrapping
        for field in mockVM.fields {
            if field == .country || field == .billingCountry { continue }
            let expected = "XYZ"
            let actual = vc[field]
            XCTAssertEqual(actual, expected)
        }
    }
    
    func test_tappingCountryField_pushesCountryListController() {
        if inputView(for: .country) == nil {
            XCTFail("Country input should exist")
            return
        }
        
        let expectation = self.expectation(description: "CountryListController pushed")
        let fakeNav = FakeNavController(rootViewController: sut)
        UIApplication.shared.keyWindow?.rootViewController = fakeNav
        
        fakeNav.onPush = { pushedVC in
            XCTAssertTrue(pushedVC is CountryListController, "Expected CountryListController to be pushed")
            expectation.fulfill()
        }
        sut.openCountryListController(from: .billingCountry)
        
        waitForExpectations(timeout: 1)
    }
    
    func testHideErrorIfNil_clearsErrorWhenNoValidationError() {
        guard let nameInput = sut.input(for: .name) else {
            XCTFail("Expected a TextFieldView for the `.name` field")
            return
        }
        mockVM.isSubmitButtonEnabledReturn = true
        nameInput.error = "Some existing error"
        sut.hideErrorIfNil(field: .name)
        
        XCTAssertNil(nameInput.error)
    }
    
    func testOpenCountryListController_pushesCountryList_andUpdatesFieldOnSelection() {
        guard let countryInput = sut.input(for: .country) else {
            XCTFail("Expected a TextFieldView for .country")
            return
        }
        XCTAssertEqual(countryInput.text, "")
        
        sut.openCountryListController(from: .country)
        
        let top = nav.topViewController as? CountryListController
        XCTAssertNotNil(top)
        XCTAssertEqual(top?.title, countryInput.title)
        
        let sampleCountry = Country(name: "United States", code: "US")
        top?.viewModel?.onSelectCountry(sampleCountry)
        
        XCTAssertEqual(countryInput.text, "United States")
        XCTAssertEqual(mockVM.shippingCountry?.name, "United States")
    }
    
    func testShowAllErrors_appliesErrorsToEveryField() throws {
        class ErringVM: AtomePaymentFormViewModelMockup {
            override func error(for field: AtomePaymentFormViewContext.Field, validate text: String?) -> String? {
                return "Error for \(field.rawValue)"
            }
        }
        let mockVM = ErringVM()
        mockVM.fields = AtomePaymentFormViewContext.Field.allCases
        let sut = AtomePaymentInputsFormController(viewModel: mockVM)
        _ = sut.view
        
        for field in mockVM.fields {
            XCTAssertNil(sut.input(for: field)?.error)
        }
        
        sut.showAllErrors()
        for field in mockVM.fields {
            let input: TextFieldView = try XCTUnwrap(sut.input(for: field))
            XCTAssertEqual(input.error, "Error for \(field.rawValue)")
        }
    }
    
    func testUpdateError_setsInputErrorFromViewModel() throws {
        class SelectiveVM: AtomePaymentFormViewModelMockup {
            override func error(for field: AtomePaymentFormViewContext.Field, validate text: String?) -> String? {
                return field == .email ? "Invalid email" : nil
            }
        }
        let mockVM = SelectiveVM()
        mockVM.fields = [.name, .email]
        let sut = AtomePaymentInputsFormController(viewModel: mockVM)
        _ = sut.view
        
        let nameInput: TextFieldView = try XCTUnwrap(sut.input(for: .name))
        let emailInput: TextFieldView = try XCTUnwrap(sut.input(for: .email))
        
        XCTAssertNil(nameInput.error)
        XCTAssertNil(emailInput.error)
        
        emailInput.text = "bad"
        sut.updateError(for: .email)
        sut.updateError(for: .name)
        
        XCTAssertEqual(emailInput.error, "Invalid email")
        XCTAssertNil(nameInput.error)
    }
    
    func testInputAfter_returnsNextVisibleInput() throws {
        let mockVM = AtomePaymentFormViewModelMockup()
        mockVM.fields = [.name, .email, .phoneNumber]
        let sut = AtomePaymentInputsFormController(viewModel: mockVM)
        _ = sut.view
        
        let nameInput: TextFieldView = try XCTUnwrap(sut.input(for: .name))
        let emailInput: TextFieldView = try XCTUnwrap(sut.input(for: .email))
        let phoneInput: TextFieldView = try XCTUnwrap(sut.input(for: .phoneNumber))
        
        XCTAssertFalse(nameInput.isHidden)
        XCTAssertFalse(emailInput.isHidden)
        XCTAssertFalse(phoneInput.isHidden)
        
        XCTAssert(sut.input(after: nameInput) === emailInput)
        XCTAssert(sut.input(after: emailInput) === phoneInput)
        
        XCTAssertNil(sut.input(after: phoneInput))
    }
}

private class FakeNavController: UINavigationController {
    var onPush: ((UIViewController) -> Void)?
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: false)
        onPush?(viewController)
    }
}

private extension UIApplication {
    var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
