import XCTest
import UIKit
@testable import OmiseSDK

class CardNameTextFieldTests: XCTestCase {
    
    func testInitFrame_setsKeyboardAndContentType_andIsValidFalse() {
        let frame = CGRect(x: 0, y: 0, width: 120, height: 44)
        let textField = CardNameTextField(frame: frame)
        
        // initial configuration
        XCTAssertEqual(textField.keyboardType, .default)
        XCTAssertEqual(textField.textContentType, .name)
        
        // No text yet → isValid should be false
        XCTAssertEqual(textField.text, "")
        XCTAssertFalse(textField.isValid)
    }
    
    func testDefaultInit_setsKeyboardAndContentType() {
        let textField = CardNameTextField()
        XCTAssertEqual(textField.keyboardType, .default)
        XCTAssertEqual(textField.textContentType, .name)
    }
    
    func testInitCoder_setsKeyboardAndContentType() throws {
        let original = CardNameTextField(frame: .zero)
        let data = try NSKeyedArchiver.archivedData(
            withRootObject: original,
            requiringSecureCoding: false
        )
        
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
        unarchiver.requiresSecureCoding = false
        
        let key = NSKeyedArchiveRootObjectKey
        guard let unarchived = unarchiver.decodeObject(
            of: CardNameTextField.self,
            forKey: key
        ) else {
            XCTFail("Should be able to decode a CardNameTextField from archive")
            return
        }
        
        XCTAssertEqual(unarchived.keyboardType, .default)
        XCTAssertEqual(unarchived.textContentType, .name)
    }
    
    func testIsValid_returnsFalseWhenTextEmpty() {
        let textField = CardNameTextField()
        textField.text = ""
        XCTAssertFalse(textField.isValid)
    }
    
    func testIsValid_returnsTrueWhenTextNonEmpty() {
        let textField = CardNameTextField()
        textField.text = "Alice"
        XCTAssertTrue(textField.isValid)
    }
    
    func testOverrideInit_callsInitializeInstance() {
        let textField = CardNameTextField()
        XCTAssertEqual(textField.keyboardType, .default)
        XCTAssertEqual(textField.textContentType, .name)
    }
}
