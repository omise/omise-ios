import XCTest
@testable import OmiseSDK

final class MainScreenUITests: BaseUITestCase {
    
    @discardableResult
    private func openPaymentMethods(timeout: TimeInterval = 5) -> XCUIElement {
        let choosePaymentButton = app.buttons[AccessibilityIdentifiers.MainView.choosePaymentButton]
        tapWhenHittable(choosePaymentButton, timeout: timeout)
        
        let paymentMethodList = app.tables[AccessibilityIdentifiers.PaymentMethodSelection.paymentMethodList]
        waitFor(element: paymentMethodList, timeout: timeout)
        return paymentMethodList
    }
    
    func testAppLaunchesSuccessfully() throws {
        XCTAssertTrue(app.exists, "App should launch successfully")
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
    }
    
    func testMainViewElementsExist() throws {
        let mainView = app.otherElements[AccessibilityIdentifiers.MainView.view]
        XCTAssertTrue(mainView.waitForExistence(timeout: 5), "Main view should exist")
        
        let choosePaymentButton = app.buttons[AccessibilityIdentifiers.MainView.choosePaymentButton]
        XCTAssertTrue(choosePaymentButton.waitForExistence(timeout: 5), "Choose payment button should exist")
    }
    
    func testSelectingPaymentMethodShowsList() throws {
        let paymentMethodList = openPaymentMethods()
        XCTAssertTrue(paymentMethodList.cells.firstMatch.waitForExistence(timeout: 3), "Should list available payment methods")
        
        let firstCell = paymentMethodList.cells.firstMatch
        firstCell.tap()
        
        let confirmationView = app.otherElements[AccessibilityIdentifiers.PaymentMethodSelection.paymentConfirmationView]
        let creditCardForm = app.textFields[AccessibilityIdentifiers.CreditCardForm.cardNumberTextField]
        XCTAssertTrue(confirmationView.exists || creditCardForm.exists, "Tapping a method should navigate onward")
    }

    func testZeroInterestToggleCanBeSwitched() throws {
        // Open Settings
        let setupButton = app.buttons["Setup"]
        tapWhenHittable(setupButton, timeout: 5)

        let zeroInterestSwitch = app.switches[AccessibilityIdentifiers.Settings.zeroInterestSwitch]
        waitFor(element: zeroInterestSwitch, timeout: 5)

        let initialValue = zeroInterestSwitch.value as? String
        zeroInterestSwitch.tap()
        let toggledValue = zeroInterestSwitch.value as? String
        XCTAssertNotEqual(initialValue, toggledValue, "Tapping the switch should change its value")
    }
}
