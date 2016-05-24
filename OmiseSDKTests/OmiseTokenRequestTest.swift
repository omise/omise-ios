import XCTest
import OmiseSDK

class OmiseTokenRequestTest: SDKTestCase {
    private let publicKey = "pkey_test_543ehdmlevzpxuqkqhu"
    private let timeout: NSTimeInterval = 15.0
    
    var testClient: OmiseSDKClient {
        return OmiseSDKClient(publicKey: publicKey)
    }
    
    var testRequest: OmiseTokenRequest {
        return OmiseTokenRequest(
            name: "JOHN DOE",
            number: "4242424242424242",
            expirationMonth: 11,
            expirationYear: 2016,
            securityCode: "123"
        )
    }
    
    var invalidRequest: OmiseTokenRequest {
        return OmiseTokenRequest(
            name: "JOHN DOE",
            number: "42424242424242421111", // invalid number
            expirationMonth: 11,
            expirationYear: 2016,
            securityCode: "123",
            city: nil,
            postalCode: nil
        )
    }
    
    func testRequestWithDelegate() {
        let expectation = expectationWithDescription("async delegate calls")
        let delegate = TokenRequestDelegateDummy(expectation: expectation)
        testClient.send(testRequest, delegate: delegate)
        
        waitForExpectationsWithTimeout(timeout) { (error) in
            if let error = error {
                return XCTFail("expectation error: \(error)")
            }
            
            XCTAssertNotNil(delegate.token)
            XCTAssertNil(delegate.error)
        }
    }
    
    func testRequestWithCallback() {
        let expectation = self.expectationWithDescription("callback")
        testClient.send(testRequest) { (token, error) in
            defer { expectation.fulfill() }
            XCTAssertNil(error)
            XCTAssertNotNil(token)
        }
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    func testBadRequestWithDelegate() {
        let expectation = expectationWithDescription("async delegate calls")
        let delegate = TokenRequestDelegateDummy(expectation: expectation)
        testClient.send(invalidRequest, delegate: delegate)
        
        waitForExpectationsWithTimeout(timeout) { (error) in
            if let error = error {
                return XCTFail("expectation error: \(error)")
            }
            
            XCTAssertNil(delegate.token)
            XCTAssertNotNil(delegate.error)
        }
    }
    
    func testBadRequestWithCallback() {
        let expectation = self.expectationWithDescription("callback")
        testClient.send(invalidRequest) { (token, error) in
            defer { expectation.fulfill() }
            XCTAssertNil(token)
            XCTAssertNotNil(error)
        }
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
}
