import XCTest
@testable import OmiseSDK
import UIKit

final class CardCVVTextFieldTests: XCTestCase {
    
    var sut: CardCVVTextField!
    
    override func setUp() {
        super.setUp()
        sut = CardCVVTextField()
        _ = sut.becomeFirstResponder()
    }
    
    override func tearDown() {
        _ = sut.resignFirstResponder()
        sut = nil
        super.tearDown()
    }
    
    func testKeyboardTypeIsAlwaysNumberPad() {
        XCTAssertEqual(sut.keyboardType, .numberPad)
        
        sut.keyboardType = .emailAddress
        XCTAssertEqual(sut.keyboardType, .numberPad)
    }
    
    func testDelegateIsAlwaysSelf() {
        XCTAssertTrue(sut.delegate === sut)
        
        class DummyDelegate: NSObject, UITextFieldDelegate {}
        let dummy = DummyDelegate()
        sut.delegate = dummy
        XCTAssertTrue(sut.delegate === sut)
    }
    
    func testValidateThrowsEmptyTextErrorWhenTextIsNilOrEmpty() {
        sut.text = nil
        XCTAssertThrowsError(try sut.validate()) { error in
            XCTAssertEqual(error as? OmiseTextFieldValidationError, .emptyText)
        }
        
        sut.text = ""
        XCTAssertThrowsError(try sut.validate()) { error in
            XCTAssertEqual(error as? OmiseTextFieldValidationError, .emptyText)
        }
    }
    
    func testValidateThrowsInvalidDataForWrongLength() {
        sut.text = "12"  // too short
        XCTAssertThrowsError(try sut.validate()) { error in
            XCTAssertEqual(error as? OmiseTextFieldValidationError, .invalidData)
        }
        
        sut.text = "12345"  // too long
        XCTAssertThrowsError(try sut.validate()) { error in
            XCTAssertEqual(error as? OmiseTextFieldValidationError, .invalidData)
        }
    }
    
    func testValidateSucceedsForValidLengths() {
        sut.text = "123"  // 3 digits
        XCTAssertNoThrow(try sut.validate())
        
        sut.text = "1234"  // 4 digits
        XCTAssertNoThrow(try sut.validate())
    }
    
    func testShouldChangeCharactersIn_allowsUpTo4Digits() {
        sut.text = ""
        // Inserting "1234" into empty field => length 4
        XCTAssertTrue(sut.textField(sut,
                                    shouldChangeCharactersIn: NSRange(location: 0, length: 0),
                                    replacementString: "1234"))
        
        sut.text = "1234"
        // Attempt to add one more character => would exceed max 4
        XCTAssertFalse(sut.textField(sut,
                                     shouldChangeCharactersIn: NSRange(location: 4, length: 0),
                                     replacementString: "5"))
        
        sut.text = "1234"
        // Deletion should always be allowed
        XCTAssertTrue(sut.textField(sut,
                                    shouldChangeCharactersIn: NSRange(location: 3, length: 1),
                                    replacementString: ""))
    }
    
}
