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
    
    func testInvalidCardLocalizedDescription() throws {
        let testCases: [(error: OmiseError, expectedDescription: String, expectedSuggestion: String)] = [
            (OmiseError.api(code: .invalidCard([.invalidCardNumber]), message: "", location: ""),
             "Invalid card number",
             "Please review the card number"),
            
            (OmiseError.api(code: .invalidCard([.emptyCardHolderName]), message: "", location: ""),
             "Invalid card holder name",
             "Please review the card holder name"),
            
            (OmiseError.api(code: .invalidCard([.invalidExpirationDate]), message: "", location: ""),
             "Invalid card expiration date",
             "Please review the card expiration date again."),
            
            (OmiseError.api(code: .invalidCard([.unsupportedBrand]), message: "", location: ""),
             "Unsupported card brand",
             "Please use another card"),
            
            (OmiseError.api(code: .invalidCard([.other("")]), message: "", location: ""),
             "An unknown error occured",
             "Please try again later")
        ]
        
        for (error, expectedDescription, expectedSuggestion) in testCases {
            XCTAssertEqual(error.localizedDescription, expectedDescription)
            XCTAssertEqual(error.localizedRecoverySuggestion, expectedSuggestion)
        }
    }
    
    func testBadRequestLocalizedDescription() throws {
        let testCases: [(error: OmiseError, expectedDescription: String, expectedSuggestion: String)] = [
            (OmiseError.api(code: .badRequest([.invalidName]), message: "", location: ""),
             "The customer name is invalid",
             "Please review the customer name"),
            
            (OmiseError.api(code: .badRequest([.invalidEmail]), message: "", location: ""),
             "The customer email is invalid",
             "Please review the email"),
            
            (OmiseError.api(code: .badRequest([.invalidCurrency]), message: "", location: ""),
             "The currency is invalid",
             "Please choose another currency or contact customer support"),
            
            (OmiseError.api(code: .badRequest([.invalidPhoneNumber]), message: "", location: ""),
             "The customer phone number is invalid",
             "Please review the phone number"),
            
            (OmiseError.api(code: .badRequest([.emptyName]), message: "", location: ""),
             "The customer name is empty",
             "Please fill in the customer name"),
            
            (OmiseError.api(code: .badRequest([.typeNotSupported]), message: "", location: ""),
             "The source type is not supported by this account",
             "Please contact customer support"),
            
            (OmiseError.api(code: .badRequest([.currencyNotSupported]), message: "", location: ""),
             "The currency is not supported for this account",
             "Please choose another currency"),
            
            (OmiseError.api(code: .badRequest([.other("")]), message: "", location: ""),
             "Unknown error occurred",
             "Please try again later"),
            
            (OmiseError.api(code: .badRequest([.amountIsGreaterThanValidAmount(validAmount: 1000, currency: .sgd)]), message: "", location: ""),
             "Amount is greater than the valid amount of SGD 10.00",
             "The payment amount is too high. Please make a payment with a lower amount."),
            
            (OmiseError.api(code: .badRequest([.amountIsLessThanValidAmount(validAmount: 1000, currency: .sgd)]), message: "", location: ""),
             "Amount is less than the valid amount of SGD 10.00",
             "The payment amount is too low. Please make a payment with a higher amount."),
            
            (OmiseError.api(code: .badRequest([.amountIsGreaterThanValidAmount(validAmount: nil, currency: nil)]), message: "", location: ""),
             "Amount is greater than the valid amount",
             "The payment amount is too high. Please make a payment with a lower amount."),
            
            (OmiseError.api(code: .badRequest([.amountIsLessThanValidAmount(validAmount: nil, currency: nil)]), message: "", location: ""),
             "Amount is less than the valid amount",
             "The payment amount is too low. Please make a payment with a higher amount."),
            
            (OmiseError.api(code: .badRequest([.nameIsTooLong(maximum: 100)]), message: "", location: ""),
             "The customer name exceeds 100 characters",
             "Please review the customer name"),
            
            (OmiseError.api(code: .badRequest([.nameIsTooLong(maximum: nil)]), message: "", location: ""),
             "The customer name is too long",
             "Please review the customer name")
        ]
        
        for (error, expectedDescription, expectedSuggestion) in testCases {
            XCTAssertEqual(error.localizedDescription, expectedDescription)
            XCTAssertEqual(error.localizedRecoverySuggestion, expectedSuggestion)
        }
    }
    
    func testOtherErrorLocalizedDescription() throws {
        let testCases: [(error: OmiseError, expectedDescription: String, expectedRecovery: String)] = [
            (OmiseError.api(code: .authenticationFailure, message: "", location: ""), "An unexpected error occured", "Please try again later"),
            (OmiseError.api(code: .serviceNotFound, message: "", location: ""), "An unexpected error occured", "Please try again later"),
            (OmiseError.api(code: .other(""), message: "", location: ""), "An unknown error occured", "Please try again later")
        ]
        
        for (error, expectedDescription, expectedRecovery) in testCases {
            XCTAssertEqual(error.localizedDescription, expectedDescription)
            XCTAssertEqual(error.localizedRecoverySuggestion, expectedRecovery)
        }
    }
    
    func testUnexpectedErrorLocalizedDescription() throws {
        let error = OmiseError.unexpected(error: .noErrorNorResponse, underlying: nil)
        
        XCTAssertEqual(error.localizedDescription, "An unexpected error occurred")
        XCTAssertEqual(error.localizedRecoverySuggestion, "Please try again later")
        
    }
}
