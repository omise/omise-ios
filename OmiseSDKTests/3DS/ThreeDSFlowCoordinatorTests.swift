// swiftlint:disable file_length
import XCTest
import UIKit
import ThreeDS_SDK
@testable import OmiseSDK

final class ThreeDSFlowCoordinatorTests: XCTestCase {
    private var repository: MockThreeDSRepository!
    private var sdkService: MockThreeDSSDKService!
    private var coordinator: ThreeDSFlowCoordinator!
    private let authURL = URL(string: "https://example.com/auth") ?? URL(fileURLWithPath: "/")
    private let viewController = UIViewController()
    private let sampleConfig = NetceteraSDKConfig(
        id: "config",
        deviceInfoEncryptionAlg: "alg",
        deviceInfoEncryptionEnc: "enc",
        deviceInfoEncryptionCertPem: "-----BEGIN CERTIFICATE-----\nMIIB\n-----END CERTIFICATE-----",
        directoryServerId: "001",
        key: "mock-key",
        messageVersion: "2.1.0"
    )

    override func setUp() {
        super.setUp()
        repository = MockThreeDSRepository()
        sdkService = MockThreeDSSDKService()
        coordinator = ThreeDSFlowCoordinator(repository: repository, sdkService: sdkService, callbackQueue: .main)
        sdkService.session = ThreeDSSDKSession(
            bridgeSession: "mock",
            sdkTransactionId: "trans-id",
            sdkAppId: "app-id",
            sdkEphemeralPublicKey: "{}",
            deviceInfo: "device-info"
        )
    }

    override func tearDown() {
        repository = nil
        sdkService = nil
        coordinator = nil
        super.tearDown()
    }

    func test_successFlowCompletes() {
        repository.configResult = .success(sampleConfig)
        repository.authResult = .success(ThreeDSAuthenticationResponse(status: .success))

        let expectation = expectation(description: "completion")
        coordinator.start(
            authURL: authURL,
            returnURL: nil,
            uiCustomization: nil,
            from: viewController
        ) { result in
            if case .completed = result {
                expectation.fulfill()
            } else {
                XCTFail("Expected success, got \(result)")
            }
        }

        waitForExpectations(timeout: 1)
    }

    func test_challengeFlowCancels() {
        repository.configResult = .success(sampleConfig)
        let challenge = ThreeDSChallengeData(
            threeDSServerTransactionID: "server",
            acsTransactionID: "acs",
            acsSignedContent: nil,
            acsReferenceNumber: nil,
            sdkTransactionID: "sdk"
        )
        repository.authResult = .success(ThreeDSAuthenticationResponse(status: .challenge(challenge)))
        sdkService.challengeResult = .cancelled

        let expectation = expectation(description: "completion")
        coordinator.start(
            authURL: authURL,
            returnURL: nil,
            uiCustomization: nil,
            from: viewController
        ) { result in
            if case .cancelled = result {
                expectation.fulfill()
            } else {
                XCTFail("Expected cancellation, got \(result)")
            }
        }

        waitForExpectations(timeout: 1)
        XCTAssertTrue(sdkService.didPerformChallenge)
    }

    func test_authFailureProducesError() {
        repository.configResult = .success(sampleConfig)
        repository.authResult = .success(ThreeDSAuthenticationResponse(status: .failed))

        let expectation = expectation(description: "completion")
        coordinator.start(
            authURL: authURL,
            returnURL: nil,
            uiCustomization: nil,
            from: viewController
        ) { result in
            if case .failed(let message) = result {
                XCTAssertTrue(message.contains("Authentication failed"))
                expectation.fulfill()
            } else {
                XCTFail("Expected failure, got \(result)")
            }
        }

        waitForExpectations(timeout: 1)
    }

    func test_repositoryMapsChallengeResponse() {
        let repository = ThreeDSRepository()
        let ares = AuthResponse.ARes(
            threeDSServerTransID: "server",
            acsTransID: "acs",
            acsSignedContent: "signed",
            acsUIType: nil,
            acsReferenceNumber: nil,
            sdkTransID: "sdk"
        )
        let authResponse = AuthResponse(serverStatus: "challenge", ares: ares)
        let mapped = repository.map(authResponse)

        switch mapped.status {
        case .challenge(let challengeData):
            XCTAssertEqual(challengeData.sdkTransactionID, "sdk")
            XCTAssertEqual(challengeData.acsTransactionID, "acs")
            XCTAssertEqual(challengeData.acsSignedContent, "signed")
        default:
            XCTFail("Expected challenge mapping")
        }
    }
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
    private(set) var didPerformChallenge = false

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
        didPerformChallenge = true
        completion(challengeResult)
    }

    func openDeepLink(_ url: URL) -> Bool {
        true
    }
}

private enum DummyError: Error {
    case defaultError
}

// MARK: - ViewModel tests

final class ThreeDSFlowViewModelTests: XCTestCase {
    func test_viewModelPublishesCompletedState() {
        let coordinator = MockCoordinator()
        let viewModel = ThreeDSFlowViewModel(coordinator: coordinator)
        let expectation = expectation(description: "state")

        viewModel.onStateChange = { state in
            if case .completed(let result) = state {
                if case .completed = result {
                    expectation.fulfill()
                }
            }
        }

        guard let authURL = URL(string: "https://example.com/auth") else {
            XCTFail("Invalid URL")
            return
        }

        viewModel.start(
            authURL: authURL,
            returnURL: nil,
            uiCustomization: nil,
            from: UIViewController()
        )

        waitForExpectations(timeout: 1)
        XCTAssertTrue(coordinator.startCalled)
    }

    func test_viewModelForwardsDeepLink() {
        let coordinator = MockCoordinator()
        let viewModel = ThreeDSFlowViewModel(coordinator: coordinator)
        guard let deeplink = URL(string: "omise://3ds") else {
            XCTFail("Invalid URL")
            return
        }
        XCTAssertTrue(viewModel.handleDeepLink(deeplink))
        XCTAssertTrue(coordinator.handleDeepLinkCalled)
    }
}

private final class MockCoordinator: ThreeDSFlowCoordinatorProtocol {
    var startCalled = false
    var handleDeepLinkCalled = false
    var nextResult: ThreeDSFlowResult = .completed

    func start(authURL: URL, returnURL: String?, uiCustomization: ThreeDSUICustomization?, from viewController: UIViewController, completion: @escaping (ThreeDSFlowResult) -> Void) {
        startCalled = true
        completion(nextResult)
    }

    func handleDeepLink(_ url: URL) -> Bool {
        handleDeepLinkCalled = true
        return true
    }
}

// MARK: - Repository mapping tests

final class ThreeDSRepositoryMappingTests: XCTestCase {
    func test_unknownStatusWithoutAres() {
        let repository = ThreeDSRepository()
        let authResponse = AuthResponse(serverStatus: "unknown", ares: nil)
        let mapped = repository.map(authResponse)

        if case .unknown = mapped.status {
            // pass
        } else {
            XCTFail("Expected unknown mapping")
        }
    }
}

// MARK: - NetceteraThreeDSSDKService tests

final class NetceteraThreeDSSDKServiceTests: XCTestCase {
    func test_handleDeepLinkDelegatesToController() {
        let bridge = MockBridge()
        bridge.deepLinkResult = true
        let service = NetceteraThreeDSSDKService(bridge: bridge)
        guard let deeplink = URL(string: "omise://3ds") else {
            XCTFail("Invalid URL")
            return
        }
        _ = service.openDeepLink(deeplink)
        XCTAssertTrue(bridge.handleDeepLinkCalled)
    }

    func test_performChallengeFailsWithoutTransaction() {
        let service = NetceteraThreeDSSDKService(bridge: MockBridge())
        let session = ThreeDSSDKSession(
            bridgeSession: "invalid",
            sdkTransactionId: "trans-id",
            sdkAppId: "app-id",
            sdkEphemeralPublicKey: "{}",
            deviceInfo: "device-info"
        )

        let challenge = ThreeDSChallengeData(
            threeDSServerTransactionID: "server",
            acsTransactionID: "acs",
            acsSignedContent: nil,
            acsReferenceNumber: nil,
            sdkTransactionID: "sdk"
        )

        let expectation = expectation(description: "completion")
        let returnURL: String? = nil
        service.performChallenge(session: session,
                                 challenge: challenge,
                                 returnURL: returnURL,
                                 from: UIViewController()) { result in
            if case .failed = result {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }

    func test_performChallengeSuccess() {
        let bridge = MockBridge()
        bridge.performResult = .completed
        let context = makeContext()
        bridge.createSessionResult = .success(context)
        let service = NetceteraThreeDSSDKService(bridge: bridge)
        guard let session = try? service.beginSession(config: sampleConfig(), uiCustomization: nil) else {
            XCTFail("Expected session")
            return
        }

        let challenge = ThreeDSChallengeData(
            threeDSServerTransactionID: "server",
            acsTransactionID: "acs",
            acsSignedContent: nil,
            acsReferenceNumber: nil,
            sdkTransactionID: "sdk"
        )

        let expectation = expectation(description: "completion")
        let returnURL: String? = nil
        service.performChallenge(session: session,
                                 challenge: challenge,
                                 returnURL: returnURL,
                                 from: UIViewController()) { result in
            if case .completed = result {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }

    func test_performChallengeRunnerThrows() {
        let bridge = MockBridge()
        bridge.performResult = .failed("boom")
        bridge.createSessionResult = .success(makeContext())
        let service = NetceteraThreeDSSDKService(bridge: bridge)
        guard let session = try? service.beginSession(config: sampleConfig(), uiCustomization: nil) else {
            XCTFail("Expected session")
            return
        }

        let challenge = ThreeDSChallengeData(
            threeDSServerTransactionID: "server",
            acsTransactionID: "acs",
            acsSignedContent: nil,
            acsReferenceNumber: nil,
            sdkTransactionID: "sdk"
        )

        let expectation = expectation(description: "completion")
        let returnURL: String? = nil
        service.performChallenge(session: session,
                                 challenge: challenge,
                                 returnURL: returnURL,
                                 from: UIViewController()) { result in
            if case .failed = result {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }

    func test_newSchemeBuildsScheme() throws {
        _ = NetceteraSDKBridge(configProvider: StubNetceteraConfigProvider())
        let config = sampleConfig()
        let scheme = NetceteraSDKBridge.newScheme(config: config)

        // XCTAssertEqual(scheme?.ids, config.id)
        XCTAssertEqual(scheme?.ids, [config.directoryServerId])
        XCTAssertEqual(scheme?.encryptionKeyValue, config.deviceInfoEncryptionCertPem.pemCertificate)
    }

    func test_beginSessionUsesBridge() throws {
        let bridge = MockBridge()
        bridge.createSessionResult = .success(makeContext())
        let service = NetceteraThreeDSSDKService(bridge: bridge)
        _ = try service.beginSession(config: sampleConfig(), uiCustomization: nil)
        XCTAssertTrue(bridge.createSessionCalled)
    }
    
    func test_bridgeCreateSessionThrowsWithInvalidConfig() {
        let bridge = NetceteraSDKBridge(
            configProvider: StubNetceteraConfigProvider(),
            sessionCreator: { _, _ in throw DummyError.defaultError } // swiftlint:disable:this trailing_closure
        )
        XCTAssertThrowsError(try bridge.createSession(config: sampleConfig(), uiCustomization: nil)) { _ in }
    }
}

private func makeContext() -> NetceteraSDKSessionContext {
    NetceteraSDKSessionContext(
        transaction: MinimalTransaction(),
        sdkTransactionId: "trans-id",
        sdkAppId: "app-id",
        sdkEphemeralPublicKey: "{}",
        deviceInfo: "device-info"
    )
}

private func sampleConfig() -> NetceteraSDKConfig {
    NetceteraSDKConfig(
        id: "ABC",
        deviceInfoEncryptionAlg: "ABC-DEFC-000",
        deviceInfoEncryptionEnc: "ABCDEFG-HIJKL",
        deviceInfoEncryptionCertPem: """
        -----BEGIN CERTIFICATE-----
        BEVQQKDAVPbWlzZTEQMA4GA1UEBw
        mYbxjtVrTeMb1r2/J3jdXGg6LsNE0ouOU/XbEEA+Xpyrs
        2Xkh78gzaRiKCXfJYplDm/mBB==
        -----END CERTIFICATE-----
        """,
        directoryServerId: "001",
        key: "qmF3DYxVQAXjH0000MOCK0KEY000cXQ1uRSWT4Yrmjcd2mJkTGQ==",
        messageVersion: "2.1.0"
    )
}

private final class MockBridge: NetceteraSDKBridgeProtocol {
    var createSessionResult: Result<NetceteraSDKSessionContext, Error> = .failure(DummyError.defaultError)
    var performResult: ThreeDSFlowResult = .completed
    var deepLinkResult = false

    private(set) var createSessionCalled = false
    private(set) var handleDeepLinkCalled = false
    private(set) var performChallengeCalled = false

    func createSession(config: NetceteraSDKConfig, uiCustomization: ThreeDSUICustomization?) throws -> NetceteraSDKSessionContext {
        createSessionCalled = true
        return try createSessionResult.get()
    }

    func performChallenge(context: NetceteraSDKSessionContext, challenge: ThreeDSChallengeData, returnURL: String?, from viewController: UIViewController, completion: @escaping (ThreeDSFlowResult) -> Void) {
        performChallengeCalled = true
        completion(performResult)
    }

    func handleDeepLink(_ url: URL) -> Bool {
        handleDeepLinkCalled = true
        return deepLinkResult
    }
}

private final class StubNetceteraConfigProvider: NetceteraSDKConfigProviding {
    let logLevel: LogLevel = .info
    let locale: Locale? = nil

    func apiKey(for config: NetceteraSDKConfig) throws -> String {
        "stub-api-key"
    }

    func makeScheme(for config: NetceteraSDKConfig) -> Scheme? {
        NetceteraSDKBridge.newScheme(config: config)
    }
}

private final class MinimalTransaction: TransactionPerforming {
    func doChallenge(challengeParameters: ChallengeParameters, challengeStatusReceiver: ChallengeStatusReceiver, timeOut: Int, inViewController: UIViewController) throws {}

    func getAuthenticationRequestParameters() throws -> AuthParametersProviding {
        MinimalAuthParameters()
    }
}

private struct MinimalAuthParameters: AuthParametersProviding {
    func getDeviceData() -> String { "device" }
    func getSDKTransactionId() -> String { "trans" }
    func getSDKAppID() -> String { "app" }
    func getSDKEphemeralPublicKey() -> String { "{}" }
}
