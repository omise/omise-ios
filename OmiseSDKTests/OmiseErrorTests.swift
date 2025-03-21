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
}
