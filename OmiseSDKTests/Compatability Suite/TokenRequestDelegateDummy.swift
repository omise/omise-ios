import XCTest
import OmiseSDK

class TokenRequestDelegateDummy: OmiseTokenRequestDelegate {
    var request: OmiseTokenRequest? = nil
    var token: OmiseToken? = nil
    var error: Error? = nil
    
    let expectation: XCTestExpectation
    
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }
    
    func tokenRequest(_ request: OmiseTokenRequest, didSucceedWithToken token: OmiseToken) {
        defer { expectation.fulfill() }
        self.request = request
        self.token = token
    }
    
    func tokenRequest(_ request: OmiseTokenRequest, didFailWithError error: Error) {
        defer { expectation.fulfill() }
        self.request = request
        self.error = error
    }
}
