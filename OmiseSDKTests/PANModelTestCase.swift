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
    
}
