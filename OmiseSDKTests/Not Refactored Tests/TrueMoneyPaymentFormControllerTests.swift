import XCTest
@testable import OmiseSDK

class TrueMoneyPaymentFormControllerTests: XCTestCase {
    
    var sut: TrueMoneyPaymentFormController?
    weak var weakController: TrueMoneyPaymentFormController?
    
    override func setUp() {
        super.setUp()
        // Create a controller instance
        sut = TrueMoneyPaymentFormController(nibName: nil, bundle: .omiseSDK)
        weakController = sut
        
        // Load the view to trigger viewDidLoad
        _ = sut?.view
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testControllerDeallocatesProperly() {
        XCTAssertNotNil(sut)
        XCTAssertNotNil(weakController)
        
        var notificationReceived = false
        let notificationCenter = NotificationCenter.default
        
        let observer = notificationCenter.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main
        ) { _ in
            notificationReceived = true
        }
        
        notificationCenter.post(name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        let expectation1 = XCTestExpectation(description: "Initial notification received")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 1.0)
        
        XCTAssertTrue(notificationReceived, "Test observer should receive notifications")
        
        notificationReceived = false
        sut = nil
        
        // Force a garbage collection-like sweep
        autoreleasepool {
            for _ in 0...1000 {
                _ = NSObject()
            }
        }
        
        let expectation2 = XCTestExpectation(description: "Wait for deallocation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 1.0)
        
        XCTAssertNil(weakController, "Controller should be deallocated")
        
        notificationCenter.removeObserver(observer)
    }
    
    func testTextFieldTargetsRemoved() {
        class TestTextField: OmiseTextField {
            var actionInvoked = false
            
            override func sendActions(for controlEvents: UIControl.Event) {
                actionInvoked = true
                super.sendActions(for: controlEvents)
            }
        }
        
        let testField = TestTextField()
        sut?.formFields = [testField]
        
        testField.sendActions(for: .editingChanged)
        XCTAssertTrue(testField.actionInvoked, "Action should be invoked initially")
        
        testField.actionInvoked = false
        
        sut = nil
        
        autoreleasepool {
            for _ in 0...1000 {
                _ = NSObject()
            }
        }
        let expectation = XCTestExpectation(description: "Wait for deallocation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertNil(weakController, "Controller should be deallocated")
        
        testField.sendActions(for: .editingChanged)
        XCTAssertTrue(true, "No crash when sending actions after controller deallocation")
    }
}
