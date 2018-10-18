import XCTest
@testable import OmiseSDK

class BadRequestAPIErrorParsingTestCase: XCTestCase {
    
    func testParseInvalidAmount() throws {
        do {
            let errorJSONString = """
                {
                  "object": "error",
                  "location": "https://www.omise.co/api-errors#bad-request",
                  "code": "bad_request",
                  "message": "amount must be less than 50000"
                }
                """
            
            let sourceParameter = CreateSourceParameter(paymentInformation: PaymentInformation.alipay, amount: 60_000, currency: .thb)
            let decoder = JSONDecoder()
            decoder.userInfo[sourceParameterCodingsUserInfoKey] = sourceParameter
            let parsedError = try decoder.decode(OmiseError.self, from: Data(errorJSONString.utf8))
            if case .api(code: .badRequest(let reasons), message: _, location: _) = parsedError {
                XCTAssertEqual(reasons, [OmiseError.APIErrorCode.BadRequestReason.amountIsGreaterThanValidAmount(validAmount: 50000, currency: .thb)])
            } else {
                XCTFail("Parsing results with the wrong code")
            }
        }
        
        do {
            let errorJSONString = """
                {
                  "object": "error",
                  "location": "https://www.omise.co/api-errors#bad-request",
                  "code": "bad_request",
                  "message": "amount must be at least 150"
                }
                """
            let sourceParameter = CreateSourceParameter(paymentInformation: PaymentInformation.alipay, amount: 100, currency: .jpy)
            let decoder = JSONDecoder()
            decoder.userInfo[sourceParameterCodingsUserInfoKey] = sourceParameter
            let parsedError = try decoder.decode(OmiseError.self, from: Data(errorJSONString.utf8))
            if case .api(code: .badRequest(let reasons), message: _, location: _) = parsedError {
                XCTAssertEqual(reasons, [OmiseError.APIErrorCode.BadRequestReason.amountIsLessThanValidAmount(validAmount: 150, currency: .jpy )])
            } else {
                XCTFail("Parsing results with the wrong code")
            }
        }
        
        do {
            let errorJSONString = """
                {
                  "object": "error",
                  "location": "https://www.omise.co/api-errors#bad-request",
                  "code": "bad_request",
                  "message": "amount must be greater than 500000"
                }
                """
            let sourceParameter = CreateSourceParameter(paymentInformation: PaymentInformation.alipay, amount: 60_000, currency: .thb)
            let decoder = JSONDecoder()
            decoder.userInfo[sourceParameterCodingsUserInfoKey] = sourceParameter
            let parsedError = try decoder.decode(OmiseError.self, from: Data(errorJSONString.utf8))
            if case .api(code: .badRequest(let reasons), message: _, location: _) = parsedError {
                XCTAssertEqual(reasons, [OmiseError.APIErrorCode.BadRequestReason.amountIsLessThanValidAmount(validAmount: 500000, currency: .thb)])
            } else {
                XCTFail("Parsing results with the wrong code")
            }
        }
    }
    
    func testParseInvalidEContextCustomerInformation() throws {
        do {
            let errorJSONString = """
                {
                  "object": "error",
                  "location": "https://www.omise.co/api-errors#bad-request",
                  "code": "bad_request",
                  "message": "name is too long (maximum is 10 characters)"
                }
                """
            
            let decoder = JSONDecoder()
            let parsedError = try decoder.decode(OmiseError.self, from: Data(errorJSONString.utf8))
            if case .api(code: .badRequest(let reasons), message: _, location: _) = parsedError {
                XCTAssertEqual(reasons, [OmiseError.APIErrorCode.BadRequestReason.nameIsTooLong(maximum: 10)])
            } else {
                XCTFail("Parsing results with the wrong code")
            }
        }
        
        do {
            let errorJSONString = """
                {
                  "object": "error",
                  "location": "https://www.omise.co/api-errors#bad-request",
                  "code": "bad_request",
                  "message": "name cannot be blank"
                }
                """
            
            let decoder = JSONDecoder()
            let parsedError = try decoder.decode(OmiseError.self, from: Data(errorJSONString.utf8))
            if case .api(code: .badRequest(let reasons), message: _, location: _) = parsedError {
                XCTAssertEqual(reasons, [OmiseError.APIErrorCode.BadRequestReason.emptyName])
            } else {
                XCTFail("Parsing results with the wrong code")
            }
        }
        
        do {
            let errorJSONString = """
                {
                  "object": "error",
                  "location": "https://www.omise.co/api-errors#bad-request",
                  "code": "bad_request",
                  "message": "email is in invalid format"
                }
                """
            
            let decoder = JSONDecoder()
            let parsedError = try decoder.decode(OmiseError.self, from: Data(errorJSONString.utf8))
            if case .api(code: .badRequest(let reasons), message: _, location: _) = parsedError {
                XCTAssertEqual(reasons, [OmiseError.APIErrorCode.BadRequestReason.invalidEmail])
            } else {
                XCTFail("Parsing results with the wrong code")
            }
        }
        
        do {
            let errorJSONString = """
                {
                  "object": "error",
                  "location": "https://www.omise.co/api-errors#bad-request",
                  "code": "bad_request",
                  "message": "phone_number must contain 10-11 digit characters"
                }
                """
            
            let decoder = JSONDecoder()
            let parsedError = try decoder.decode(OmiseError.self, from: Data(errorJSONString.utf8))
            if case .api(code: .badRequest(let reasons), message: _, location: _) = parsedError {
                XCTAssertEqual(reasons, [OmiseError.APIErrorCode.BadRequestReason.invalidPhoneNumber])
            } else {
                XCTFail("Parsing results with the wrong code")
            }
        }
    }
    
    
    func testParseBadRequestParameters() throws {
        do {
            let errorJSONString = """
                {
                  "object": "error",
                  "location": "https://www.omise.co/api-errors#bad-request",
                  "code": "bad_request",
                  "message": "currency must be JPYs"
                }
                """
            
            let decoder = JSONDecoder()
            let parsedError = try decoder.decode(OmiseError.self, from: Data(errorJSONString.utf8))
            if case .api(code: .badRequest(let reasons), message: _, location: _) = parsedError {
                XCTAssertEqual(reasons, [OmiseError.APIErrorCode.BadRequestReason.invalidCurrency])
            } else {
                XCTFail("Parsing results with the wrong code")
            }
        }
        
        do {
            let errorJSONString = """
                {
                  "object": "error",
                  "location": "https://www.omise.co/api-errors#bad-request",
                  "code": "bad_request",
                  "message": "type is currently not supported"
                }
                """
            
            let decoder = JSONDecoder()
            let parsedError = try decoder.decode(OmiseError.self, from: Data(errorJSONString.utf8))
            if case .api(code: .badRequest(let reasons), message: _, location: _) = parsedError {
                XCTAssertEqual(reasons, [OmiseError.APIErrorCode.BadRequestReason.typeNotSupported])
            } else {
                XCTFail("Parsing results with the wrong code")
            }
        }
        do {
            let errorJSONString = """
                {
                  "object": "error",
                  "location": "https://www.omise.co/api-errors#bad-request",
                  "code": "bad_request",
                  "message": "currency is currently not supported"
                }
                """
            
            let decoder = JSONDecoder()
            let parsedError = try decoder.decode(OmiseError.self, from: Data(errorJSONString.utf8))
            if case .api(code: .badRequest(let reasons), message: _, location: _) = parsedError {
                XCTAssertEqual(reasons, [OmiseError.APIErrorCode.BadRequestReason.currencyNotSupported])
            } else {
                XCTFail("Parsing results with the wrong code")
            }
        }
        
    }
    
    
    func testParseMultipleReasons() throws {
        do {
            let errorJSONString = """
                {
                  "object": "error",
                  "location": "https://www.omise.co/api-errors#bad-request",
                  "code": "bad_request",
                  "message": "amount must be less than 50000 and currency must be JPY"
                }
                """
            
            let sourceParameter = CreateSourceParameter(paymentInformation: PaymentInformation.alipay, amount: 60_000, currency: .thb)
            let decoder = JSONDecoder()
            decoder.userInfo[sourceParameterCodingsUserInfoKey] = sourceParameter
            let parsedError = try decoder.decode(OmiseError.self, from: Data(errorJSONString.utf8))
            if case .api(code: .badRequest(let reasons), message: _, location: _) = parsedError {
                XCTAssertEqual(reasons, [OmiseError.APIErrorCode.BadRequestReason.amountIsGreaterThanValidAmount(validAmount: 50000, currency: .thb), .invalidCurrency])
            } else {
                XCTFail("Parsing results with the wrong code")
            }
        }
        
        do {
            let errorJSONString = """
                {
                  "object": "error",
                  "location": "https://www.omise.co/api-errors#bad-request",
                  "code": "bad_request",
                  "message": "name cannot be blank, email is in invalid format, and phone_number must contain 10-11 digit characters"
                }
                """
            
            let decoder = JSONDecoder()
            let parsedError = try decoder.decode(OmiseError.self, from: Data(errorJSONString.utf8))
            if case .api(code: .badRequest(let reasons), message: _, location: _) = parsedError {
                XCTAssertEqual(reasons, [OmiseError.APIErrorCode.BadRequestReason.emptyName, .invalidEmail, .invalidPhoneNumber])
            } else {
                XCTFail("Parsing results with the wrong code")
            }
        }
    }
}
