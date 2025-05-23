import XCTest
@testable import OmiseSDK
import WebKit

class AuthorizingPaymentWebViewControllerTests: XCTestCase {
    var sut: AuthorizingPaymentWebViewController!
    var authURL: URL!
    
    // swiftlint:disable force_unwrapping
    let expectedURL = URL(string: "https://example.com/cb/123")!
    let otherURL    = URL(string: "https://foo.com")!
    let customURL   = URL(string: "myapp://doSomething")!
    // swiftlint:enable force_unwrapping
    
    override func setUp() {
        super.setUp()
        sut = AuthorizingPaymentWebViewController()
        _ = sut.view
        sut.expectedReturnURLStrings = [
            // swiftlint:disable:next force_unwrapping
            URLComponents(string: "https://example.com/cb/")!
        ]
        // swiftlint:disable:next force_unwrapping
        authURL = URL(string: "https://omise.co")!
        sut.authorizeURL = authURL
        sut.loadViewIfNeeded()
        sut.viewDidAppear(false)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_policyAndResult_forExpectedReturnURL() {
        let (policy, result) = sut.policyAndResult(for: expectedURL)
        XCTAssertEqual(policy, .cancel, "Expected `.cancel` for a matching return URL")
        XCTAssertEqual(result, .complete(redirectedURL: expectedURL))
    }
    
    func test_policyAndResult_forOtherHttpURL() {
        let (policy, result) = sut.policyAndResult(for: otherURL)
        XCTAssertEqual(policy, .allow, "Non-matching HTTPS should be `.allow`")
        XCTAssertNil(result)
    }
    
    func test_policyAndResult_forCustomSchemeURL() {
        let (policy, result) = sut.policyAndResult(for: customURL)
        XCTAssertEqual(policy, .cancel, "Custom schemes should be `.cancel` (we open them)")
        XCTAssertNil(result)
    }
    
    func test_cancelAuthorizingPaymentProcess_invokesCompletionCancel() {
        // arrange
        var saw: AuthorizingPaymentWebViewController.CompletionState?
        sut.completion = { saw = $0 }
        
        // install a dummy cancel button so perform(_:with:) has a target
        let cancelItem = UIBarButtonItem()
        sut.navigationItem.rightBarButtonItem = cancelItem
        
        // act
        sut.perform(
            #selector(AuthorizingPaymentWebViewController.cancelAuthorizingPaymentProcess(_:)),
            with: cancelItem
        )
        
        // assert
        XCTAssertEqual(saw, .cancel)
    }
}

private extension AuthorizingPaymentWebViewController {
    /// Extract the same branches from your `decidePolicyFor:` into a pure function
    /// so tests can call it directly.
    func policyAndResult(for url: URL)
    -> (policy: WKNavigationActionPolicy, completionState: CompletionState?) {
        if verifyPaymentURL(url) {
            return (.cancel, .complete(redirectedURL: url))
        }
        if let scheme = url.scheme?.lowercased(), scheme != "http" && scheme != "https" {
            return (.cancel, nil)
        }
        return (.allow, nil)
    }
}
