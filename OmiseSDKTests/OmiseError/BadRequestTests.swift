import XCTest
@testable import OmiseSDK

class BadRequestTests: XCTestCase {
    func testParseBadRequestReason() throws {
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
    
    func test_parseBadRequestReasonsFromMessage_returnsExpectedReasons() throws {
        let message = """
            amount must be 1000, the currency must be USD, unsupported type, \
            provided currency is not supported, name blank, \
            name is too long: maximum is 30, name is unacceptable, \
            email format error, your phone is missing, phone number is invalid, invalid name, \
            amount must be greater than 2500, amount must be less than 800 and unexpected error
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
            .invalidName,
            .invalidPhoneNumber,
            .amountIsGreaterThanValidAmount(validAmount: 800, currency: .thb),
            .amountIsLessThanValidAmount(validAmount: 2500, currency: .thb),
            .other("unexpected error")
        ]
        
        let sortedParsed = parsedReasons.sorted { "\($0)" < "\($1)" }
        let sortedExpected = expectedReasons.sorted { "\($0)" < "\($1)" }
        XCTAssertEqual(sortedParsed, sortedExpected)
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
    
    func testBadRequestLocalizedDescription1() throws {
        let testCases: [OmiseErrorParsing] = [
            .init(error: OmiseError.api(code: .badRequest([.invalidName]), message: "", location: ""),
                  expectedLocalizedDescription: "The customer name is invalid",
                  expectedLocalizedRecovery: "Please review the customer name",
                  expectedDescription: "The customer name is invalid",
                  expectedRecovery: "Please review the customer name"),
            .init(error: OmiseError.api(code: .badRequest([.invalidEmail]), message: "", location: ""),
                  expectedLocalizedDescription: "The customer email is invalid",
                  expectedLocalizedRecovery: "Please review the email",
                  expectedDescription: "The customer email is invalid",
                  expectedRecovery: "Please review the customer email"),
            .init(error: OmiseError.api(code: .badRequest([.invalidCurrency]), message: "", location: ""),
                  expectedLocalizedDescription: "The currency is invalid",
                  expectedLocalizedRecovery: "Please choose another currency or contact customer support",
                  expectedDescription: "The currency is invalid",
                  expectedRecovery: "Bad request"),
            .init(error: OmiseError.api(code: .badRequest([.invalidPhoneNumber]), message: "", location: ""),
                  expectedLocalizedDescription: "The customer phone number is invalid",
                  expectedLocalizedRecovery: "Please review the phone number",
                  expectedDescription: "The customer phone number is invalid",
                  expectedRecovery: "Please review the customer phone number"),
            .init(error: OmiseError.api(code: .badRequest([.emptyName]), message: "", location: ""),
                  expectedLocalizedDescription: "The customer name is empty",
                  expectedLocalizedRecovery: "Please fill in the customer name",
                  expectedDescription: "The customer name is empty",
                  expectedRecovery: "Please input customer name"),
            .init(error: OmiseError.api(code: .badRequest([.typeNotSupported]), message: "", location: ""),
                  expectedLocalizedDescription: "The source type is not supported by this account",
                  expectedLocalizedRecovery: "Please contact customer support",
                  expectedDescription: "The source type is not supported by this account",
                  expectedRecovery: "Please review the source type"),
            .init(error: OmiseError.api(code: .badRequest([.currencyNotSupported]), message: "", location: ""),
                  expectedLocalizedDescription: "The currency is not supported for this account",
                  expectedLocalizedRecovery: "Please choose another currency",
                  expectedDescription: "The currency is not supported by this account",
                  expectedRecovery: "Please choose another currency"),
            .init(error: OmiseError.api(code: .badRequest([.other("Other Bad Request")]), message: "", location: ""),
                  expectedLocalizedDescription: "Unknown error occurred",
                  expectedLocalizedRecovery: "Please try again later",
                  expectedDescription: "Bad request: Other Bad Request",
                  expectedRecovery: "Other Bad Request"),
        ]
        
        for testCase in testCases {
            let error = testCase.error
            let expectedLocalizedDescription = testCase.expectedLocalizedDescription
            let expectedLocalizedRecovery = testCase.expectedLocalizedRecovery
            let expectedDescription = testCase.expectedDescription
            let expectedRecovery = testCase.expectedRecovery
            
            XCTAssertEqual(error.localizedDescription, expectedLocalizedDescription)
            XCTAssertEqual(error.localizedRecoverySuggestion, expectedLocalizedRecovery)
            XCTAssertEqual(error.errorDescription, expectedDescription)
            XCTAssertEqual(error.recoverySuggestion, expectedRecovery)
        }
    }
    
    func testBadRequestLocalizedDescription2() throws {
        let testCases: [OmiseErrorParsing] = [
            .init(error: OmiseError.api(code: .badRequest([.amountIsGreaterThanValidAmount(validAmount: 1000, currency: .sgd)]),
                                        message: "",
                                        location: ""),
                  expectedLocalizedDescription: "Amount is greater than the valid amount of SGD 10.00",
                  expectedLocalizedRecovery: "The payment amount is too high. Please make a payment with a lower amount.",
                  expectedDescription: "Amount exceeds the valid amount of SGD 10.00",
                  expectedRecovery: "Please create a source with an amount which is less than SGD 10.00"),
            .init(error: OmiseError.api(code: .badRequest([.amountIsLessThanValidAmount(validAmount: 1000, currency: .sgd)]),
                                        message: "",
                                        location: ""),
                  expectedLocalizedDescription: "Amount is less than the valid amount of SGD 10.00",
                  expectedLocalizedRecovery: "The payment amount is too low. Please make a payment with a higher amount.",
                  expectedDescription: "Amount is less than the valid amount of SGD 10.00",
                  expectedRecovery: "Please create a source with an amount that is greater than SGD 10.00"),
            .init(error: OmiseError.api(code: .badRequest([.amountIsGreaterThanValidAmount(validAmount: nil, currency: nil)]),
                                        message: "",
                                        location: ""),
                  expectedLocalizedDescription: "Amount is greater than the valid amount",
                  expectedLocalizedRecovery: "The payment amount is too high. Please make a payment with a lower amount.",
                  expectedDescription: "Amount exceeds the valid amount",
                  expectedRecovery: "Please create a source with less amount"),
            .init(error: OmiseError.api(code: .badRequest([.amountIsLessThanValidAmount(validAmount: nil, currency: nil)]),
                                        message: "",
                                        location: ""),
                  expectedLocalizedDescription: "Amount is less than the valid amount",
                  expectedLocalizedRecovery: "The payment amount is too low. Please make a payment with a higher amount.",
                  expectedDescription: "Amount is less than the valid amount",
                  expectedRecovery: "Please create a source with a greater amount"),
            .init(error: OmiseError.api(code: .badRequest([.nameIsTooLong(maximum: 100)]), message: "", location: ""),
                  expectedLocalizedDescription: "The customer name exceeds 100 characters",
                  expectedLocalizedRecovery: "Please review the customer name",
                  expectedDescription: "The customer name exceeds the 100 character limit",
                  expectedRecovery: "Please input customer name which is no longer than 100 characters"),
            .init(error: OmiseError.api(code: .badRequest([.nameIsTooLong(maximum: nil)]), message: "", location: ""),
                  expectedLocalizedDescription: "The customer name is too long",
                  expectedLocalizedRecovery: "Please review the customer name",
                  expectedDescription: "The customer name is too long",
                  expectedRecovery: "Please input shorter customer name")
        ]
        
        for testCase in testCases {
            let error = testCase.error
            let expectedLocalizedDescription = testCase.expectedLocalizedDescription
            let expectedLocalizedRecovery = testCase.expectedLocalizedRecovery
            let expectedDescription = testCase.expectedDescription
            let expectedRecovery = testCase.expectedRecovery
            
            XCTAssertEqual(error.localizedDescription, expectedLocalizedDescription)
            XCTAssertEqual(error.localizedRecoverySuggestion, expectedLocalizedRecovery)
            XCTAssertEqual(error.errorDescription, expectedDescription)
            XCTAssertEqual(error.recoverySuggestion, expectedRecovery)
        }
    }
}
