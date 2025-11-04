import XCTest

class BaseUITestCase: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        
        XCUIDevice.shared.orientation = .portrait
        
        app = XCUIApplication()
        configure(app)
        launchApp()
    }
    
    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        try super.tearDownWithError()
    }
    
    var launchArguments: [String] {
        ["--uitesting", "--mock-mode"]
    }
    
    var launchEnvironment: [String: String] {
        ["OMISE_MOCK_MODE": "true"]
    }
    
    func configure(_ application: XCUIApplication) {
        application.launchArguments = launchArguments
        application.launchEnvironment = launchEnvironment
    }
    
    func launchApp(waitForMainView: Bool = true) {
        app.launch()
        if waitForMainView {
            waitForAppToBeReady()
        }
    }
    
    @discardableResult
    func relaunchApp(extraArguments: [String] = [], extraEnvironment: [String: String] = [:], waitForMainView: Bool = true) -> XCUIApplication {
        app.terminate()
        
        var arguments = launchArguments
        arguments.append(contentsOf: extraArguments)
        
        var environment = launchEnvironment
        extraEnvironment.forEach { environment[$0.key] = $0.value }
        
        app.launchArguments = arguments
        app.launchEnvironment = environment
        app.launch()
        
        if waitForMainView {
            waitForAppToBeReady()
        }
        
        return app
    }
    
    func waitForAppToBeReady(timeout: TimeInterval = 10) {
        let mainViewIdentifier = AccessibilityIdentifiers.MainView.view
        let mainView = app.otherElements[mainViewIdentifier]
        XCTAssertTrue(mainView.waitForExistence(timeout: timeout), "Expected main view to load within \(timeout) seconds")
    }
    
    func waitFor(element: XCUIElement, timeout: TimeInterval = 5, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(element.waitForExistence(timeout: timeout), "Failed to find element before timeout", file: file, line: line)
    }
    
    func tapWhenHittable(_ element: XCUIElement, timeout: TimeInterval = 5, file: StaticString = #filePath, line: UInt = #line) {
        waitFor(element: element, timeout: timeout, file: file, line: line)
        
        let predicate = NSPredicate(format: "isHittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let waiter = XCTWaiter()
        let result = waiter.wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(result, .completed, "Element was not hittable before timeout", file: file, line: line)
        
        element.tap()
    }
    
    func waitForEnabled(_ element: XCUIElement, timeout: TimeInterval = 10, file: StaticString = #filePath, line: UInt = #line) {
        if element.isEnabled { return }
        
        let predicate = NSPredicate(format: "isEnabled == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let waiter = XCTWaiter()
        let result = waiter.wait(for: [expectation], timeout: timeout)
        
        if result != .completed || !element.isEnabled {
            XCTFail("Element was not enabled before timeout", file: file, line: line)
        }
    }
    
    func waitForDisappearance(of element: XCUIElement, timeout: TimeInterval = 5, file: StaticString = #filePath, line: UInt = #line) {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let waiter = XCTWaiter()
        let result = waiter.wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(result, .completed, "Element still exists after timeout", file: file, line: line)
    }
    
    func waitForCooldown(_ interval: TimeInterval) {
        RunLoop.current.run(until: Date().addingTimeInterval(interval))
    }
}

extension XCUIElement {
    func clearText() {
        guard let stringValue = value as? String else { return }
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        typeText(deleteString)
    }
    
    func replaceText(with text: String) {
        clearText()
        typeText(text)
    }
}
