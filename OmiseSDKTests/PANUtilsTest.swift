import Foundation
import OmiseSDK
import XCTest

// TODO: More extensive tests.
class PANUtilsTest: SDKTestCase {
    func testNormalize() {
        let tests: [String: String] = [
            " 4242 4242-4242 4242 ": "4242424242424242",
            "the quick brown 12345": "12345"
        ]
        
        tests.forEach { (input, output) in
            XCTAssertEqual(output, PANUtils.normalize(input))
        }
    }
    
    func testBrand() {
        let tests: [CardBrand: String] = [
            .Visa: "4242424242424242",
            .MasterCard: "5454545454545454",
            .JCB: "3566111111111113",
        ]
        
        tests.forEach { (brand, number) in
            XCTAssertEqual(brand, PANUtils.brand(number))
        }
    }
    
    func testLuhn() {
        XCTAssertTrue(PANUtils.luhn("4242424242424242"))
        XCTAssertFalse(PANUtils.luhn("4242424242424243"))
    }
    
    func testValidate() {
        XCTAssertTrue(PANUtils.validate(" 4242 4242-4242 4242 "))
        XCTAssertFalse(PANUtils.validate("4242424242424243"))
        XCTAssertFalse(PANUtils.validate("1234567812345678"))
    }
}
