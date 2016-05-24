import XCTest
import OmiseSDK

class TokenRequestDelegateDummy: OmiseTokenRequestDelegate {
    var request: OmiseTokenRequest? = nil
    var token: OmiseToken? = nil
    var error: ErrorType? = nil
    
    let expectation: XCTestExpectation
    
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }
    
    func tokenRequest(request: OmiseTokenRequest, didSucceedWithToken token: OmiseToken) {
        defer { expectation.fulfill() }
        self.request = request
        self.token = token
    }
    
    func tokenRequest(request: OmiseTokenRequest, didFailWithError error: ErrorType) {
        defer { expectation.fulfill() }
        self.request = request
        self.error = error
    }
}