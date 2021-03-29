import XCTest
import OmiseSDK


@available(*, deprecated)
class TokenRequestDelegateDummy: OmiseTokenRequestDelegate {
    var request: OmiseTokenRequest?
    var token: __OmiseToken?
    var error: Error?
    
    let expectation: XCTestExpectation
    
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }
    
    func tokenRequest(_ request: OmiseTokenRequest, didSucceedWithToken token: __OmiseToken) {
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
