import Foundation
import XCTest
@testable import OmiseSDK

class OmiseErrorTests: XCTestCase {
    func testInvalidCardLocalizedDescription() throws {
        let testCases: [OmiseErrorParsing] = [
            .init(error: OmiseError.api(code: .invalidCard([.invalidCardNumber]), message: "", location: ""),
                  expectedLocalizedDescription: "Invalid card number",
                  expectedRecovery: "Please review the card number"),
            .init(error: OmiseError.api(code: .invalidCard([.emptyCardHolderName]), message: "", location: ""),
                  expectedLocalizedDescription: "Invalid card holder name",
                  expectedRecovery: "Please review the card holder name"),
            .init(error: OmiseError.api(code: .invalidCard([.invalidExpirationDate]), message: "", location: ""),
                  expectedLocalizedDescription: "Invalid card expiration date",
                  expectedRecovery: "Please review the card expiration date again."),
            .init(error: OmiseError.api(code: .invalidCard([.unsupportedBrand]), message: "", location: ""),
                  expectedLocalizedDescription: "Unsupported card brand",
                  expectedRecovery: "Please use another card"),
            .init(error: OmiseError.api(code: .invalidCard([.other("")]), message: "", location: ""),
                  expectedLocalizedDescription: "An unknown error occured",
                  expectedRecovery: "Please try again later")
        ]
        
        for testCase in testCases {
            let error = testCase.error
            let expectedDescription = testCase.expectedLocalizedDescription
            let expectedRecovery = testCase.expectedRecovery
            
            XCTAssertEqual(error.localizedDescription, expectedDescription)
            XCTAssertEqual(error.localizedRecoverySuggestion, expectedRecovery)
        }
    }
    
    func testOtherErrorLocalizedDescription() throws {
        let testCases: [OmiseErrorParsing] = [
            .init(error: OmiseError.api(code: .authenticationFailure, message: "", location: ""),
                  expectedLocalizedDescription: "An unexpected error occured",
                  expectedLocalizedRecovery: "Please try again later",
                  expectedDescription: "Authentication failure",
                  expectedRecovery: "Please contact the merchant"),
            .init(error: OmiseError.api(code: .serviceNotFound, message: "", location: ""),
                  expectedLocalizedDescription: "An unexpected error occured",
                  expectedLocalizedRecovery: "Please try again later",
                  expectedDescription: "Service not found",
                  expectedRecovery: "Please contact the merchant"),
            .init(error: OmiseError.api(code: .other(""), message: "", location: ""),
                  expectedLocalizedDescription: "An unknown error occured",
                  expectedLocalizedRecovery: "Please try again later",
                  expectedRecovery: nil)
        ]
        
        for testCase in testCases {
            let error = testCase.error
            let expectedDescription = testCase.expectedLocalizedDescription
            let expectedLocalizedRecovery = testCase.expectedLocalizedRecovery
            let expectedErrorDescription = testCase.expectedDescription
            let expectedRecovery = testCase.expectedRecovery
            
            XCTAssertEqual(error.localizedDescription, expectedDescription)
            XCTAssertEqual(error.errorDescription, expectedErrorDescription)
            XCTAssertEqual(error.localizedRecoverySuggestion, expectedLocalizedRecovery)
            XCTAssertEqual(error.recoverySuggestion, expectedRecovery)
        }
    }
    
    func testUnexpectedErrorLocalizedDescription() throws {
        let testCases: [OmiseErrorParsing] = [
            .init(error: OmiseError.unexpected(error: .noErrorNorResponse, underlying: nil),
                  expectedDescription: "No error nor response"),
            .init(error: OmiseError.unexpected(error: .httpErrorWithNoData, underlying: nil),
                  expectedDescription: "No error data in the error response"),
            .init(error: OmiseError.unexpected(error: .httpErrorResponseWithInvalidData, underlying: nil),
                  expectedDescription: "Invalid error data in the error response"),
            .init(error: OmiseError.unexpected(error: .httpSuccessWithNoData, underlying: nil),
                  expectedDescription: "No data in the success response"),
            .init(error: OmiseError.unexpected(error: .httpSuccessWithInvalidData, underlying: nil),
                  expectedDescription: "Invalid data in the success response"),
            .init(error: OmiseError.unexpected(error: .unrecognizedHTTPStatusCode(code: 9), underlying: nil),
                  expectedDescription: "Unrecognized/unsupported HTTP status code"),
            .init(error: OmiseError.unexpected(error: .other("API Error"), underlying: nil),
                  expectedDescription: "API Error")
        ]
        
        for testCase in testCases {
            let error = testCase.error
            let expectedErrorDescription = testCase.expectedDescription
            
            XCTAssertEqual(error.errorDescription, expectedErrorDescription)
            XCTAssertEqual(error.localizedDescription, "An unexpected error occurred")
            XCTAssertEqual(error.localizedRecoverySuggestion, "Please try again later")
        }
    }
    
    // swiftlint:disable:next function_body_length
    func testUnexpectedErrorMessage() throws {
        let underlying: OmiseError = .api(
            code: .authenticationFailure,
            message: "",
            location: "https://docs.omise.co/api-errors"
        )
        let testCases: [OmiseErrorParsing] = [
            .init(error: OmiseError.unexpected(error: .httpErrorResponseWithInvalidData, underlying: underlying),
                  expectedLocalizedDescription: "An unexpected error occurred",
                  expectedLocalizedRecovery: "Please try again later",
                  expectedDescription: "Authentication failure",
                  expectedRecovery: "Please try again later. If the same problem persists please contact customer support."),
            .init(error: OmiseError.unexpected(error: .noErrorNorResponse, underlying: nil),
                  expectedLocalizedDescription: "An unexpected error occurred",
                  expectedLocalizedRecovery: "Please try again later",
                  expectedDescription: "No error nor response",
                  expectedRecovery: "Please try again later. If the same problem persists please contact customer support."),
            .init(error: OmiseError.unexpected(error: .httpErrorWithNoData, underlying: nil),
                  expectedLocalizedDescription: "An unexpected error occurred",
                  expectedLocalizedRecovery: "Please try again later",
                  expectedDescription: "No error data in the error response",
                  expectedRecovery: "Please try again later. If the same problem persists please contact customer support."),
            .init(error: OmiseError.unexpected(error: .httpErrorResponseWithInvalidData, underlying: nil),
                  expectedLocalizedDescription: "An unexpected error occurred",
                  expectedLocalizedRecovery: "Please try again later",
                  expectedDescription: "Invalid error data in the error response",
                  expectedRecovery: "Please try again later. If the same problem persists please contact customer support."),
            .init(error: OmiseError.unexpected(error: .httpSuccessWithNoData, underlying: nil),
                  expectedLocalizedDescription: "An unexpected error occurred",
                  expectedLocalizedRecovery: "Please try again later",
                  expectedDescription: "No data in the success response",
                  expectedRecovery: "Please try again later. If the same problem persists please contact customer support."),
            .init(error: OmiseError.unexpected(error: .httpSuccessWithInvalidData, underlying: nil),
                  expectedLocalizedDescription: "An unexpected error occurred",
                  expectedLocalizedRecovery: "Please try again later",
                  expectedDescription: "Invalid data in the success response",
                  expectedRecovery: "Please try again later. If the same problem persists please contact customer support."),
            .init(error: OmiseError.unexpected(error: .unrecognizedHTTPStatusCode(code: 504), underlying: nil),
                  expectedLocalizedDescription: "An unexpected error occurred",
                  expectedLocalizedRecovery: "Please try again later",
                  expectedDescription: "Unrecognized/unsupported HTTP status code",
                  expectedRecovery: "Please try again later. If the same problem persists please contact customer support."),
            .init(error: OmiseError.unexpected(error: .other("Other Error"), underlying: nil),
                  expectedLocalizedDescription: "An unexpected error occurred",
                  expectedLocalizedRecovery: "Please try again later",
                  expectedDescription: "Other Error",
                  expectedRecovery: nil)
        ]
        
        for testCase in testCases {
            let error = testCase.error
            let expectedLocalizedDescription = testCase.expectedLocalizedDescription
            let expectedLocalizedRecovery = testCase.expectedLocalizedRecovery
            let expectedErrorDescription = testCase.expectedDescription
            let expectedRecovery = testCase.expectedRecovery
            
            XCTAssertEqual(error.localizedDescription, expectedLocalizedDescription)
            XCTAssertEqual(error.errorDescription, expectedErrorDescription)
            XCTAssertEqual(error.localizedRecoverySuggestion, expectedLocalizedRecovery)
            XCTAssertEqual(error.recoverySuggestion, expectedRecovery)
        }
    }
    
    func testUserErrorInfo() {
        let underlying: OmiseError = .api(
            code: .authenticationFailure,
            message: "",
            location: "https://docs.omise.co/api-errors"
        )
        let testCases: [OmiseErrorParsing] = [
            .init(error: OmiseError.api(code: .serviceNotFound, message: "", location: ""),
                  expectedNSLocalizedDescriptionKey: "Service not found"),
            .init(error: OmiseError.unexpected(error: .httpErrorResponseWithInvalidData, underlying: underlying),
                  expectedNSLocalizedDescriptionKey: "Authentication failure"),
            .init(error: OmiseError.unexpected(error: .httpErrorResponseWithInvalidData, underlying: nil),
                  expectedNSLocalizedDescriptionKey: "Invalid error data in the error response")
        ]
        
        for testCase in testCases {
            let error = testCase.error
            let info = error.errorUserInfo
            
            XCTAssertEqual(info[NSLocalizedDescriptionKey] as? String, testCase.expectedNSLocalizedDescriptionKey)
            XCTAssertEqual(info[NSLocalizedDescriptionKey] as? String, testCase.expectedNSLocalizedDescriptionKey)
            
        }
    }
}

internal struct OmiseErrorParsing {
    let error: OmiseError
    var expectedLocalizedDescription: String? = ""
    var expectedLocalizedRecovery: String? = ""
    var expectedDescription: String? = ""
    var expectedRecovery: String? = ""
    var expectedNSLocalizedDescriptionKey: String? = ""
}
