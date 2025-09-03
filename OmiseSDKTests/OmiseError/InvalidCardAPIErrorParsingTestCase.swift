import XCTest
@testable import OmiseSDK

// swiftlint:disable:next type_body_length
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
    
    // swiftlint:disable:next function_body_length
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
    
    // swiftlint:disable:next function_body_length
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
                XCTAssertEqual(reasons, [.invalidCardNumber, .invalidExpirationDate])
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
                XCTAssertEqual(reasons, [.invalidCardNumber, .invalidExpirationDate, .emptyCardHolderName])
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
                XCTAssertEqual(reasons, [.invalidCardNumber, .invalidExpirationDate, .emptyCardHolderName])
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
    
    func testInitMessage_detectsInvalidCardNumber() throws {
        let reason = try OmiseError.APIErrorCode.InvalidCardReason(message: "number is wrong")
        XCTAssertEqual(reason, .invalidCardNumber)
    }
    
    func testInitMessage_detectsInvalidExpirationDate() throws {
        let reason = try OmiseError.APIErrorCode.InvalidCardReason(message: "expiration date missing")
        XCTAssertEqual(reason, .invalidExpirationDate)
    }
    
    func testInitMessage_detectsEmptyCardHolderName() throws {
        let reason = try OmiseError.APIErrorCode.InvalidCardReason(message: "name is blank")
        XCTAssertEqual(reason, .emptyCardHolderName)
    }
    
    func testInitMessage_detectsUnsupportedBrand() throws {
        let reason = try OmiseError.APIErrorCode.InvalidCardReason(message: "brand not supported")
        XCTAssertEqual(reason, .unsupportedBrand)
    }
    
    func testInitMessage_detectsOther() throws {
        let message = "something else wrong"
        let reason = try OmiseError.APIErrorCode.InvalidCardReason(message: message)
        XCTAssertEqual(reason, .other(message))
    }
    
    func testDefaultLocalizedErrorDescription_forEachCase() {
        XCTAssertEqual(
            OmiseError.APIErrorCode.InvalidCardReason.invalidCardNumber
                .defaultLocalizedErrorDescription,
            "Invalid card number"
        )
        XCTAssertEqual(
            OmiseError.APIErrorCode.InvalidCardReason.invalidExpirationDate
                .defaultLocalizedErrorDescription,
            "Invalid card expiration date"
        )
        XCTAssertEqual(
            OmiseError.APIErrorCode.InvalidCardReason.emptyCardHolderName
                .defaultLocalizedErrorDescription,
            "Invalid card holder name"
        )
        XCTAssertEqual(
            OmiseError.APIErrorCode.InvalidCardReason.unsupportedBrand
                .defaultLocalizedErrorDescription,
            "Unsupported card brand"
        )
        let otherReason = OmiseError.APIErrorCode.InvalidCardReason.other("Oops")
        XCTAssertEqual(otherReason.defaultLocalizedErrorDescription, "Oops")
        let emptyOtherReason = OmiseError.APIErrorCode.InvalidCardReason.other("")
        XCTAssertNil(emptyOtherReason.defaultLocalizedErrorDescription)
    }
    
    func testDefaultRecoverySuggestionMessage_forEachCase() {
        XCTAssertEqual(
            OmiseError.APIErrorCode.InvalidCardReason.invalidCardNumber
                .defaultRecoverySuggestionMessage,
            "Please review the card number"
        )
        XCTAssertEqual(
            OmiseError.APIErrorCode.InvalidCardReason.invalidExpirationDate
                .defaultRecoverySuggestionMessage,
            "Please review the card expiration date"
        )
        XCTAssertEqual(
            OmiseError.APIErrorCode.InvalidCardReason.emptyCardHolderName
                .defaultRecoverySuggestionMessage,
            "Please review the card holder name"
        )
        XCTAssertEqual(
            OmiseError.APIErrorCode.InvalidCardReason.unsupportedBrand
                .defaultRecoverySuggestionMessage,
            "Please use another credit card"
        )
        XCTAssertEqual(
            OmiseError.APIErrorCode.InvalidCardReason.other("Oops")
                .defaultRecoverySuggestionMessage,
            "Please review credit card information"
        )
    }
    
    func testDecodable_fromDecoder() throws {
        let decoder = JSONDecoder()
        
        // Use non-failable Data initializer for UTF8 conversion
        let jsonData1 = Data("\"number invalid\"".utf8)
        let reason1 = try decoder.decode(
            OmiseError.APIErrorCode.InvalidCardReason.self,
            from: jsonData1
        )
        XCTAssertEqual(reason1, .invalidCardNumber)
        
        let jsonData2 = Data("\"expiration oops\"".utf8)
        let reason2 = try decoder.decode(
            OmiseError.APIErrorCode.InvalidCardReason.self,
            from: jsonData2
        )
        XCTAssertEqual(reason2, .invalidExpirationDate)
        
        let jsonData3 = Data("\"name empty\"".utf8)
        let reason3 = try decoder.decode(
            OmiseError.APIErrorCode.InvalidCardReason.self,
            from: jsonData3
        )
        XCTAssertEqual(reason3, .emptyCardHolderName)
        
        let jsonData4 = Data("\"brand bad\"".utf8)
        let reason4 = try decoder.decode(
            OmiseError.APIErrorCode.InvalidCardReason.self,
            from: jsonData4
        )
        XCTAssertEqual(reason4, .unsupportedBrand)
        
        let message = "foo bar"
        let jsonData5 = Data("\"\(message)\"".utf8)
        let reason5 = try decoder.decode(
            OmiseError.APIErrorCode.InvalidCardReason.self,
            from: jsonData5
        )
        XCTAssertEqual(reason5, .other(message))
    }
}
