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
        let testCases: [OmiseErrorParsing] = [
            .init(error: OmiseError.api(code: .invalidCard([.invalidCardNumber]), message: "", location: ""),
                  expectedDescription: "Invalid card number",
                  expectedRecovery: "Please review the card number"),
            .init(error: OmiseError.api(code: .invalidCard([.emptyCardHolderName]), message: "", location: ""),
                  expectedDescription: "Invalid card holder name",
                  expectedRecovery: "Please review the card holder name"),
            .init(error: OmiseError.api(code: .invalidCard([.invalidExpirationDate]), message: "", location: ""),
                  expectedDescription: "Invalid card expiration date",
                  expectedRecovery: "Please review the card expiration date again."),
            .init(error: OmiseError.api(code: .invalidCard([.unsupportedBrand]), message: "", location: ""),
                  expectedDescription: "Unsupported card brand",
                  expectedRecovery: "Please use another card"),
            .init(error: OmiseError.api(code: .invalidCard([.other("")]), message: "", location: ""),
                  expectedDescription: "An unknown error occured",
                  expectedRecovery: "Please try again later")
        ]
        
        for testCase in testCases {
            let error = testCase.error
            let expectedDescription = testCase.expectedDescription
            let expectedRecovery = testCase.expectedRecovery
            
            XCTAssertEqual(error.localizedDescription, expectedDescription)
            XCTAssertEqual(error.localizedRecoverySuggestion, expectedRecovery)
        }
    }
    
    func testBadRequestLocalizedDescription1() throws {
        let testCases: [OmiseErrorParsing] = [
            .init(error: OmiseError.api(code: .badRequest([.invalidName]), message: "", location: ""),
                  expectedDescription: "The customer name is invalid",
                  expectedRecovery: "Please review the customer name"),
            .init(error: OmiseError.api(code: .badRequest([.invalidEmail]), message: "", location: ""),
                  expectedDescription: "The customer email is invalid",
                  expectedRecovery: "Please review the email"),
            .init(error: OmiseError.api(code: .badRequest([.invalidCurrency]), message: "", location: ""),
                  expectedDescription: "The currency is invalid",
                  expectedRecovery: "Please choose another currency or contact customer support"),
            .init(error: OmiseError.api(code: .badRequest([.invalidPhoneNumber]), message: "", location: ""),
                  expectedDescription: "The customer phone number is invalid",
                  expectedRecovery: "Please review the phone number"),
            .init(error: OmiseError.api(code: .badRequest([.emptyName]), message: "", location: ""),
                  expectedDescription: "The customer name is empty",
                  expectedRecovery: "Please fill in the customer name"),
            .init(error: OmiseError.api(code: .badRequest([.typeNotSupported]), message: "", location: ""),
                  expectedDescription: "The source type is not supported by this account",
                  expectedRecovery: "Please contact customer support")
        ]
        
        for testCase in testCases {
            let error = testCase.error
            let expectedDescription = testCase.expectedDescription
            let expectedRecovery = testCase.expectedRecovery
            
            XCTAssertEqual(error.localizedDescription, expectedDescription)
            XCTAssertEqual(error.localizedRecoverySuggestion, expectedRecovery)
        }
    }
    
    func testBadRequestLocalizedDescription2() throws {
        let testCases: [OmiseErrorParsing] = [
            .init(error: OmiseError.api(code: .badRequest([.currencyNotSupported]), message: "", location: ""),
                  expectedDescription: "The currency is not supported for this account",
                  expectedRecovery: "Please choose another currency"),
            .init(error: OmiseError.api(code: .badRequest([.other("")]), message: "", location: ""),
                  expectedDescription: "Unknown error occurred",
                  expectedRecovery: "Please try again later"),
            .init(error: OmiseError.api(code: .badRequest([
                .amountIsGreaterThanValidAmount(validAmount: 1000, currency: .sgd)
            ]),
                                        message: "",
                                        location: ""),
                  expectedDescription: "Amount is greater than the valid amount of SGD 10.00",
                  expectedRecovery: "The payment amount is too high. Please make a payment with a lower amount."),
            .init(error: OmiseError.api(code: .badRequest([
                .amountIsLessThanValidAmount(validAmount: 1000, currency: .sgd)
            ]),
                                        message: "",
                                        location: ""),
                  expectedDescription: "Amount is less than the valid amount of SGD 10.00",
                  expectedRecovery: "The payment amount is too low. Please make a payment with a higher amount."),
            .init(error: OmiseError.api(code: .badRequest([
                .amountIsGreaterThanValidAmount(validAmount: nil, currency: nil)
            ]),
                                        message: "",
                                        location: ""),
                  expectedDescription: "Amount is greater than the valid amount",
                  expectedRecovery: "The payment amount is too high. Please make a payment with a lower amount."),
            .init(error: OmiseError.api(code: .badRequest([
                .amountIsLessThanValidAmount(validAmount: nil, currency: nil)
            ]),
                                        message: "",
                                        location: ""),
                  expectedDescription: "Amount is less than the valid amount",
                  expectedRecovery: "The payment amount is too low. Please make a payment with a higher amount."),
            .init(error: OmiseError.api(code: .badRequest([.nameIsTooLong(maximum: 100)]), message: "", location: ""),
                  expectedDescription: "The customer name exceeds 100 characters",
                  expectedRecovery: "Please review the customer name"),
            .init(error: OmiseError.api(code: .badRequest([.nameIsTooLong(maximum: nil)]), message: "", location: ""),
                  expectedDescription: "The customer name is too long",
                  expectedRecovery: "Please review the customer name")
        ]
        
        for testCase in testCases {
            let error = testCase.error
            let expectedDescription = testCase.expectedDescription
            let expectedRecovery = testCase.expectedRecovery
            
            XCTAssertEqual(error.localizedDescription, expectedDescription)
            XCTAssertEqual(error.localizedRecoverySuggestion, expectedRecovery)
        }
    }
    
    func testOtherErrorLocalizedDescription() throws {
        let testCases: [OmiseErrorParsing] = [
            .init(error: OmiseError.api(code: .authenticationFailure, message: "", location: ""),
                  expectedDescription: "An unexpected error occured",
                  expectedRecovery: "Please try again later",
                  expectedErrorDescription: "Authentication failure"),
            .init(error: OmiseError.api(code: .serviceNotFound, message: "", location: ""),
                  expectedDescription: "An unexpected error occured",
                  expectedRecovery: "Please try again later",
                  expectedErrorDescription: "Service not found"),
            .init(error: OmiseError.api(code: .other(""), message: "", location: ""),
                  expectedDescription: "An unknown error occured",
                  expectedRecovery: "Please try again later")
        ]
        
        for testCase in testCases {
            let error = testCase.error
            let expectedDescription = testCase.expectedDescription
            let expectedRecovery = testCase.expectedRecovery
            let expectedErrorDescription = testCase.expectedErrorDescription
            
            XCTAssertEqual(error.localizedDescription, expectedDescription)
            XCTAssertEqual(error.errorDescription, expectedErrorDescription)
            XCTAssertEqual(error.localizedRecoverySuggestion, expectedRecovery)
        }
    }
    
    func testUnexpectedErrorLocalizedDescription() throws {
        let testCases: [OmiseErrorParsing] = [
            .init(error: OmiseError.unexpected(error: .noErrorNorResponse, underlying: nil),
                  expectedErrorDescription: "No error nor response"),
            .init(error: OmiseError.unexpected(error: .httpErrorWithNoData, underlying: nil),
                  expectedErrorDescription: "No error data in the error response"),
            .init(error: OmiseError.unexpected(error: .httpErrorResponseWithInvalidData, underlying: nil),
                  expectedErrorDescription: "Invalid error data in the error response"),
            .init(error: OmiseError.unexpected(error: .httpSuccessWithNoData, underlying: nil),
                  expectedErrorDescription: "No data in the success response"),
            .init(error: OmiseError.unexpected(error: .httpSuccessWithInvalidData, underlying: nil),
                  expectedErrorDescription: "Invalid data in the success response"),
            .init(error: OmiseError.unexpected(error: .unrecognizedHTTPStatusCode(code: 9), underlying: nil),
                  expectedErrorDescription: "Unrecognized/unsupported HTTP status code"),
            .init(error: OmiseError.unexpected(error: .other("API Error"), underlying: nil),
                  expectedErrorDescription: "API Error")
        ]
        
        for testCase in testCases {
            let error = testCase.error
            let expectedErrorDescription = testCase.expectedErrorDescription
            
            XCTAssertEqual(error.errorDescription, expectedErrorDescription)
            XCTAssertEqual(error.localizedDescription, "An unexpected error occurred")
            XCTAssertEqual(error.localizedRecoverySuggestion, "Please try again later")
        }
    }
    
    func testMessageNotEmptyLocalizedDescription() throws {
        let error = OmiseError.api(code: .badRequest([.other("")]),
                                   message: "API Error",
                                   location: "")
        
        XCTAssertEqual(error.localizedDescription, "API Error")
        XCTAssertEqual(error.localizedRecoverySuggestion, "")
    }
    
    func test_init_withAmountMustBePrefix() throws {
        let message = "amount must be 1000"
        let actual = try OmiseError.APIErrorCode.BadRequestReason(message: message, currency: .main)
        XCTAssertEqual(actual.defaultLocalizedErrorDescription, "Bad request: amount must be 1000")
    }
    
    func test_init_withCurrencyMustBeSubstring() throws {
        let message = "the currency must be USD"
        let actual = try OmiseError.APIErrorCode.BadRequestReason(message: message, currency: .main)
        XCTAssertEqual(actual, .invalidCurrency)
    }
    
    func test_init_withTypeSubstring() throws {
        let message = "unsupported type provided"
        let actual = try OmiseError.APIErrorCode.BadRequestReason(message: message, currency: .main)
        XCTAssertEqual(actual, .typeNotSupported)
    }
    
    func test_init_withCurrencySubstring() throws {
        let message = "provided currency is not supported"
        let actual = try OmiseError.APIErrorCode.BadRequestReason(message: message, currency: .main)
        XCTAssertEqual(actual, .currencyNotSupported)
    }
    
    func test_init_withNameAndBlank() throws {
        let message = "name is blank"
        let actual = try OmiseError.APIErrorCode.BadRequestReason(message: message, currency: .main)
        XCTAssertEqual(actual, .emptyName)
    }
    
    func test_init_withNameIsTooLongPrefix_validParsing() throws {
        let message = "name is too long: maximum is 30"
        let actual = try OmiseError.APIErrorCode.BadRequestReason(message: message, currency: .main)
        XCTAssertEqual(actual.defaultLocalizedErrorDescription, "The customer name is too long")
        
    }
    
    func test_init_withNameSubstring_notTooLongOrBlank() throws {
        let message = "name is unacceptable"
        let actual = try OmiseError.APIErrorCode.BadRequestReason(message: message, currency: .main)
        XCTAssertEqual(actual, .nameIsTooLong(maximum: nil))
    }
    
    func test_init_withEmailSubstring() throws {
        let message = "email format is not correct"
        let actual = try OmiseError.APIErrorCode.BadRequestReason(message: message, currency: .main)
        XCTAssertEqual(actual, .invalidEmail)
    }
    
    func test_init_withPhoneSubstring() throws {
        let message = "phone number is invalid"
        let actual = try OmiseError.APIErrorCode.BadRequestReason(message: message, currency: .main)
        XCTAssertEqual(actual, .invalidPhoneNumber)
    }
    
    func test_init_withNoMatchingPattern() throws {
        let message = "an unexpected error occurred"
        let actual = try OmiseError.APIErrorCode.BadRequestReason(message: message, currency: .main)
        XCTAssertEqual(actual, .other(message))
    }
    
    func test_parseBadRequestReasonsFromMessage_returnsExpectedReasons() throws {
        let message = """
            amount must be 1000, the currency must be USD, unsupported type, \
            provided currency is not supported, name blank, \
            name is too long: maximum is 30, name is unacceptable, \
            email format error, phone is missing, and unexpected error
            """
        
        let parsedReasons = try OmiseError.APIErrorCode.BadRequestReason.parseBadRequestReasonsFromMessage(message, currency: .main)
        
        let expectedReasons: [OmiseError.APIErrorCode.BadRequestReason] = [
            .other("amount must be 1000"),
            .invalidCurrency,
            .typeNotSupported,
            .currencyNotSupported,
            .emptyName,
            .nameIsTooLong(maximum: nil),
            .invalidEmail,
            .invalidPhoneNumber,
            .other("unexpected error")
        ]
        
        let sortedParsed = parsedReasons.sorted { "\($0)" < "\($1)" }
        let sortedExpected = expectedReasons.sorted { "\($0)" < "\($1)" }
        XCTAssertEqual(sortedParsed, sortedExpected)
    }
}

private struct OmiseErrorParsing {
    let error: OmiseError
    var expectedDescription: String = ""
    var expectedRecovery: String = ""
    var expectedErrorDescription: String = ""
}
