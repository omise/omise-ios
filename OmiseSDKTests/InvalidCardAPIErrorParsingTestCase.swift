import XCTest
@testable import OmiseSDK

class InvalidCardAPIErrorParsingTestCase: XCTestCase {

    func testParseInvalidCardNumber() throws {
        do {
            let errorJSONString = """
				{
				  "object": "error",
				  "location": "https://www.omise.co/api-errors#invalid-card",
				  "code": "invalid_card",
				  "message": "number can't be blank and brand not supported (unknown)"
				}
				"""
            
            let decoder = JSONDecoder()
            let parsedError = try decoder.decode(OmiseError.self, from: Data(errorJSONString.utf8))
            if case .api(code: .invalidCard(let reasons), message: _, location: _) = parsedError {
                XCTAssertEqual(reasons, [OmiseError.APIErrorCode.InvalidCardReason.invalidCardNumber])
            } else {
                XCTFail("Parsing results with the wrong code")
            }
        }
        
        do {
            let errorJSONString = """
                {
                  "object": "error",
                  "location": "https://www.omise.co/api-errors#invalid-card",
                  "code": "invalid_card",
                  "message": "number is invalid and brand not supported (unknown)"
                }
                """
            
            let decoder = JSONDecoder()
            let parsedError = try decoder.decode(OmiseError.self, from: Data(errorJSONString.utf8))
            if case .api(code: .invalidCard(let reasons), message: _, location: _) = parsedError {
                XCTAssertEqual(reasons, [OmiseError.APIErrorCode.InvalidCardReason.invalidCardNumber])
            } else {
                XCTFail("Parsing results with the wrong code")
            }
        }
    }
    
    func testParseEmptyCardHolderName() throws {
        do {
            let errorJSONString = """
                {
                  "object": "error",
                  "location": "https://www.omise.co/api-errors#invalid-card",
                  "code": "invalid_card",
                  "message": "name can't be blank"
                }
                """
            
            let decoder = JSONDecoder()
            let parsedError = try decoder.decode(OmiseError.self, from: Data(errorJSONString.utf8))
            if case .api(code: .invalidCard(let reasons), message: _, location: _) = parsedError {
                XCTAssertEqual(reasons, [OmiseError.APIErrorCode.InvalidCardReason.emptyCardHolderName])
            } else {
                XCTFail("Parsing results with the wrong code")
            }
        }
    }
    
    func testParseInvalidExpirationDate() throws {
        do {
            let errorJSONString = """
                {
                  "object": "error",
                  "location": "https://www.omise.co/api-errors#invalid-card",
                  "code": "invalid_card",
                  "message": "expiration date cannot be in the past"
                }
                """
            
            let decoder = JSONDecoder()
            let parsedError = try decoder.decode(OmiseError.self, from: Data(errorJSONString.utf8))
            if case .api(code: .invalidCard(let reasons), message: _, location: _) = parsedError {
                XCTAssertEqual(reasons, [OmiseError.APIErrorCode.InvalidCardReason.invalidExpirationDate])
            } else {
                XCTFail("Parsing results with the wrong code")
            }
        }
        
        do {
            let errorJSONString = """
                {
                  "object": "error",
                  "location": "https://www.omise.co/api-errors#invalid-card",
                  "code": "invalid_card",
                  "message": "expiration year is invalid"
                }
                """
            
            let decoder = JSONDecoder()
            let parsedError = try decoder.decode(OmiseError.self, from: Data(errorJSONString.utf8))
            if case .api(code: .invalidCard(let reasons), message: _, location: _) = parsedError {
                XCTAssertEqual(reasons, [OmiseError.APIErrorCode.InvalidCardReason.invalidExpirationDate])
            } else {
                XCTFail("Parsing results with the wrong code")
            }
        }
        
        do {
            let errorJSONString = """
                {
                  "object": "error",
                  "location": "https://www.omise.co/api-errors#invalid-card",
                  "code": "invalid_card",
                  "message": "expiration month is not between 1 and 12, expiration year is invalid, and expiration date is invalid"
                }
                """
            
            let decoder = JSONDecoder()
            let parsedError = try decoder.decode(OmiseError.self, from: Data(errorJSONString.utf8))
            if case .api(code: .invalidCard(let reasons), message: _, location: _) = parsedError {
                XCTAssertEqual(reasons, [OmiseError.APIErrorCode.InvalidCardReason.invalidExpirationDate])
            } else {
                XCTFail("Parsing results with the wrong code")
            }
        }
        
        do {
            let errorJSONString = """
                {
                  "object": "error",
                  "location": "https://www.omise.co/api-errors#invalid-card",
                  "code": "invalid_card",
                  "message": "expiration month is not between 1 and 12 and expiration date is invalid"
                }
                """
            
            let decoder = JSONDecoder()
            let parsedError = try decoder.decode(OmiseError.self, from: Data(errorJSONString.utf8))
            if case .api(code: .invalidCard(let reasons), message: _, location: _) = parsedError {
                XCTAssertEqual(reasons, [OmiseError.APIErrorCode.InvalidCardReason.invalidExpirationDate])
            } else {
                XCTFail("Parsing results with the wrong code")
            }
        }
    }
    
    func testParseErrorWithMultipleReasons() throws {
        do {
            let errorJSONString = """
                {
                  "object": "error",
                  "location": "https://www.omise.co/api-errors#invalid-card",
                  "code": "invalid_card",
                  "message": "expiration year is invalid, number is invalid, and brand not supported (unknown)"
                }
                """
            
            let decoder = JSONDecoder()
            let parsedError = try decoder.decode(OmiseError.self, from: Data(errorJSONString.utf8))
            if case .api(code: .invalidCard(let reasons), message: _, location: _) = parsedError {
                XCTAssertEqual(reasons, [OmiseError.APIErrorCode.InvalidCardReason.invalidCardNumber, .invalidExpirationDate])
            } else {
                XCTFail("Parsing results with the wrong code")
            }
        }
        
        do {
            let errorJSONString = """
                {
                  "object": "error",
                  "location": "https://www.omise.co/api-errors#invalid-card",
                  "code": "invalid_card",
                  "message": "name can't be blank, expiration year is invalid, number is invalid, and brand not supported (unknown)"
                }
                """
            
            let decoder = JSONDecoder()
            let parsedError = try decoder.decode(OmiseError.self, from: Data(errorJSONString.utf8))
            if case .api(code: .invalidCard(let reasons), message: _, location: _) = parsedError {
                XCTAssertEqual(reasons, [OmiseError.APIErrorCode.InvalidCardReason.invalidCardNumber, .invalidExpirationDate, .emptyCardHolderName])
            } else {
                XCTFail("Parsing results with the wrong code")
            }
        }
        
        do {
            let errorJSONString = """
                {
                  "object": "error",
                  "location": "https://www.omise.co/api-errors#invalid-card",
                  "code": "invalid_card",
                  "message": "expiration month is not between 1 and 12, name can't be blank, expiration year is invalid, expiration date is invalid, number is invalid, and brand not supported (unknown)"
                }
                """
            
            let decoder = JSONDecoder()
            let parsedError = try decoder.decode(OmiseError.self, from: Data(errorJSONString.utf8))
            if case .api(code: .invalidCard(let reasons), message: _, location: _) = parsedError {
                XCTAssertEqual(reasons, [OmiseError.APIErrorCode.InvalidCardReason.invalidCardNumber, .invalidExpirationDate, .emptyCardHolderName])
            } else {
                XCTFail("Parsing results with the wrong code")
            }
        }
        
        do {
            let errorJSONString = """
                {
                  "object": "error",
                  "location": "https://www.omise.co/api-errors#invalid-card",
                  "code": "invalid_card",
                  "message": "expiration month can't be blank and expiration month is not between 1 and 12"
                }
                """
            
            let decoder = JSONDecoder()
            let parsedError = try decoder.decode(OmiseError.self, from: Data(errorJSONString.utf8))
            if case .api(code: .invalidCard(let reasons), message: _, location: _) = parsedError {
                XCTAssertEqual(reasons, [.invalidExpirationDate])
            } else {
                XCTFail("Parsing results with the wrong code")
            }
        }
    }

}
