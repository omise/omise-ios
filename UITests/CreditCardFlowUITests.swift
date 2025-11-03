import XCTest
@testable import OmiseSDK

final class CreditCardFlowUITests: BaseUITestCase {
    
    func testCreditCardFormDisplaysRequiredFields() throws {
        let cardNumberField = navigateToCreditCardForm()
        XCTAssertTrue(cardNumberField.isHittable, "Card number field should be ready for input")
        
        let expectedFields: [XCUIElement] = [
            app.textFields[AccessibilityIdentifiers.CreditCardForm.nameTextField],
            app.textFields[AccessibilityIdentifiers.CreditCardForm.expiryDateTextField],
            app.textFields[AccessibilityIdentifiers.CreditCardForm.cvvTextField],
            app.textFields[AccessibilityIdentifiers.CreditCardForm.emailTextField]
        ]
        
        for field in expectedFields {
            XCTAssertTrue(field.waitForExistence(timeout: 2), "\(field.identifier) should be visible")
        }
        
        let submitButton = app.buttons[AccessibilityIdentifiers.CreditCardForm.submitButton]
        XCTAssertTrue(submitButton.exists, "Submit button should be present")
        XCTAssertFalse(submitButton.isEnabled, "Submit should start disabled")
    }
    
    func testFillingCreditCardFormPopulatesValues() throws {
        let cardNumberField = navigateToCreditCardForm()
        
        fillCreditCardForm(
            cardNumber: TestDataHelper.CreditCard.validVisa,
            name: TestDataHelper.CreditCard.cardName,
            expiry: TestDataHelper.CreditCard.validExpiryDate,
            cvv: TestDataHelper.CreditCard.cardCVV,
            email: TestDataHelper.PersonalInfo.validEmail
        )
        
        app.tap()
        
        let cardValue = cardNumberField.value as? String
        XCTAssertNotNil(cardValue)
        
        if let cleanedValue = cardValue?.replacingOccurrences(of: " ", with: "") {
            XCTAssertEqual(String(cleanedValue.suffix(4)), "4242", "Card number should be captured")
        } else {
            XCTFail("Card number value should be a string")
        }
        
        let nameValue = app.textFields[AccessibilityIdentifiers.CreditCardForm.nameTextField].value as? String
        XCTAssertEqual(nameValue, TestDataHelper.CreditCard.cardName)
    }
    
    // MARK: - Helpers
    
    @discardableResult
    private func navigateToCreditCardForm() -> XCUIElement {
        let creditCardPaymentButton = app.buttons[AccessibilityIdentifiers.MainView.creditCardPaymentButton]
        tapWhenHittable(creditCardPaymentButton)
        
        let cardNumberField = app.textFields[AccessibilityIdentifiers.CreditCardForm.cardNumberTextField]
        waitFor(element: cardNumberField)
        return cardNumberField
    }
    
    private func fillCreditCardForm(cardNumber: String, name: String, expiry: String, cvv: String, email: String) {
        let cardNumberField = app.textFields[AccessibilityIdentifiers.CreditCardForm.cardNumberTextField]
        cardNumberField.tap()
        cardNumberField.replaceText(with: cardNumber)
        
        let nameField = app.textFields[AccessibilityIdentifiers.CreditCardForm.nameTextField]
        nameField.tap()
        nameField.replaceText(with: name)
        
        let expiryField = app.textFields[AccessibilityIdentifiers.CreditCardForm.expiryDateTextField]
        expiryField.tap()
        expiryField.replaceText(with: expiry)
        
        let cvvField = app.textFields[AccessibilityIdentifiers.CreditCardForm.cvvTextField]
        cvvField.tap()
        cvvField.replaceText(with: cvv)
        
        let emailField = app.textFields[AccessibilityIdentifiers.CreditCardForm.emailTextField]
        emailField.tap()
        emailField.replaceText(with: email)
        
        let phoneField = app.textFields[AccessibilityIdentifiers.CreditCardForm.phoneTextField]
        if phoneField.exists {
            phoneField.tap()
            phoneField.replaceText(with: TestDataHelper.PersonalInfo.validPhoneNumber)
        }
        
        selectCountryIfNeeded()
        fillAddressIfNeeded()
        dismissKeyboardIfNeeded()
    }
    
    private func selectCountryIfNeeded() {
        let countryField = app.otherElements["CreditCardForm.countryField"]
        guard countryField.exists else { return }
        
        let currentValue = (countryField.value as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard currentValue.isEmpty else { return }
        
        countryField.tap()
        
        let firstCell = app.tables.cells.element(boundBy: 0)
        if firstCell.waitForExistence(timeout: 3) {
            firstCell.tap()
        } else if app.cells.firstMatch.exists {
            app.cells.firstMatch.tap()
        }
    }
    
    private func fillAddressIfNeeded() {
        fillIfPresent(elementId: "CreditCardForm.addressField", text: "123 Main St")
        fillIfPresent(elementId: "CreditCardForm.cityField", text: "Bangkok")
        fillIfPresent(elementId: "CreditCardForm.stateField", text: "Bangkok")
        fillIfPresent(elementId: "CreditCardForm.postalCodeField", text: "10200")
    }
    
    private func fillIfPresent(elementId: String, text: String) {
        let element = app.otherElements[elementId]
        guard element.exists else { return }
        element.tap()
        app.typeText(text)
    }
    
    private func dismissKeyboardIfNeeded() {
        if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        } else if app.keyboards.buttons["Done"].exists {
            app.keyboards.buttons["Done"].tap()
        } else if app.keyboards.keys["Return"].exists {
            app.keyboards.keys["Return"].tap()
        }
    }
}
