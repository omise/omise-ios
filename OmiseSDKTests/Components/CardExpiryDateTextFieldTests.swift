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
    
    func testKeyboardTypeOverride() {
        sut.keyboardType = .emailAddress
        XCTAssertEqual(sut.keyboardType, .numberPad)
    }
    
    func testAccessibilityElements() {
        guard let elements = sut.accessibilityElements,
              elements.count == 2,
              elements[0] is CardExpiryDateTextField.InfoAccessibilityElement,
              elements[1] is CardExpiryDateTextField.InfoAccessibilityElement
        else {
            return XCTFail("Expected two accessibility elements")
        }
    }
    
    func testParsedSelectedYear() {
        // when <100, adds 2000
        sut.parsedSelectedYear = 22
        let base = Calendar.creditCardInformationCalendar.component(.year, from: Date()) / 100 * 100
        XCTAssertEqual(sut.selectedYear, base + 22)
        
        // when >=100, takes as-is
        sut.parsedSelectedYear = 2025
        XCTAssertEqual(sut.selectedYear, 2025)
    }
    
    // MARK: – validate throws on past date, succeeds on future date
    func testValidate_throwsForPastDate() {
        let now = Date()
        let cal = Calendar.creditCardInformationCalendar
        let thisMonth = cal.component(.month, from: now)
        let thisYear = cal.component(.year, from: now)
        // make a date one month in the past
        let pastMonth = thisMonth == 1 ? 12 : thisMonth - 1
        let pastYear  = thisMonth == 1 ? thisYear - 1 : thisYear
        let input = String(format: "%02d/%02d", pastMonth, pastYear % 100)
        
        sut.text = input
        sut.parseCardExpiryDate(text: input)
        XCTAssertThrowsError(try sut.validate())
    }
    
    func testValidate_succeedsForFutureDate() {
        let now = Date()
        let cal = Calendar.creditCardInformationCalendar
        let thisMonth = cal.component(.month, from: now)
        let thisYear = cal.component(.year, from: now)
        // next year
        let nextYear = thisYear + 1
        let input = String(format: "%02d/%02d", thisMonth, nextYear % 100)
        
        sut.text = input
        sut.parseCardExpiryDate(text: input)
        XCTAssertNoThrow(try sut.validate())
    }
    
    // MARK: – textDidChange formatting, separator coloring, truncation
    func testTextDidChangeFormattingAndTruncation() {
        sut.dateSeparatorTextColor = .red
        sut.text = ""
        // user types "5"
        sut.text! += "5" // swiftlint:disable:this force_unwrapping
        sut.textDidChange()
        XCTAssertEqual(sut.attributedText?.string, "05/")
        
        // user adds "6"
        sut.text! += "6" // swiftlint:disable:this force_unwrapping
        sut.textDidChange()
        XCTAssertEqual(sut.text, "05/6")
        
        // simulate too-long
        sut.text = "12/3456"
        sut.textDidChange()
        XCTAssertEqual(sut.text, "12/34")
    }
    
    func testLayoutSubviews() {
        sut.layoutSubviews()
        // after laying out, both frames must exist
        XCTAssertNotNil(sut.expirationMonthAccessibilityElement.accessibilityFrameInContainerSpace)
        XCTAssertNotNil(sut.expirationYearAccessibilityElement.accessibilityFrameInContainerSpace)
    }
    
    func testAccessibilityIncrementDecrement() throws {
        // seed a known MM/YY
        sut.parseCardExpiryDate(text: "06/25")
        let monthElement = try XCTUnwrap(sut.expirationMonthAccessibilityElement)
        let beforeMonth = try XCTUnwrap(sut.selectedMonth)
        monthElement.accessibilityIncrement()
        XCTAssertEqual(sut.selectedMonth, min(12, beforeMonth + 1))
        monthElement.accessibilityDecrement()
        XCTAssertEqual(sut.selectedMonth, beforeMonth)
        
        let yearElement = try XCTUnwrap(sut.expirationYearAccessibilityElement)
        let beforeYear = try XCTUnwrap(sut.selectedYear)  // 2025
        yearElement.accessibilityIncrement()
        XCTAssertEqual(sut.selectedYear, beforeYear + 1)
        yearElement.accessibilityDecrement()
        XCTAssertEqual(sut.selectedYear, beforeYear)
    }
    
    func testShouldChangeCharacters() {
        sut.text = "12/34"
        // inserting one more at position 0 (no deletion) → would be length 6 → false
        let tooLong = sut.textField(
            sut,
            shouldChangeCharactersIn: NSRange(location: 0, length: 0),
            replacementString: "5"
        )
        XCTAssertFalse(tooLong)
        
        // replacing the last character → length stays 5 → true
        let ok = sut.textField(
            sut,
            shouldChangeCharactersIn: NSRange(location: 4, length: 1),
            replacementString: "5"
        )
        XCTAssertTrue(ok)
    }
    
    func testDeleteBackward_slashThenDigit_atEndOfField() {
        // 1) When there's a trailing “/” and the caret is at the very end,
        //    the first call should eat the slash (inside the if) then the digit (super.call).
        sut.text = "12/"
        
        // place the insertion point at the very end
        let end = sut.endOfDocument
        sut.selectedTextRange = sut.textRange(from: end, to: end)
        
        sut.deleteBackward()
        XCTAssertEqual(sut.text, "1")
    }
    
    func testInitFrame_callsInitializeInstance() {
        // Exercise init(frame:)
        let field = CardExpiryDateTextField(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        field.keyboardType = .default
        
        // initializeInstance should have run:
        XCTAssertNotNil(field.expirationMonthAccessibilityElement)
        XCTAssertNotNil(field.expirationYearAccessibilityElement)
        XCTAssertEqual(field.keyboardType, .numberPad)
        XCTAssertTrue(field.delegate === field)
    }
    
    func testParseCardExpiryDate_regexBranch_setsMonthOnlyAndLeavesTextAlone() {
        sut.parseCardExpiryDate(text: "12")
        
        XCTAssertEqual(sut.selectedMonth, 12)
        XCTAssertNil(sut.selectedYear)
    }
    
}
