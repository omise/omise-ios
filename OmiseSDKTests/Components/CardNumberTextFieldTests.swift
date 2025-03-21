import XCTest
@testable import OmiseSDK
import UIKit

final class CardNumberTextFieldTests: XCTestCase {
    
    var sut: CardNumberTextField!
    
    override func setUp() {
        super.setUp()
        sut = CardNumberTextField()
        _ = sut.becomeFirstResponder()
    }
    
    override func tearDown() {
        _ = sut.resignFirstResponder()
        sut = nil
        super.tearDown()
    }
    
    func testHandlePaste_WhenClipboardHasValidPAN_ShouldFormatAndTruncateAsNeeded() {
        // Given
        let copiedText = "1234-5678-9012-3456-7890"  // includes non-digits
        sut.text = "4111 1111"
        
        // Move cursor to end (so any pasted text goes there)
        let endPosition = sut.endOfDocument
        sut.selectedTextRange = sut.textRange(from: endPosition, to: endPosition)
        
        // When
        sut.handlePaste(copiedText: copiedText)
        
        // Then
        XCTAssertEqual(
            sut.text,
            "4111 11111234567890",
            "Should paste digits, remove non-numerics, and truncate after 19."
        )
    }
    
    func testHandlePaste_WhenClipboardIsEmpty_ShouldDoNothing() {
        // Given
        let copiedText: String? = nil
        sut.text = "4111 1111 1111"
        let originalText = sut.text
        
        // Move cursor to end
        let end = sut.endOfDocument
        sut.selectedTextRange = sut.textRange(from: end, to: end)
        
        // When
        sut.handlePaste(copiedText: copiedText)
        
        // Then
        XCTAssertEqual(
            sut.text,
            originalText,
            "Pasting nil/empty clipboard should not modify the text."
        )
    }
    
    func testHandlePaste_WhenClipboardHasNonDigitsOnly_ShouldNotInsertAny() {
        // Given
        let copiedText = "ABCDEFG"  // no digits
        sut.text = ""
        
        let end = sut.endOfDocument
        sut.selectedTextRange = sut.textRange(from: end, to: end)
        
        // When
        sut.handlePaste(copiedText: copiedText)
        
        // Then
        XCTAssertEqual(
            sut.text,
            "",
            "Should remain empty when pasting a string with no digits."
        )
    }
    
    func testHandlePaste_WhenFieldIsAlmostFull_ShouldPasteOnlyTheRemainingAllowedDigits() {
        // Suppose brand’s max length is 19 digits.
        // The field currently has 16 digits: "4111 1111 1111 1111"
        sut.text = "4111 1111 1111 1111"
        
        let copiedText = "9999"
        
        let end = sut.endOfDocument
        sut.selectedTextRange = sut.textRange(from: end, to: end)
        
        // When
        sut.handlePaste(copiedText: copiedText)
        
        // Then
        XCTAssertEqual(
            sut.text,
            "4111 1111 1111 1111",
            "Should only paste up to the brand's max length."
        )
    }
}
