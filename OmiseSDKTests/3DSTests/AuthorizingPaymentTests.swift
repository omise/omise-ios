import XCTest
@testable import OmiseSDK
import ThreeDS_SDK

class NetceteraThreeDSControllerMock: NetceteraThreeDSControllerProtocol {

    func appOpen3DSDeeplinkURL(_ url: URL) -> Bool {
        return true
    }
    
    var processAuthorizedURLResult = NetceteraThreeDSControllerResult.success(())
    func processAuthorizedURL(
        _ authorizeUrl: URL,
        threeDSRequestorAppURL: String?,
        uiCustomization: ThreeDSUICustomization?,
        in viewController: UIViewController,
        onComplete: @escaping (NetceteraThreeDSControllerResult) -> Void
    ) {
        onComplete(processAuthorizedURLResult)
    }
}

class TopViewControllerMock: UIViewController {
    var onPresentViewController: ((UIViewController) -> Void)?
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        onPresentViewController?(viewControllerToPresent)
    }
}

class AuthorizingPaymentTests: XCTestCase {

    struct AnyError: Error {
        let message: String
        init(_ message: String? = nil) {
            self.message = message ?? ""
        }
    }

    // swiftlint:disable force_unwrapping
    let authorizeURL = URL(string: "https://co.omise.com/authorize")!
    let expectedWebReturnURL = URL(string: "https://co.omise.com/callback")!
    let deeplinkURL = URL(string: "omiseExampleApp://authorizePayment")!
    // swiftlint:enable force_unwrapping

    typealias NetceteraError = NetceteraThreeDSController.Errors
    let netceteraMockController = NetceteraThreeDSControllerMock()
    let authorizingPayment = AuthorizingPayment()
    let topViewController = TopViewControllerMock()
    let timeout: TimeInterval = 15.0

    override func setUp() {
        super.setUp()
        NetceteraThreeDSController.sharedController = netceteraMockController
    }

    func test3DSUserFailedChallenge() {
        let expectation = self.expectation(description: "callback")

        netceteraMockController.processAuthorizedURLResult = .failure(NetceteraError.incomplete(event: nil))
        authorizingPayment.presentAuthPaymentController(
            from: topViewController,
            url: authorizeURL,
            expectedWebViewReturnURL: expectedWebReturnURL,
            deeplinkURL: deeplinkURL) { result in
                defer { expectation.fulfill() }
                XCTAssertEqual(result, AuthorizingPayment.Status.cancel)
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func test3DSUserCancelledChallenge() {
        let expectation = self.expectation(description: "callback")

        netceteraMockController.processAuthorizedURLResult = .failure(NetceteraError.cancelled)
        authorizingPayment.presentAuthPaymentController(
            from: topViewController,
            url: authorizeURL,
            expectedWebViewReturnURL: expectedWebReturnURL,
            deeplinkURL: deeplinkURL) { result in
                defer { expectation.fulfill() }
                XCTAssertEqual(result, AuthorizingPayment.Status.cancel)
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func test3DSUserTimedOutChallenge() {
        let expectation = self.expectation(description: "callback")
        
        netceteraMockController.processAuthorizedURLResult = .failure(NetceteraError.timedout)
        authorizingPayment.presentAuthPaymentController(
            from: topViewController,
            url: authorizeURL,
            expectedWebViewReturnURL: expectedWebReturnURL,
            deeplinkURL: deeplinkURL) { result in
                defer { expectation.fulfill() }
                XCTAssertEqual(result, AuthorizingPayment.Status.cancel)
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func test3DSAuthResponseStatusFailed() {
        let expectation = self.expectation(description: "callback")

        netceteraMockController.processAuthorizedURLResult = .failure(NetceteraError.authResStatusFailed)
        authorizingPayment.presentAuthPaymentController(
            from: topViewController,
            url: authorizeURL,
            expectedWebViewReturnURL: expectedWebReturnURL,
            deeplinkURL: deeplinkURL) { result in
                defer { expectation.fulfill() }
                XCTAssertEqual(result, AuthorizingPayment.Status.cancel)
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func test3DSAuthResponseStatusUnknown() {
        let expectation = self.expectation(description: "callback")

        netceteraMockController.processAuthorizedURLResult = .failure(NetceteraError.authResStatusUnknown("Some Unknown Status"))
        authorizingPayment.presentAuthPaymentController(
            from: topViewController,
            url: authorizeURL,
            expectedWebViewReturnURL: expectedWebReturnURL,
            deeplinkURL: deeplinkURL) { result in
                defer { expectation.fulfill() }
                XCTAssertEqual(result, AuthorizingPayment.Status.cancel)
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func test3DSSuccess() {
        let expectation = self.expectation(description: "callback")

        netceteraMockController.processAuthorizedURLResult = .success(())
        authorizingPayment.presentAuthPaymentController(
            from: topViewController,
            url: authorizeURL,
            expectedWebViewReturnURL: expectedWebReturnURL,
            deeplinkURL: deeplinkURL) { result in
                defer { expectation.fulfill() }
                XCTAssertEqual(result, AuthorizingPayment.Status.complete(redirectURL: nil))
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testWebViewOn3DSAuthResponseInvalid() {
        let expectation = self.expectation(description: "callback")

        topViewController.onPresentViewController = { viewController in
            defer { expectation.fulfill() }
            let presentedVC = (viewController as? UINavigationController)?.topViewController
            XCTAssertTrue(presentedVC is AuthorizingPaymentWebViewController)
        }

        netceteraMockController.processAuthorizedURLResult = .failure(NetceteraError.authResInvalid)
        authorizingPayment.presentAuthPaymentController(
            from: topViewController,
            url: authorizeURL,
            expectedWebViewReturnURL: expectedWebReturnURL,
            deeplinkURL: deeplinkURL) { _ in
                XCTFail("Should open webview and don't call this callback")
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testWebViewOn3DSProtocolError() {
        let expectation = self.expectation(description: "callback")

        topViewController.onPresentViewController = { viewController in
            defer { expectation.fulfill() }
            let presentedVC = (viewController as? UINavigationController)?.topViewController
            XCTAssertTrue(presentedVC is AuthorizingPaymentWebViewController)
        }

        netceteraMockController.processAuthorizedURLResult = .failure(NetceteraError.protocolError(event: nil))
        authorizingPayment.presentAuthPaymentController(
            from: topViewController,
            url: authorizeURL,
            expectedWebViewReturnURL: expectedWebReturnURL,
            deeplinkURL: deeplinkURL) { _ in
                XCTFail("Should open webview and don't call this callback")
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testWebViewOn3DSRuntimeError() {
        let expectation = self.expectation(description: "callback")

        topViewController.onPresentViewController = { viewController in
            defer { expectation.fulfill() }
            let presentedVC = (viewController as? UINavigationController)?.topViewController
            XCTAssertTrue(presentedVC is AuthorizingPaymentWebViewController)
        }

        netceteraMockController.processAuthorizedURLResult = .failure(NetceteraError.runtimeError(event: nil))
        authorizingPayment.presentAuthPaymentController(
            from: topViewController,
            url: authorizeURL,
            expectedWebViewReturnURL: expectedWebReturnURL,
            deeplinkURL: deeplinkURL) { _ in
                XCTFail("Should open webview and don't call this callback")
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testWebViewOn3DSPresentChallengeFailed() {
        let expectation = self.expectation(description: "callback")

        topViewController.onPresentViewController = { viewController in
            defer { expectation.fulfill() }
            let presentedVC = (viewController as? UINavigationController)?.topViewController
            XCTAssertTrue(presentedVC is AuthorizingPaymentWebViewController)
        }

        let challengeError = AnyError("Any error on presenting Netcetera Challenge")
        netceteraMockController.processAuthorizedURLResult = .failure(NetceteraError.presentChallenge(error: challengeError))
        authorizingPayment.presentAuthPaymentController(
            from: topViewController,
            url: authorizeURL,
            expectedWebViewReturnURL: expectedWebReturnURL,
            deeplinkURL: deeplinkURL) { _ in
                XCTFail("Should open webview and don't call this callback")
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testWebViewOn3DSDeviceInfoInvalid() {
        let expectation = self.expectation(description: "callback")

        topViewController.onPresentViewController = { viewController in
            defer { expectation.fulfill() }
            let presentedVC = (viewController as? UINavigationController)?.topViewController
            XCTAssertTrue(presentedVC is AuthorizingPaymentWebViewController)
        }

        netceteraMockController.processAuthorizedURLResult = .failure(NetceteraError.deviceInfoInvalid)
        authorizingPayment.presentAuthPaymentController(
            from: topViewController,
            url: authorizeURL,
            expectedWebViewReturnURL: expectedWebReturnURL,
            deeplinkURL: deeplinkURL) { _ in
                XCTFail("Should open webview and don't call this callback")
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testWebViewOnInitializationFailed() {
        let expectation = self.expectation(description: "callback")

        topViewController.onPresentViewController = { viewController in
            defer { expectation.fulfill() }
            let presentedVC = (viewController as? UINavigationController)?.topViewController
            XCTAssertTrue(presentedVC is AuthorizingPaymentWebViewController)
        }

        netceteraMockController.processAuthorizedURLResult = .failure(AnyError("Any error during initialization"))
        authorizingPayment.presentAuthPaymentController(
            from: topViewController,
            url: authorizeURL,
            expectedWebViewReturnURL: expectedWebReturnURL,
            deeplinkURL: deeplinkURL) { _ in
                XCTFail("Should open webview and don't call this callback")
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }
}
