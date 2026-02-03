import XCTest
import UIKit
@testable import OmiseSDK

final class ThreeDSFlowControllerTests: XCTestCase {
    private var repository: MockThreeDSRepository!
    private var sdkService: MockThreeDSSDKService!
    private var controller: ThreeDSFlowController!
    private let authURL = URL(string: "https://example.com/auth") ?? URL(fileURLWithPath: "/")
    private let viewController = UIViewController()

    override func setUp() {
        super.setUp()
        repository = MockThreeDSRepository()
        sdkService = MockThreeDSSDKService()
        controller = ThreeDSFlowController(repository: repository, sdkService: sdkService)
        sdkService.session = ThreeDSSDKSession(
            bridgeSession: "mock",
            sdkTransactionId: "trans",
            sdkAppId: "app",
            sdkEphemeralPublicKey: "{}",
            deviceInfo: "info"
        )
    }

    override func tearDown() {
        repository = nil
        sdkService = nil
        controller = nil
        super.tearDown()
    }

    func test_startSuccessReturnsSuccess() {
        repository.configResult = .success(makeConfig())
        repository.authResult = .success(.init(status: .success))

        let expectation = expectation(description: "completion")
        controller.start(
            authorizeURL: authURL,
            threeDSRequestorAppURLString: nil,
            uiCustomization: nil,
            from: viewController
        ) { result in
            if case .success = result { expectation.fulfill() }
        }
        waitForExpectations(timeout: 1)
    }

    func test_startCancelledMapsToCancelledError() {
        repository.configResult = .success(makeConfig())
        let challenge = ThreeDSChallengeData(
            threeDSServerTransactionID: "server",
            acsTransactionID: "acs",
            acsSignedContent: nil,
            acsReferenceNumber: nil,
            sdkTransactionID: "sdk"
        )
        repository.authResult = .success(.init(status: .challenge(challenge)))
        sdkService.challengeResult = .cancelled

        let expectation = expectation(description: "completion")
        controller.start(
            authorizeURL: authURL,
            threeDSRequestorAppURLString: nil,
            uiCustomization: nil,
            from: viewController
        ) { result in
            if case .failure(let error as ThreeDSFlowControllerError) = result,
               case .cancelled = error {
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }

    func test_startFailureMapsToFailedError() {
        repository.configResult = .success(makeConfig())
        repository.authResult = .success(.init(status: .failed))

        let expectation = expectation(description: "completion")
        controller.start(
            authorizeURL: authURL,
            threeDSRequestorAppURLString: nil,
            uiCustomization: nil,
            from: viewController
        ) { result in
            if case .failure(let error as ThreeDSFlowControllerError) = result,
               case .failed = error {
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
}

private func makeConfig() -> NetceteraSDKConfig {
    NetceteraSDKConfig(
        id: "config",
        deviceInfoEncryptionAlg: "alg",
        deviceInfoEncryptionEnc: "enc",
        deviceInfoEncryptionCertPem: "-----BEGIN CERTIFICATE-----\nMIIB\n-----END CERTIFICATE-----",
        directoryServerId: "001",
        key: "mock-key",
        messageVersion: "2.1.0"
    )
}

private final class MockThreeDSRepository: ThreeDSRepositoryProtocol {
    var configResult: Result<NetceteraSDKConfig, Error> = .failure(DummyError.defaultError)
    var authResult: Result<ThreeDSAuthenticationResponse, Error> = .failure(DummyError.defaultError)

    func fetchConfig(authURL: URL, completion: @escaping (Result<NetceteraSDKConfig, Error>) -> Void) {
        completion(configResult)
    }

    func performAuthentication(
        authURL: URL,
        request: ThreeDSAuthenticationRequest,
        completion: @escaping (Result<ThreeDSAuthenticationResponse, Error>) -> Void
    ) {
        completion(authResult)
    }
}

private final class MockThreeDSSDKService: ThreeDSSDKServiceProtocol {
    var session: ThreeDSSDKSession!
    var challengeResult: ThreeDSFlowResult = .completed
    func beginSession(
        config: NetceteraSDKConfig,
        uiCustomization: ThreeDSUICustomization?
    ) throws -> ThreeDSSDKSession {
        session
    }

    func performChallenge(
        session: ThreeDSSDKSession,
        challenge: ThreeDSChallengeData,
        returnURL: String?,
        from viewController: UIViewController,
        completion: @escaping (ThreeDSFlowResult) -> Void
    ) {
        completion(challengeResult)
    }

    func openDeepLink(_ url: URL) -> Bool { true }
}

private enum DummyError: Error {
    case defaultError
}
