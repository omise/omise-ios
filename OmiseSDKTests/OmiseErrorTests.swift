import Foundation
import XCTest
@testable import OmiseSDK

class OmiseErrorTests: XCTestCase {
    
    func testBadRequestReason() throws {
        let currencies: [Currency?] = [nil, .jpy, .myr, .thb, .usd]
        for currency in currencies {
            let expectedResults: [String: OmiseError.APIErrorCode.BadRequestReason] = [
                "amount must be at least 500": .amountIsLessThanValidAmount(validAmount: 500, currency: currency),
                "amount must be less than 500": .amountIsGreaterThanValidAmount(validAmount: 500, currency: currency),
                "amount must be greater than 500": .amountIsLessThanValidAmount(validAmount: 500, currency: currency),
                "name is too long (maximum is 50 characters)": .nameIsTooLong(maximum: 50),
                "name is too long ... 20": .nameIsTooLong(maximum: nil), // check if it should be .invalidName instead,
                "... name ... blank ...": .emptyName,
                "... name ...": .nameIsTooLong(maximum: nil), // check if it should be .invalidName instead,
                "... email ...": .invalidEmail,
                "... phone ...": .invalidPhoneNumber,
                "... type ...": .typeNotSupported,
                "... currency must be...": .invalidCurrency,
                "... currency ...": .currencyNotSupported,
                "Something else": .other("Something else")
            ]

            for (testString, expectedResult) in expectedResults {
                let result = try OmiseError.APIErrorCode.BadRequestReason(message: testString, currency: currency)
                XCTAssertEqual(result, expectedResult)
            }
        }
    }

    typealias BadRequestReason = OmiseError.APIErrorCode.BadRequestReason
    func testParseBadRequestReasonsFromMessage() {
        // Array of tuples for test cases
        let currency: Currency = .thb
        let testCases: [(message: String, expected: Set<BadRequestReason>)] = [
            (
                "amount must be at least 100 THB",
                [.amountIsLessThanValidAmount(validAmount: 100, currency: currency)]
            ),
            (
                "amount must be less than 5000 USD",
                [.amountIsGreaterThanValidAmount(validAmount: 5000, currency: currency)]
            ),
            (
                "currency must be.., empty name",
                [.invalidCurrency, .nameIsTooLong(maximum: nil)]
            ),
            (
                "other currency error, empty name",
                [.currencyNotSupported, .nameIsTooLong(maximum: nil)]
            ),
            (
                "name is too long (maximum is 25 characters), invalid email",
                [.nameIsTooLong(maximum: 25), .invalidEmail]
            ),
            (
                "invalid phone number",
                [.invalidPhoneNumber]
            ),
            (
                "type not supported, currency not supported",
                [.typeNotSupported, .currencyNotSupported]
            ),
            (
                "unknown issue",
                [.other("unknown issue")]
            )
        ]

        for (message, expected) in testCases {
            do {
                let results = try BadRequestReason.parseBadRequestReasonsFromMessage(message, currency: currency)
                XCTAssertEqual(Set(results), expected, "Failed to parse or incorrect order for message: \(message)")
            } catch {
                XCTFail("Unexpected error for message: \(message): \(error)")
            }
        }
    }

}
