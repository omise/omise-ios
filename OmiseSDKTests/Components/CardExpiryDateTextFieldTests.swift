import XCTest
@testable import OmiseSDK
import UIKit

final class CardExpiryDateTextFieldTests: XCTestCase {
    
    var sut: CardExpiryDateTextField!
    
    override func setUp() {
        super.setUp()
        sut = CardExpiryDateTextField()
        _ = sut.becomeFirstResponder()
    }
    
    override func tearDown() {
        _ = sut.resignFirstResponder()
        sut = nil
        super.tearDown()
    }
    
    func testPaste_WhenClipboardHasValidExpiryDate_ShouldInsertIt() {
        // Clear the text field
        sut.text = ""
        let end = sut.endOfDocument
        sut.selectedTextRange = sut.textRange(from: end, to: end)
        
        // When
        sut.handlePaste(copiedText: "12/24 extra text")
        XCTAssertEqual(sut.text, "12/24", "Should parse and insert '12/24' from clipboard.")
        XCTAssertEqual(sut.selectedMonth, 12, "Expected month to be 12.")
        XCTAssertEqual(sut.selectedYear, 2024, "Expected year to be 2024 (2000 + 24).")
    }
    
    func testPaste_WhenClipboardIsEmpty_ShouldDoNothing() {
        // Given
        sut.text = "09/25"
        
        // Move cursor
        let end = sut.endOfDocument
        sut.selectedTextRange = sut.textRange(from: end, to: end)
        
        // When
        sut.handlePaste(copiedText: nil)
        
        // Then
        XCTAssertEqual(sut.text, "09/25", "Pasting empty clipboard should not change text.")
        XCTAssertEqual(sut.selectedMonth, 9)
        XCTAssertEqual(sut.selectedYear, 2025)
    }
    
    func testPaste_WhenClipboardHasNoDigits_ShouldNotInsertAny() {
        sut.text = ""
        let end = sut.endOfDocument
        sut.selectedTextRange = sut.textRange(from: end, to: end)
        
        // When
        sut.handlePaste(copiedText: "ABC / ???")
        
        // Then
        XCTAssertTrue(sut.text?.isEmpty == true || sut.text == "/",
                      "Should remain empty or minimal if there's no numeric data.")
        XCTAssertNil(sut.selectedMonth, "No digits => selectedMonth should remain nil.")
        XCTAssertNil(sut.selectedYear, "No digits => selectedYear should remain nil.")
    }
    
    func testPaste_WhenFieldIsPartiallyFilled_ShouldInsertRemainingDigits() {
        // Suppose the text field has "0" typed,
        // i.e. user typed "0" for month, and we want to paste the rest
        sut.text = "0"
        let end = sut.endOfDocument
        sut.selectedTextRange = sut.textRange(from: end, to: end)
        
        // When
        sut.handlePaste(copiedText: "7/24")
        
        XCTAssertEqual(sut.text, "07/24", "Should insert '7/24' after the leading '0', forming '07/24'.")
        XCTAssertEqual(sut.selectedMonth, 7)
        XCTAssertEqual(sut.selectedYear, 2024)
    }
}
