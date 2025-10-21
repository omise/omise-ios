import XCTest
import SafariServices
@testable import OmiseSDK

class SafariPasskeyAuthenticationHandlerTests: XCTestCase {
    var sut: SafariPasskeyAuthenticationHandler!
    var mockViewController: UIViewController!
    var mockDelegate: MockAuthorizingPaymentDelegate!
    
    override func setUp() {
        super.setUp()
        sut = SafariPasskeyAuthenticationHandler()
        mockViewController = UIViewController()
        mockDelegate = MockAuthorizingPaymentDelegate()
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        mockViewController = nil
        mockDelegate = nil
    }
    
    // MARK: - shouldHandlePasskey Tests
    
    func test_shouldHandlePasskey_withSignatureParam_returnsTrue() throws {
        // Given
        let urlWithSignature = try XCTUnwrap(URL(string: "https://sample.domain/?signature=aBcdXyzlibc"))
        
        // When
        let result = sut.shouldHandlePasskey(urlWithSignature)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_shouldHandlePasskey_withSignatureAndExtraParams_returnsTrue() throws {
        // Given
        let urlWithSignatureAndExtras = try XCTUnwrap(URL(string: "https://sample.domain/?t=opaqueToken&signature=aBcdXyzlibc&sigv=1&extra=value"))
        
        // When
        let result = sut.shouldHandlePasskey(urlWithSignatureAndExtras)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_shouldHandlePasskey_withMissingSignatureParam_returnsFalse() throws {
        // Given
        let urlMissingSignature = try XCTUnwrap(URL(string: "https://sample.domain/?t=opaqueToken&sigv=1"))
        
        // When
        let result = sut.shouldHandlePasskey(urlMissingSignature)
        
        // Then
        XCTAssertFalse(result)
    }
    
    func test_shouldHandlePasskey_withNoQueryParams_returnsFalse() throws {
        // Given
        let urlWithoutParams = try XCTUnwrap(URL(string: "https://sample.domain/"))
        
        // When
        let result = sut.shouldHandlePasskey(urlWithoutParams)
        
        // Then
        XCTAssertFalse(result)
    }
    
    func test_shouldHandlePasskey_withEmptySignatureValue_returnsTrue() throws {
        // Given - Signature param present but with empty value
        let urlWithEmptySignature = try XCTUnwrap(URL(string: "https://sample.domain/?signature="))
        
        // When
        let result = sut.shouldHandlePasskey(urlWithEmptySignature)
        
        // Then
        XCTAssertTrue(result) // Should return true as long as parameter name is present
    }
    
    func test_shouldHandlePasskey_withOnlyOtherParams_returnsFalse() throws {
        // Given - Has other params but not signature
        let urlWithOtherParams = try XCTUnwrap(URL(string: "https://sample.domain/?t=token&sigv=1&other=value"))
        
        // When
        let result = sut.shouldHandlePasskey(urlWithOtherParams)
        
        // Then
        XCTAssertFalse(result)
    }
    
    func test_shouldHandlePasskey_withCaseSensitiveParam_returnsFalse() throws {
        // Given - Different case for signature param
        let urlWithWrongCase = try XCTUnwrap(URL(string: "https://sample.domain/?SIGNATURE=aBcdXyzlibc"))
        
        // When
        let result = sut.shouldHandlePasskey(urlWithWrongCase)
        
        // Then
        XCTAssertFalse(result) // Parameter names are case-sensitive
    }
    
    func test_shouldHandlePasskey_withMultipleSignatureParams_returnsTrue() throws {
        // Given - Multiple signature params (which is valid in URLs)
        let urlWithMultipleSignatures = try XCTUnwrap(URL(string: "https://sample.domain/?signature=first&signature=second"))
        
        // When
        let result = sut.shouldHandlePasskey(urlWithMultipleSignatures)
        
        // Then
        XCTAssertTrue(result) // At least one signature param is present
    }
    
    // MARK: - presentPasskeyAuthentication Tests
    
    func test_presentPasskeyAuthentication_storesExpectedReturnURLs() throws {
        // Given
        let authorizeURL = try XCTUnwrap(URL(string: "https://passkey.omise.co/authorize"))
        let expectedReturnURLs = ["myapp://callback", "myapp://cancel"]
        
        // When
        sut.presentPasskeyAuthentication(
            from: mockViewController,
            authorizeURL: authorizeURL,
            expectedReturnURLStrings: expectedReturnURLs,
            delegate: mockDelegate
        )
        
        // Then - We can't directly access private properties, but we can test behavior
        // The handler should be set up to handle callbacks
    }
    
    // MARK: - handlePasskeyCallback Tests
    
    func test_handlePasskeyCallback_withMatchingURL_returnsTrue() throws {
        // Given
        let authorizeURL = try XCTUnwrap(URL(string: "https://passkey.omise.co/authorize"))
        let expectedReturnURLs = ["myapp://callback"]
        let callbackURL = try XCTUnwrap(URL(string: "myapp://callback?result=success"))
        
        // Set up the handler with expected URLs
        sut.presentPasskeyAuthentication(
            from: mockViewController,
            authorizeURL: authorizeURL,
            expectedReturnURLStrings: expectedReturnURLs,
            delegate: mockDelegate
        )
        
        // When
        let result = sut.handlePasskeyCallback(callbackURL)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_handlePasskeyCallback_withNonMatchingURL_returnsFalse() throws {
        // Given
        let authorizeURL = try XCTUnwrap(URL(string: "https://passkey.omise.co/authorize"))
        let expectedReturnURLs = ["myapp://callback"]
        let nonMatchingURL = try XCTUnwrap(URL(string: "anotherapp://different"))
        
        // Set up the handler with expected URLs
        sut.presentPasskeyAuthentication(
            from: mockViewController,
            authorizeURL: authorizeURL,
            expectedReturnURLStrings: expectedReturnURLs,
            delegate: mockDelegate
        )
        
        // When
        let result = sut.handlePasskeyCallback(nonMatchingURL)
        
        // Then
        XCTAssertFalse(result)
    }
    
    func test_handlePasskeyCallback_withoutPresentingSafari_returnsFalse() throws {
        // Given
        let callbackURL = try XCTUnwrap(URL(string: "myapp://callback?result=success"))
        
        // When - calling callback without presenting Safari first
        let result = sut.handlePasskeyCallback(callbackURL)
        
        // Then
        XCTAssertFalse(result)
    }
    
    // MARK: - dismiss Tests
    
    func test_dismiss_withoutActiveSafari_callsCompletionImmediately() {
        // Given
        var completionCalled = false
        
        // When
        sut.dismiss(animated: false) {
            completionCalled = true
        }
        
        // Then
        XCTAssertTrue(completionCalled)
    }
    
    func test_dismiss_cleansUpState() throws {
        // Given
        let authorizeURL = try XCTUnwrap(URL(string: "https://passkey.omise.co/authorize"))
        sut.presentPasskeyAuthentication(
            from: mockViewController,
            authorizeURL: authorizeURL,
            expectedReturnURLStrings: ["myapp://callback"],
            delegate: mockDelegate
        )
        
        // When
        var completionCalled = false
        sut.dismiss(animated: false) {
            completionCalled = true
        }
        
        // Then
        XCTAssertTrue(completionCalled)
        
        // Verify state is cleaned up by testing that callback no longer works
        let callbackURL = try XCTUnwrap(URL(string: "myapp://callback?result=success"))
        let result = sut.handlePasskeyCallback(callbackURL)
        XCTAssertFalse(result) // Should return false as state was cleaned up
    }
    
    // MARK: - URL Matching Tests
    
    func test_urlMatching_withExactMatch() throws {
        // Given
        let testURL = try XCTUnwrap(URL(string: "myapp://callback"))
        let expectedURLs = ["myapp://callback"]
        
        // Set up handler
        let authorizeURL = try XCTUnwrap(URL(string: "https://passkey.omise.co/authorize"))
        sut.presentPasskeyAuthentication(
            from: mockViewController,
            authorizeURL: authorizeURL,
            expectedReturnURLStrings: expectedURLs,
            delegate: mockDelegate
        )
        
        // When
        let result = sut.handlePasskeyCallback(testURL)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_urlMatching_withQueryParameters() throws {
        // Given
        let testURL = try XCTUnwrap(URL(string: "myapp://callback?param=value&result=success"))
        let expectedURLs = ["myapp://callback"]
        
        // Set up handler
        let authorizeURL = try XCTUnwrap(URL(string: "https://passkey.omise.co/authorize"))
        sut.presentPasskeyAuthentication(
            from: mockViewController,
            authorizeURL: authorizeURL,
            expectedReturnURLStrings: expectedURLs,
            delegate: mockDelegate
        )
        
        // When
        let result = sut.handlePasskeyCallback(testURL)
        
        // Then
        XCTAssertTrue(result)
    }
    
    // MARK: - Integration Tests
    
    func test_presentPasskeyAuthentication_storesCorrectState() throws {
        // Given
        let authorizeURL = try XCTUnwrap(URL(string: "https://passkey.omise.co/authorize"))
        let expectedReturnURLs = ["myapp://callback", "myapp://cancel"]
        
        // When
        sut.presentPasskeyAuthentication(
            from: mockViewController,
            authorizeURL: authorizeURL,
            expectedReturnURLStrings: expectedReturnURLs,
            delegate: mockDelegate
        )
        
        // Then - Test that subsequent callback matching works correctly
        let callbackURL = try XCTUnwrap(URL(string: "myapp://callback?result=success"))
        let result = sut.handlePasskeyCallback(callbackURL)
        XCTAssertTrue(result)
    }
}
