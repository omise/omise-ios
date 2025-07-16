import XCTest
import UIKit

@testable import OmiseSDK

class CVVInfoViewTests: XCTestCase {
    
    var sut: CVVInfoView!
    
    override func setUp() {
        super.setUp()
        sut = CVVInfoView()
        sut.preferredCardBrand = .visa
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testTapGesture_CallsOnCloseTapped() {
        let expectation = self.expectation(description: "onCloseTapped closure should be called")
        
        sut.onCloseTapped = {
            expectation.fulfill()
        }
        sut.handleBackgroundTap()
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testPreferCardToAMEX() {
        guard let label = sut.view(withAccessibilityIdentifier: "CVVInfoView.descriptionLabel") as? UILabel else {
            return
        }
        XCTAssertEqual(label.text, localized("CreditCard.cvv.details.default.text"))
        
        sut.preferredCardBrand = .amex
        
        XCTAssertEqual(label.text, localized("CreditCard.cvv.details.amex.text"))
    }
    
    func testShouldReceiveTouch_onlyWhenTouchIsOnSelf() {
        guard let container = sut.view(withAccessibilityIdentifier: "CVVInfoView.containerView") else {
            return
        }
        
        let gesture = UITapGestureRecognizer()
        
        func touch(on view: UIView) -> UITouch {
            let t = UITouch()
            // bypass the private setter
            t.setValue(view, forKey: "view")
            return t
        }
        
        let onSelf = touch(on: sut)
        XCTAssertTrue(sut.gestureRecognizer(gesture, shouldReceive: onSelf))
        
        let onChild = touch(on: container)
        XCTAssertFalse(sut.gestureRecognizer(gesture, shouldReceive: onChild))
    }
}
