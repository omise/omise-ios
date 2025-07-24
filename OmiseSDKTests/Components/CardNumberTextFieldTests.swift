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
    
    func testUpdatePlaceholderTextColor_appliesColorAndKerning() {
        sut.placeholder = "ABCDEFGHIJKLMNOP"
        sut.placeholderTextColor = .magenta
        sut.updatePlaceholderTextColor()
        
        guard let attr = sut.attributedPlaceholder else {
            return XCTFail("Expected an attributedPlaceholder")
        }
        
        // entire string should have .foregroundColor = magenta
        let fullRange = NSRange(location: 0, length: attr.length)
        var foundColor: UIColor?
        attr.enumerateAttribute(.foregroundColor, in: fullRange, options: []) { v, _, _ in
            if let c = v as? UIColor { foundColor = c }
        }
        XCTAssertEqual(foundColor, .magenta)
        
        // kerning at positions 3,7,11 (within length) should be 5
        let kerningKey = NSAttributedString.Key.kern
        [3, 7, 11].filter { $0 < attr.length }.forEach { idx in
            let value = attr.attribute(kerningKey, at: idx, effectiveRange: nil) as? Int
            XCTAssertEqual(value, 5, "Expected kern=5 at index \(idx)")
        }
    }
    
    func testTokenizerPositionAndIsPositionAndRangeEnclosing() throws {
        // no spaces in text, pan.suggestedSpaceFormattedIndexes = [4,8,12,...]
        sut.text = "123456789012"
        let tok = try XCTUnwrap(
            sut.tokenizer as? CardNumberTextField.CreditCardNumberTextInputStringTokenizer,
            "Expected tokenizer to be CreditCardNumberTextInputStringTokenizer"
        )
        
        let start = sut.beginningOfDocument
        let forward = UITextDirection(rawValue: UITextStorageDirection.forward.rawValue)
        let backward = UITextDirection(rawValue: UITextStorageDirection.backward.rawValue)
        
        // forward to first group boundary => offset 4
        guard let pos4 = tok.position(from: start,
                                      toBoundary: .word,
                                      inDirection: forward) else {
            return XCTFail("Expected a forward word boundary")
        }
        XCTAssertEqual(sut.offset(from: sut.beginningOfDocument, to: pos4), 4)
        
        // backward from pos4 => back to 0
        guard let back0 = tok.position(from: pos4,
                                       toBoundary: .word,
                                       inDirection: backward) else {
            return XCTFail("Expected a backward word boundary")
        }
        XCTAssertEqual(sut.offset(from: sut.beginningOfDocument, to: back0), 0)
        
        // isPosition at boundary: offset=4, atBoundary .word backward
        let isAtBoundary = tok.isPosition(back0,
                                          atBoundary: .word,
                                          inDirection: backward)
        XCTAssertTrue(isAtBoundary)
        
        // isPosition(withinTextUnit: .word) always true
        let within = tok.isPosition(back0,
                                    withinTextUnit: .word,
                                    inDirection: forward)
        XCTAssertTrue(within)
        
        // rangeEnclosingPosition for a position inside first group (offset=2) => 0..<4
        guard let pos2 = sut.position(from: sut.beginningOfDocument, offset: 2),
              let range = tok.rangeEnclosingPosition(pos2,
                                                     with: .word,
                                                     inDirection: forward)
        else {
            return XCTFail("Expected non‐nil enclosing range")
        }
        let startOffset = sut.offset(from: sut.beginningOfDocument, to: range.start)
        let endOffset   = sut.offset(from: sut.beginningOfDocument, to: range.end)
        XCTAssertEqual(startOffset, 0)
        XCTAssertEqual(endOffset, 4)
    }
    
    func testShouldChangeCharactersIn_limitsMaxLength() {
        // sut.text empty, default pan.brand=nil => maxLength=19
        sut.text = ""
        let nineteen = String(repeating: "1", count: 19)
        let zeroOK = sut.textField(sut,
                                   shouldChangeCharactersIn: NSRange(location: 0, length: 0),
                                   replacementString: nineteen)
        XCTAssertTrue(zeroOK)
        
        // now pretend full length
        sut.text = nineteen
        let tooLong = sut.textField(sut,
                                    shouldChangeCharactersIn: NSRange(location: 19, length: 0),
                                    replacementString: "1")
        XCTAssertFalse(tooLong)
    }
    
    func testCardBrand_detectsVisa() {
        sut.text = "4242424242424242"
        XCTAssertEqual(sut.cardBrand, .visa)
    }
    
    func testCardBrand_nilWhenEmpty() {
        sut.text = ""
        XCTAssertNil(sut.cardBrand)
    }
    
    func testInitFrame_setsKeyboardAndContentType() {
        let frameField = CardNumberTextField(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        XCTAssertEqual(frameField.keyboardType, .numberPad)
        XCTAssertEqual(frameField.textContentType, .creditCardNumber)
        XCTAssertTrue(frameField.delegate === frameField)
    }
    
    func testDefaultInit_behavesSameAsFrameInit() {
        let defaultField = CardNumberTextField()
        XCTAssertEqual(defaultField.keyboardType, .numberPad)
        XCTAssertEqual(defaultField.textContentType, .creditCardNumber)
    }
    
    func testValidate_throwsWhenPANInvalid() {
        sut.text = "11112222" // too short / fails Luhn
        XCTAssertThrowsError(try sut.validate()) { error in
            XCTAssertEqual(error as? OmiseTextFieldValidationError, .invalidData)
        }
    }
    
    func testValidate_succeedsWhenPANValid() {
        sut.text = "4111111111111111" // known-valid Visa test number
        XCTAssertNoThrow(try sut.validate())
    }
}
