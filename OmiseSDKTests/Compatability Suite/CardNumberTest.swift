import Foundation
import OmiseSDK
import XCTest


@available(*, deprecated)
class CardNumberTest: XCTestCase {
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
        let tests: [[CardBrand: String]] = [
            [.visa: "4242424242424242"],
            [.jcb: "3566111111111113"],
            [.masterCard: "5454545454545454"],
            [.masterCard: "2221001234123456"]
        ]
        
        tests.forEach { cards in
            cards.forEach({ (brand, number) in
                XCTAssertEqual(brand, CardNumber.brand(of: number))
            })
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

