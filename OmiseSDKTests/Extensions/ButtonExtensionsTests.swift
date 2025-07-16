import XCTest
import UIKit
@testable import OmiseSDK

final class UIButtonChainableExtensionsTests: XCTestCase {
    private var button: UIButton!
    
    override func setUp() {
        super.setUp()
        button = UIButton(type: .system)
    }
    
    override func tearDown() {
        button = nil
        super.tearDown()
    }
    
    func testTitleMethodReturnsSelfAndSetsTitle() {
        let returned = button.title("Press Me", for: .normal)
        XCTAssertTrue(returned === button, "Should return self for chaining")
        XCTAssertEqual(button.title(for: .normal), "Press Me")
    }
    
    func testImageMethodReturnsSelfAndSetsImage() {
        let testImage = UIImage()
        let returned = button.image(testImage, for: .selected)
        XCTAssertTrue(returned === button)
        XCTAssertEqual(button.image(for: .selected), testImage)
    }
    
    func testTitleColorMethodReturnsSelfAndSetsTitleColor() {
        let red = UIColor.red
        let returned = button.titleColor(red, for: .highlighted)
        XCTAssertTrue(returned === button)
        XCTAssertEqual(button.titleColor(for: .highlighted), red)
    }
    
    func testFontMethodReturnsSelfAndSetsFont() {
        let customFont = UIFont.italicSystemFont(ofSize: 16)
        let returned = button.font(customFont)
        XCTAssertTrue(returned === button)
        XCTAssertEqual(button.titleLabel?.font, customFont)
    }
    
    func testTargetMethodReturnsSelfAndAddsAction() {
        class DummyTarget: NSObject {
            @objc func didTap(_ sender: UIButton) { }
        }
        let target = DummyTarget()
        let sel = #selector(DummyTarget.didTap(_:))
        let returned = button.target(target, action: sel, for: .touchUpInside)
        XCTAssertTrue(returned === button)
        
        // verify that the action is registered
        let actions = button.actions(forTarget: target, forControlEvent: .touchUpInside)
        XCTAssertNotNil(actions)
        XCTAssertTrue(((actions?.contains(String(describing: sel))) != nil))
    }
}
