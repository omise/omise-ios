import XCTest
import UIKit
@testable import OmiseSDK

final class OmiseTextFieldTests: XCTestCase {
    var tf: OmiseTextField!
    
    override func setUp() {
        super.setUp()
        tf = OmiseTextField(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
    }
    
    override func tearDown() {
        tf = nil
        super.tearDown()
    }
    
    func testPlainStyleAndBorderInspectable() {
        XCTAssertEqual(tf.style, .plain)
        XCTAssertEqual(tf.borderWidth, 0)
        
        tf.style = .border(width: 3)
        XCTAssertEqual(tf.style, .border(width: 3))
        XCTAssertEqual(tf.borderWidth, 3)
        
        tf.borderWidth = 0
        XCTAssertEqual(tf.style, .plain)
    }
    
    func testCornerRadiusAndBorderColorDriveLayer() {
        tf.style = .border(width: 2)
        tf.cornerRadius = 5
        tf.borderColor = .magenta
        
        XCTAssertEqual(tf.layer.borderWidth, 2)
        XCTAssertEqual(tf.layer.cornerRadius, 5)
        XCTAssertEqual(tf.layer.borderColor, UIColor.magenta.cgColor)
    }
    
    func testPlaceholderTextColor() {
        tf.placeholder = "Hello"
        tf.placeholderTextColor = .brown
        
        guard let attr = tf.attributedPlaceholder else {
            return XCTFail("Expected attributedPlaceholder to be non‐nil")
        }
        let full = NSRange(location: 0, length: attr.length)
        var found: UIColor?
        attr.enumerateAttribute(.foregroundColor, in: full, options: []) { v, _, _ in
            found = v as? UIColor
        }
        XCTAssertEqual(found, .brown)
    }
    
    func testValidate_throwsEmptyText() {
        tf.text = nil
        XCTAssertThrowsError(try tf.validate()) { err in
            XCTAssertEqual(err as? OmiseTextFieldValidationError, .emptyText)
        }
        
        tf.text = ""
        XCTAssertThrowsError(try tf.validate()) { err in
            XCTAssertEqual(err as? OmiseTextFieldValidationError, .emptyText)
        }
    }
    
    func testValidate_withRegexValidator() {
        tf.validator = try? NSRegularExpression(pattern: #"^\d{3}$"#)
        tf.text = "123"
        XCTAssertNoThrow(try tf.validate())
        
        tf.text = "abc"
        XCTAssertThrowsError(try tf.validate()) { err in
            XCTAssertEqual(err as? OmiseTextFieldValidationError, .invalidData)
        }
    }
    
    func testIsValidProperty() {
        tf.text = nil
        XCTAssertFalse(tf.isValid)
        
        tf.text = ""
        XCTAssertFalse(tf.isValid)
        
        tf.validator = try? NSRegularExpression(pattern: #"^[A-Z]+$"#)
        tf.text = "ABC"
        XCTAssertTrue(tf.isValid)
        
        tf.text = "A1C"
        XCTAssertFalse(tf.isValid)
    }
    
    func testOnValueChanged_and_textDidChange() {
        var called = false
        tf.onValueChanged = { called = true }
        
        // programmatically setting .text must fire textDidChange → onValueChanged
        tf.text = "foo"
        XCTAssertTrue(called)
    }
    
    func testOnTextFieldShouldReturn() {
        tf.onTextFieldShouldReturn = { true }
        XCTAssertTrue(tf.textFieldShouldReturn(tf))
    }
    
    func testTraitCollectionDidChange_invokesUpdateBorder() {
        // just cover the path; no assertions needed
        let previous = UITraitCollection(userInterfaceStyle: .light)
        tf.traitCollectionDidChange(previous)
    }
    
    func testRectMethods_areWithinBounds() {
        let bounds = CGRect(x: 0, y: 0, width: 100, height: 50)
        tf.style = .plain
        
        // borderRect is exactly the bounds
        XCTAssertEqual(tf.borderRect(forBounds: bounds), bounds)
        
        // the rest must lie inside
        let rects = [
            tf.textRect(forBounds: bounds),
            tf.editingRect(forBounds: bounds),
            tf.clearButtonRect(forBounds: bounds),
            tf.rightViewRect(forBounds: bounds),
            tf.leftViewRect(forBounds: bounds)
        ]
        rects.forEach {
            XCTAssertTrue(bounds.contains($0), "\($0) should lie inside \(bounds)")
        }
    }
    
    func testTextAreaViewRect_appliesInsetsOnBorderStyle() {
        tf.layoutMargins = UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4)
        tf.style = .border(width: 5)
        let bounds = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        // overallInsets = margins + borderWidth = (6,7,8,9)
        let inset = tf.textAreaViewRect(forBounds: bounds)
        let expected = bounds.inset(by: UIEdgeInsets(top: 6, left: 7, bottom: 8, right: 9))
        XCTAssertEqual(inset, expected)
    }
    
    func testInit_setsDelegate_and_defaultTextColor() {
        XCTAssertIdentical(tf.delegate, tf)
        // default borderWidth is zero
        XCTAssertEqual(tf.layer.borderWidth, 0)
        
        // confirm onValueChanged still works
        var didFire = false
        tf.onValueChanged = { didFire = true }
        tf.text = "abc"
        XCTAssertTrue(didFire)
    }
    
    func testBorderWidthAndStyle_roundTrips() {
        tf.borderWidth = 0
        XCTAssertEqual(tf.style, .plain)
        XCTAssertEqual(tf.layer.borderWidth, 0)
        
        tf.borderWidth = 3
        XCTAssertEqual(tf.style, .border(width: 3))
        XCTAssertEqual(tf.layer.borderWidth, 3)
    }
    
    func testPlaceholderTextColor_and_BorderColorLayerBehavior() {
        // placeholder styling
        tf.placeholder = "Test"
        tf.placeholderTextColor = .cyan
        
        let attr = tf.attributedPlaceholder! // swiftlint:disable:this force_unwrapping
        // swiftlint:disable:next force_cast
        let applied = attr.attribute(.foregroundColor, at: 0, effectiveRange: nil) as! UIColor
        XCTAssertEqual(applied.hexString, UIColor.cyan.hexString)
        
        // border behavior
        tf.style = .border(width: 4)
        tf.cornerRadius = 2
        tf.borderColor = .magenta
        XCTAssertEqual(tf.layer.borderWidth, 4)
        XCTAssertEqual(tf.layer.cornerRadius, 2)
        XCTAssertEqual(tf.layer.borderColor, UIColor.magenta.cgColor)
    }
}
