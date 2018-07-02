import XCTest
@testable import OmiseSDK

private let timeout: TimeInterval = 15.0

class ClientTestCase: XCTestCase {
    
    var testClient: Client!
    override func setUp() {
        super.setUp()
        testClient = Client(publicKey: "pkey_test_58wfnlwoxz1tbkdd993")
    }
    
    override func tearDown() {
        testClient = nil
        super.tearDown()
    }
    
    func testValidTokenRequestWithCallback() {
        let expectation = self.expectation(description: "Tokenized Reqeust with a valid token data")
        let task = testClient.sendRequest(ClientTestCase.makeValidTokenRequest()) { (result) in
            defer { expectation.fulfill() }
            switch result {
            case .success(let token):
                XCTAssertEqual("4242", token.card.lastDigits)
                XCTAssertEqual(11, token.card.expirationMonth)
                XCTAssertEqual(2019, token.card.expirationYear)
            case .fail(let error):
                XCTFail("Expected succeed request but it failed with \(error)")
            }
        }
        
        XCTAssertEqual("4242424242424242", task.request.parameter.number)
        XCTAssertEqual(11, task.request.parameter.expirationMonth)
        XCTAssertEqual(2019, task.request.parameter.expirationYear)
        
        XCTAssertEqual(Token.postURL, task.dataTask.currentRequest?.url)
        XCTAssertEqual("POST", task.dataTask.currentRequest?.httpMethod)
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testInvalidTokenRequestWithCallback() {
        let expectation = self.expectation(description: "Tokenized Reqeust with an invalid token data")
        let task = testClient.sendRequest(ClientTestCase.makeInvalidTokenRequest()) { (result) in
            defer { expectation.fulfill() }
            if case .success = result {
                XCTFail("Expected failed request")
            }
        }
        
        XCTAssertEqual("4242424242111111", task.request.parameter.number)
        XCTAssertEqual(11, task.request.parameter.expirationMonth)
        XCTAssertEqual(2016, task.request.parameter.expirationYear)
        
        XCTAssertEqual(Token.postURL, task.dataTask.currentRequest?.url)
        XCTAssertEqual("POST", task.dataTask.currentRequest?.httpMethod)
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testValidSourceRequestWithCallback() {
        let expectation = self.expectation(description: "Source Reqeust with a valid token data")
        let task = testClient.sendRequest(ClientTestCase.makeValidSourceRequest()) { (result) in
            defer { expectation.fulfill() }
            switch result {
            case .success(let source):
                XCTAssertEqual(100_00, source.amount)
                XCTAssertEqual(Currency.thb, source.currency)
                XCTAssertEqual(Flow.redirect, source.flow)
                XCTAssertEqual(SourceType.internetBankingBAY, source.type)
            case .fail(let error):
                XCTFail("Expected succeed request but it failed with \(error)")
            }
        }
        
        XCTAssertEqual(100_00, task.request.parameter.amount)
        XCTAssertEqual(Currency.thb, task.request.parameter.currency)
        XCTAssertEqual(SourceType.internetBankingBAY, task.request.parameter.type)
        
        XCTAssertEqual(Source.postURL, task.dataTask.currentRequest?.url)
        XCTAssertEqual("POST", task.dataTask.currentRequest?.httpMethod)
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testInvalidSourceRequestWithCallback() {
        let expectation = self.expectation(description: "Source Reqeust with an invalid source data")
        let task = testClient.sendRequest(ClientTestCase.makeInvalidSourceRequest()) { (result) in
            defer { expectation.fulfill() }
            if case .success = result {
                XCTFail("Expected failed request")
            }
        }
        
        XCTAssertEqual(100_00, task.request.parameter.amount)
        XCTAssertEqual(Currency.custom(code: "UNSUPPORTED_CURRENCY", factor: 100), task.request.parameter.currency)
        XCTAssertEqual(SourceType.other("UNSUPPORTED SOURCE"), task.request.parameter.type)

        XCTAssertEqual(Source.postURL, task.dataTask.currentRequest?.url)
        XCTAssertEqual("POST", task.dataTask.currentRequest?.httpMethod)
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
}

extension ClientTestCase {
    
    // MARK: Request factory methods
    static func makeValidTokenRequest() -> Request<Token>  {
        return Request.init(parameter: Token.CreateParameter(
            name: "JOHN DOE",
            number: "4242424242424242",
            expirationMonth: 11,
            expirationYear: 2019,
            securityCode: "123"
        ))
    }
    static func makeInvalidTokenRequest() -> Request<Token>  {
        return Request.init(parameter: Token.CreateParameter(
            name: "JOHN DOE",
            number: "4242424242111111",
            expirationMonth: 11,
            expirationYear: 2016,
            securityCode: "123"
        ))
    }
    
    static func makeValidSourceRequest() -> Request<Source>  {
        return Request.init(sourceType: SourceType.internetBankingBAY, amount: 100_00, currency: .thb)
    }
    static func makeInvalidSourceRequest() -> Request<Source>  {
        return Request.init(sourceType: SourceType.other("UNSUPPORTED SOURCE"), amount: 100_00, currency: Currency.custom(code: "UNSUPPORTED_CURRENCY", factor: 100))
    }
}
