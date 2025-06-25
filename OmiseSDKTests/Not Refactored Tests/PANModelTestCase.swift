import XCTest
@testable import OmiseSDK

class PANModelTestCase: XCTestCase {
    
    func testCreatePANs() {
        do {
            let pan = PAN("4242424242424242")
            XCTAssertEqual(pan.pan, "4242424242424242")
        }
        
        do {
            let pan = PAN("4242 4242 4242 4242")
            XCTAssertEqual(pan.pan, "4242424242424242")
        }
        
        do {
            let pan = PAN("4242-4242-4242-4242")
            XCTAssertEqual(pan.pan, "4242424242424242")
        }
        
        do {
            let pan = PAN("abcdefghi")
            XCTAssertEqual(pan.pan, "")
        }
        
        do {
            let pan = PAN("4242 4242 4242 ABCD")
            XCTAssertEqual(pan.pan, "424242424242")
        }
    }
    
    func testMaskingPAN() {
        do {
            let pan = PAN("4242424242424242")
            XCTAssertEqual(pan.pan, "4242424242424242")
            XCTAssertEqual(pan.number, "424242XXXXXX4242")
        }
        
        do {
            let pan = PAN("4242 4242 4242 4242")
            XCTAssertEqual(pan.number, "424242XXXXXX4242")
        }
        
        do {
            let pan = PAN("4242-4242-4242-4242")
            XCTAssertEqual(pan.number, "424242XXXXXX4242")
        }
        
        do {
            let pan = PAN("abcdefghi")
            XCTAssertEqual(pan.number, "")
        }
        
        do {
            let pan = PAN("4242 4242 4242 ABCD")
            XCTAssertEqual(pan.number, "42XXXXXX4242")
        }
        
        do {
            let pan = PAN("4242")
            XCTAssertEqual(pan.number, "4242")
        }
        
        do {
            let pan = PAN("42")
            XCTAssertEqual(pan.number, "42")
        }
        
        do {
            let pan = PAN("")
            XCTAssertEqual(pan.number, "")
        }
        
        do {
            let pan = PAN("42 4242")
            XCTAssertEqual(pan.number, "XX4242")
        }
        
        do {
            let pan = PAN("4242 4242")
            XCTAssertEqual(pan.number, "XXXX4242")
        }
    }
    
    // swiftlint:disable:next function_body_length
    func testBrandChecking() {
        do {
            let pan = PAN("4242424242424242")
            XCTAssertEqual(CardBrand.visa, pan.brand)
        }
        
        do {
            let pan = PAN("4111111111111111")
            XCTAssertEqual(CardBrand.visa, pan.brand)
        }
        
        do {
            let pan = PAN("5555555555554444")
            XCTAssertEqual(CardBrand.masterCard, pan.brand)
        }
        
        do {
            let pan = PAN("5454545454545454")
            XCTAssertEqual(CardBrand.masterCard, pan.brand)
        }
        
        do {
            let pan = PAN("3530111333300000")
            XCTAssertEqual(CardBrand.jcb, pan.brand)
        }
        
        do {
            let pan = PAN("3566111111111113")
            XCTAssertEqual(CardBrand.jcb, pan.brand)
        }
        
        do {
            let pan = PAN("3782 8224 6310 005")
            XCTAssertEqual(CardBrand.amex, pan.brand)
        }
        
        do {
            let pan = PAN("5033 9619 8909 17")
            XCTAssertEqual(CardBrand.maestro, pan.brand)
        }
        
        do {
            let pan = PAN("5868 2416 0825 5333 38")
            XCTAssertEqual(CardBrand.maestro, pan.brand)
        }
        
        do {
            let pan = PAN("6759 4111 0000 0008")
            XCTAssertEqual(CardBrand.maestro, pan.brand)
        }
        
        do {
            let pan = PAN("6759 5600 4500 5727 054")
            XCTAssertEqual(CardBrand.maestro, pan.brand)
        }
        
        do {
            let pan = PAN("5641 8211 1116 6669")
            XCTAssertEqual(CardBrand.maestro, pan.brand)
        }
        
        do {
            let pan = PAN("2222 4200 0000 1113")
            XCTAssertEqual(CardBrand.masterCard, pan.brand)
        }
        
        do {
            let pan = PAN("2222 6300 0000 1125")
            XCTAssertEqual(CardBrand.masterCard, pan.brand)
        }
    }
    
    func  testPANValidation() {
        do {
            let pan = PAN("4242424242424242")
            XCTAssertTrue(pan.isValid)
        }
        
        do {
            let pan = PAN("424242424242")
            XCTAssertFalse(pan.isValid)
        }
        
        do {
            let pan = PAN("4242 4242 42424 242")
            XCTAssertTrue(pan.isValid)
        }
        
        do {
            let pan = PAN("4242424242424241")
            XCTAssertFalse(pan.isValid)
        }
    }
    
    func testPatternOperatorAndBrandOperator() {
        let visaPAN = PAN("4242424242424242")
        // brand-pattern operator
        XCTAssertTrue(CardBrand.visa ~= visaPAN)
        XCTAssertFalse(CardBrand.masterCard ~= visaPAN)
        // string-pattern operator
        XCTAssertTrue("4242" ~= visaPAN)
        XCTAssertFalse("5555" ~= visaPAN)
    }
    
    func testLastDigitsAndSuggestedIndexes() {
        let pan = PAN("1234567890123456")
        XCTAssertEqual(pan.lastDigits, "3456")
        
        // The static suggestedSpaceFormattedIndexes is always [4,8,12,16]
        let expected = IndexSet([4, 8, 12, 16])
        XCTAssertEqual(pan.suggestedSpaceFormattedIndexes, expected)
        XCTAssertEqual(PAN.suggestedSpaceFormattedIndexesForPANPrefix(""), expected)
        XCTAssertEqual(PAN.suggestedSpaceFormattedIndexesForPANPrefix("1234"), expected)
    }
    
    func testDescriptionAndDebugDescription() {
        let pan = PAN("4242424242424242")
        // description only includes masked number
        XCTAssertEqual(pan.description, "PAN: \(pan.number)")
        
        // debugDescription includes ✓, masked number, and brand name
        let debug = pan.debugDescription
        XCTAssertTrue(debug.contains("✓"), "should show ✓ for valid pan")
        XCTAssertTrue(debug.contains(pan.number))
        XCTAssertTrue(debug.contains(CardBrand.visa.description))
        
        // invalid PAN shows ⨯ and no brand
        let bad = PAN("0000")
        let badDebug = bad.debugDescription
        XCTAssertTrue(badDebug.contains("⨯"))
        XCTAssertTrue(badDebug.contains("-"), "no brand should show “-”")
    }
    
    func testMaskingBehaviourEdgeCases() {
        // very short pan
        let pan2 = PAN("123")
        XCTAssertEqual(pan2.number, "123")
        // exactly 4 digits
        let pan4 = PAN("1234")
        XCTAssertEqual(pan4.number, "1234")
        // 5 digits -> mask middle (only digit 5 masked?)
        let pan5 = PAN("12345")
        // last four are "2345", startIndex = max(0,5-10)=0, endIndex = pan.index(end,-4)= index1 -> replace pan[0..<1] digits
        XCTAssertEqual(pan5.number, "X2345")
    }
    
    func testIsValidLuhnAndLengths() {
        let good = PAN("4242424242424242")
        XCTAssertTrue(good.isValid)
        
        // wrong check digit
        let badCheck = PAN("4242424242424241")
        XCTAssertFalse(badCheck.isValid)
        
        // correct luhn but wrong length
        let short = PAN("424242424242")
        XCTAssertFalse(short.isValid)
    }
}
