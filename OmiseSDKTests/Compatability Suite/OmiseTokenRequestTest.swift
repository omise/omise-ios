import XCTest
import OmiseSDK


@available(*, deprecated)
class OmiseTokenRequestTest: XCTestCase {
    private let publicKey = "<#Omise Public Key#>"
    private let timeout: TimeInterval = 15.0
    
    var testClient: OmiseSDKClient {
        return OmiseSDKClient(publicKey: publicKey)
    }
    
    var testRequest: OmiseTokenRequest {
        return OmiseTokenRequest(
            name: "JOHN DOE",
            number: "4242424242424242",
            expirationMonth: 11,
            expirationYear: 2020,
            securityCode: "123"
        )
    }
    
    var invalidRequest: OmiseTokenRequest {
        return OmiseTokenRequest(
            name: "JOHN DOE",
            number: "42424242424242421111", // invalid number
            expirationMonth: 11,
            expirationYear: 2020,
            securityCode: "123",
            city: nil,
            postalCode: nil
        )
    }
    
    func testRequestWithDelegate() {
        let expectation = self.expectation(description: "async delegate calls")
        let delegate = TokenRequestDelegateDummy(expectation: expectation)
        testClient.send(testRequest, delegate: delegate)

        waitForExpectations(timeout: timeout) { (error) in
            if let error = error {
                return XCTFail("expectation error: \(error)")
            }
            
            XCTAssertNotNil(delegate.token)
            XCTAssertNil(delegate.error)
            
            XCTAssertEqual("4242", delegate.token?.card?.lastDigits)
            XCTAssertEqual(11, delegate.token?.card?.expirationMonth)
            XCTAssertEqual(2020, delegate.token?.card?.expirationYear)
        }
    }
    
    func testRequestWithCallback() {
        let expectation = self.expectation(description: "callback")
        testClient.send(testRequest) { (result) in
            defer { expectation.fulfill() }
            switch result {
            case .succeed(token: let token):
                XCTAssertEqual("4242", token.card?.lastDigits)
                XCTAssertEqual(11, token.card?.expirationMonth)
                XCTAssertEqual(2020, token.card?.expirationYear)
            case .fail(let error):
                XCTFail("Expected succeed request but failed with \(error)")
            }
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testBadRequestWithDelegate() {
        let expectation = self.expectation(description: "async delegate calls")
        let delegate = TokenRequestDelegateDummy(expectation: expectation)
        testClient.send(invalidRequest, delegate: delegate)
        
        waitForExpectations(timeout: timeout) { (error) in
            if let error = error {
                return XCTFail("expectation error: \(error)")
            }
            
            XCTAssertNil(delegate.token)
            XCTAssertNotNil(delegate.error)
        }
    }
    
    func testBadRequestWithCallback() {
        let expectation = self.expectation(description: "callback")
        testClient.send(invalidRequest) { (result) in
            defer { expectation.fulfill() }
            if case .succeed = result {
                XCTFail("Expected failed request")
            }
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
}

