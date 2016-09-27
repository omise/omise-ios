import Foundation
import OmiseSDK
import XCTest

// TODO: More extensive tests.
class CardNumberTest: SDKTestCase {
    func testNormalize() {
        let tests: [String: String] = [
            " 4242 4242-4242 4242 ": "4242424242424242",
            "the quick brown 12345": "12345"
        ]
        
        tests.forEach { (input, output) in
            XCTAssertEqual(output, CardNumber.normalize(input))
        }
    }
    
    func testBrand() {
        let tests: [CardBrand: String] = [
            .Visa: "4242424242424242",
            .MasterCard: "5454545454545454",
            .JCB: "3566111111111113",
        ]
        
        tests.forEach { (brand, number) in
            XCTAssertEqual(brand, CardNumber.brand(of: number))
        }
    }
    
    func testFormat() {
        XCTAssertEqual("4242 42", CardNumber.format("424242"))
        XCTAssertEqual("4242 4242 4242 4242", CardNumber.format("4242424242424242"))
    }
    
    func testLuhn() {
        XCTAssertTrue(CardNumber.luhn("4242424242424242"))
        XCTAssertFalse(CardNumber.luhn("4242424242424243"))
    }
    
    func testValidate() {
        XCTAssertTrue(CardNumber.validate(" 4242 4242-4242 4242 "))
        XCTAssertFalse(CardNumber.validate("4242424242424243"))
        XCTAssertFalse(CardNumber.validate("1234567812345678"))
    }
}
