import XCTest
@testable import OmiseSDK

class MockPasskeyAuthenticationHandler: PasskeyAuthenticationProtocol {
    var shouldHanlePasskeyCallCount = 0
    var presentPasskeyAuthenticationCallCount = 0
    var handlePasskeyCallbackCallCount = 0
    var lastPresentedURL: URL?
    var lastExpectedReturnURLStrings: [String]?
    var lastDelegate: AuthorizingPaymentDelegate?
    var shouldReturnTrueForCallback = false
    var shouldReturnTrueForShouldHandle = false
    
    func shouldHandlePasskey(_ url: URL) -> Bool {
        shouldHanlePasskeyCallCount += 1
        return shouldReturnTrueForShouldHandle
    }
    
    func presentPasskeyAuthentication(
        from viewController: UIViewController,
        authorizeURL: URL,
        expectedReturnURLStrings: [String],
        delegate: AuthorizingPaymentDelegate
    ) {
        presentPasskeyAuthenticationCallCount += 1
        lastPresentedURL = authorizeURL
        lastExpectedReturnURLStrings = expectedReturnURLStrings
        lastDelegate = delegate
    }
    
    func handlePasskeyCallback(_ url: URL) -> Bool {
        handlePasskeyCallbackCallCount += 1
        return shouldReturnTrueForCallback
    }
}

class MockAuthorizingPaymentDelegate: AuthorizingPaymentDelegate {
    var authorizingPaymentDidCompleteCallCount = 0
    var authorizingPaymentDidCancelCallCount = 0
    var lastCompletedURL: URL?
    
    func authorizingPaymentDidComplete(with redirectedURL: URL?) {
        authorizingPaymentDidCompleteCallCount += 1
        lastCompletedURL = redirectedURL
    }
    
    func authorizingPaymentDidCancel() {
        authorizingPaymentDidCancelCallCount += 1
    }
}
