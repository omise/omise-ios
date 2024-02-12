import XCTest
@testable import OmiseSDK
@testable import OmiseUnitTestKit

private let timeout: TimeInterval = 15.0

class ClientTestCase: XCTestCase {

    static let requestTokenGenerator: OmiseUnitTestKit.TestCaseValueGenerator.GeneratorFunction<Request<Token>> = { gen in
        Request(parameter: Token.CreateParameter(
            name: "JOHN DOE",
            number: "4242424242424242",
            expirationMonth: 11,
            expirationYear: gen.cases(.valid(2030), .invalid(2016, "Expired")),
            securityCode: "123"
        ))
    }

    var testClient: ClientOld!
    override func setUp() {
        super.setUp()
        testClient = ClientOld(publicKey: "pkey_test_58wfnlwoxz1tbkdd993")
    }
    
    override func tearDown() {
        testClient = nil
        super.tearDown()
    }
    
    func testValidTokenRequestWithCallback() {
        let expectation = self.expectation(description: "Tokenized Reqeust with a valid token data")
        let tokenRequest = ClientTestCase.makeValidTokenRequest()
        let task = testClient.send(tokenRequest) { (result) in
            defer { expectation.fulfill() }
            switch result {
            case .success(let token):
                XCTAssertEqual("4242", token.card?.lastDigits)
                XCTAssertEqual(11, token.card?.expirationMonth)
                XCTAssertEqual(2030, token.card?.expirationYear)
            case .failure(let error):
                XCTFail("Expected succeed request but it failed with \(error)")
            }
        }
        
        XCTAssertEqual(tokenRequest.parameter.number, task.request.parameter.number)
        XCTAssertEqual(tokenRequest.parameter.expirationMonth, task.request.parameter.expirationMonth)
        XCTAssertEqual(tokenRequest.parameter.expirationYear, task.request.parameter.expirationYear)

        XCTAssertEqual(Token.postURL, task.dataTask.currentRequest?.url)
        XCTAssertEqual("POST", task.dataTask.currentRequest?.httpMethod)
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testInvalidTokenRequestWithCallback() {
        let expectation = self.expectation(description: "Tokenized Reqeust with an invalid token data")
        let tokenRequest = ClientTestCase.makeInvalidTokenRequest()
        let task = testClient.send(tokenRequest) { (result) in
            defer { expectation.fulfill() }
            if case .success = result {
                XCTFail("Expected failed request")
            }
        }
        
        XCTAssertEqual(tokenRequest.parameter.number, task.request.parameter.number)
        XCTAssertEqual(tokenRequest.parameter.expirationMonth, task.request.parameter.expirationMonth)
        XCTAssertEqual(tokenRequest.parameter.expirationYear, task.request.parameter.expirationYear)
        
        XCTAssertEqual(Token.postURL, task.dataTask.currentRequest?.url)
        XCTAssertEqual("POST", task.dataTask.currentRequest?.httpMethod)
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testValidSourceRequestWithCallback() {
        let expectation = self.expectation(description: "SourceOLD Reqeust with a valid token data")
        let task = testClient.send(ClientTestCase.makeValidSourceRequest()) { (result) in
            defer { expectation.fulfill() }
            switch result {
            case .success(let source):
                XCTAssertEqual(100_00, source.amount)
                XCTAssertEqual(Currency.thb, source.currency)
                XCTAssertEqual(Flow.redirect, source.flow)
                XCTAssertEqual(PaymentInformation.internetBanking(.bay), source.paymentInformation)
            case .failure(let error):
                XCTFail("Expected succeed request but it failed with \(error)")
            }
        }
        
        XCTAssertEqual(100_00, task.request.parameter.amount)
        XCTAssertEqual(Currency.thb, task.request.parameter.currency)
        XCTAssertEqual(PaymentInformation.internetBanking(.bay), task.request.parameter.paymentInformation)
        
        XCTAssertEqual(SourceOLD.postURL, task.dataTask.currentRequest?.url)
        XCTAssertEqual("POST", task.dataTask.currentRequest?.httpMethod)
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testInvalidSourceRequestWithCallback() {
        let expectation = self.expectation(description: "SourceOLD Reqeust with an invalid source data")
        let task = testClient.send(ClientTestCase.makeInvalidSourceRequest()) { (result) in
            defer { expectation.fulfill() }
            if case .success = result {
                XCTFail("Expected failed request")
            }
        }
        
        XCTAssertEqual(100_00, task.request.parameter.amount)
        XCTAssertEqual(Currency.custom(code: "UNSUPPORTED_CURRENCY", factor: 100), task.request.parameter.currency)
        XCTAssertEqual(
            PaymentInformation.other(type: "UNSUPPORTED SOURCE", parameters: [ "client_id": "client_12345", "client_balance": 12345.67]),
            task.request.parameter.paymentInformation
        )

        XCTAssertEqual(SourceOLD.postURL, task.dataTask.currentRequest?.url)
        XCTAssertEqual("POST", task.dataTask.currentRequest?.httpMethod)
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
}

extension ClientTestCase {

    // MARK: Request factory methods
    static func makeValidTokenRequest() -> Request<Token> {
        // swiftlint:disable:next force_unwrapping
        TestCaseValueGenerator.validCases(self.requestTokenGenerator).first!
    }
    static func makeInvalidTokenRequest() -> Request<Token> {
        // swiftlint:disable:next force_unwrapping
        TestCaseValueGenerator.invalidCases(self.requestTokenGenerator).first!
    }
    
    static func makeValidSourceRequest() -> Request<SourceOLD> {
        return Request(paymentInformation: PaymentInformation.internetBanking(.bay), amount: 100_00, currency: .thb)
    }
    static func makeInvalidSourceRequest() -> Request<SourceOLD> {
        return Request(
            paymentInformation: .other(type: "UNSUPPORTED SOURCE", parameters: [ "client_id": "client_12345", "client_balance": 12345.67]),
            amount: 100_00,
            currency: Currency.custom(code: "UNSUPPORTED_CURRENCY", factor: 100)
        )
    }
}
