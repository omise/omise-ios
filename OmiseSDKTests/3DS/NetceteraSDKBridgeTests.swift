import XCTest
@testable import OmiseSDK
import ThreeDS_SDK

final class NetceteraSDKBridgeTests: XCTestCase {
    func test_activeChallengeStatePreventsConcurrentChallenge() {
        let state = ActiveChallengeState()
        let transaction = FakeTransaction(authParams: FakeAuthParameters())
        let firstReceiver = BridgeChallengeStatusReceiver()
        let secondReceiver = BridgeChallengeStatusReceiver()

        XCTAssertTrue(state.trySet(transaction: transaction, receiver: firstReceiver))
        XCTAssertFalse(state.trySet(transaction: transaction, receiver: secondReceiver))

        state.clear()
        XCTAssertTrue(state.trySet(transaction: transaction, receiver: secondReceiver))
    }
    
    func test_mapChallengeResultCoversBridgeErrors() {
        XCTAssertEqual(
            NetceteraSDKBridge.mapChallengeResult(Result<Void, NetceteraSDKBridgeError>.failure(.cancelled)),
            .cancelled
        )
        XCTAssertEqual(
            NetceteraSDKBridge.mapChallengeResult(Result<Void, NetceteraSDKBridgeError>.failure(.timedOut)),
            .cancelled
        )
        XCTAssertEqual(
            NetceteraSDKBridge.mapChallengeResult(Result<Void, NetceteraSDKBridgeError>.failure(.protocolError(event: nil))),
            .failed("Protocol error")
        )
        XCTAssertEqual(
            NetceteraSDKBridge.mapChallengeResult(Result<Void, NetceteraSDKBridgeError>.failure(.runtimeError(event: nil))),
            .failed("Runtime error")
        )
        XCTAssertEqual(
            NetceteraSDKBridge.mapChallengeResult(Result<Void, NetceteraSDKBridgeError>.failure(.incomplete(event: nil))),
            .failed("Challenge incomplete")
        )
        XCTAssertEqual(
            NetceteraSDKBridge.mapChallengeResult(Result<Void, DummyError>.failure(DummyError.defaultError)),
            .failed(DummyError.defaultError.localizedDescription)
        )
    }
    
    func test_handleDeepLinkUsesInjectedHandler() {
        var called = false
        guard let url = URL(string: "omise://deeplink") else {
            XCTFail("Invalid URL")
            return
        }
        let bridge = NetceteraSDKBridge(
            configProvider: NetceteraSDKConfigProvider(),
            sessionCreator: { _, _ in
                NetceteraSDKSessionContext(
                    transaction: FakeTransaction(authParams: FakeAuthParameters()),
                    sdkTransactionId: "",
                    sdkAppId: "",
                    sdkEphemeralPublicKey: "",
                    deviceInfo: ""
                )
            },
            deepLinkHandler: { incoming in
                called = incoming == url
                return true
            }
        )
        
        XCTAssertTrue(bridge.handleDeepLink(url))
        XCTAssertTrue(called)
    }
    
    func test_performChallengeUsesInjectedPerformer() {
        var called = false
        let expectedResult: ThreeDSFlowResult = .completed
        let bridge = NetceteraSDKBridge(
            configProvider: NetceteraSDKConfigProvider(),
            sessionCreator: { _, _ in
                NetceteraSDKSessionContext(
                    transaction: FakeTransaction(authParams: FakeAuthParameters()),
                    sdkTransactionId: "",
                    sdkAppId: "",
                    sdkEphemeralPublicKey: "",
                    deviceInfo: ""
                )
            },
            challengePerformer: { _, _, _, _, completion in
                called = true
                completion(expectedResult)
            }
        )
        
        let context = NetceteraSDKSessionContext(
            transaction: FakeTransaction(authParams: FakeAuthParameters()),
            sdkTransactionId: "",
            sdkAppId: "",
            sdkEphemeralPublicKey: "",
            deviceInfo: ""
        )
        let challenge = ThreeDSChallengeData(
            threeDSServerTransactionID: "server",
            acsTransactionID: "acs",
            acsSignedContent: nil,
            acsReferenceNumber: nil,
            sdkTransactionID: "sdk"
        )
        
        let expectation = expectation(description: "performer")
        bridge.performChallenge(
            context: context,
            challenge: challenge,
            returnURL: nil,
            from: UIViewController()
        ) { result in
            XCTAssertEqual(result, expectedResult)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        XCTAssertTrue(called)
    }
    
    func test_defaultSessionCreatorUsesServiceFactory() throws {
        let authParams = FakeAuthParameters()
        let transaction = FakeTransaction(authParams: authParams)
        let service = FakeService(transaction: transaction)
        let serviceFactory: NetceteraSDKBridge.ServiceFactory = { service }
        let creator = NetceteraSDKBridge.makeDefaultSessionCreator(
            configProvider: StubConfigProvider(),
            serviceFactory: serviceFactory
        )
        
        let ctx = try creator(sampleConfig(), nil)
        XCTAssertEqual(ctx.sdkTransactionId, authParams.getSDKTransactionId())
        XCTAssertTrue(service.didInitialize)
        XCTAssertTrue(service.didCreateTransaction)
    }
    
    func test_defaultChallengePerformerMapsSuccessAndErrors() {
        let performer = NetceteraSDKBridge.makeDefaultChallengePerformer(activeState: ActiveChallengeState())
        let expectation = expectation(description: "challenge")
        
        let transaction = FakeTransaction(authParams: FakeAuthParameters())
        transaction.challengeBehavior = .complete
        let context = NetceteraSDKSessionContext(
            transaction: transaction,
            sdkTransactionId: "tx",
            sdkAppId: "app",
            sdkEphemeralPublicKey: "{}",
            deviceInfo: "device"
        )
        let challenge = ThreeDSChallengeData(
            threeDSServerTransactionID: "server",
            acsTransactionID: "acs",
            acsSignedContent: nil,
            acsReferenceNumber: nil,
            sdkTransactionID: "sdk"
        )
        
        let returnURL: String? = nil
        performer(context, challenge, returnURL, UIViewController()) { result in
            XCTAssertEqual(result, .completed)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func test_defaultChallengePerformerMapsCancellation() {
        let performer = NetceteraSDKBridge.makeDefaultChallengePerformer(activeState: ActiveChallengeState())
        let expectation = expectation(description: "challenge")
        
        let transaction = FakeTransaction(authParams: FakeAuthParameters())
        transaction.challengeBehavior = .cancel
        let context = NetceteraSDKSessionContext(
            transaction: transaction,
            sdkTransactionId: "tx",
            sdkAppId: "app",
            sdkEphemeralPublicKey: "{}",
            deviceInfo: "device"
        )
        let challenge = ThreeDSChallengeData(
            threeDSServerTransactionID: "server",
            acsTransactionID: "acs",
            acsSignedContent: nil,
            acsReferenceNumber: nil,
            sdkTransactionID: "sdk"
        )
        
        let returnURL: String? = nil
        performer(context, challenge, returnURL, UIViewController()) { result in
            XCTAssertEqual(result, .cancelled)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func test_defaultChallengePerformerMapsThrownError() {
        let performer = NetceteraSDKBridge.makeDefaultChallengePerformer(activeState: ActiveChallengeState())
        let expectation = expectation(description: "challenge")
        
        let transaction = FakeTransaction(authParams: FakeAuthParameters())
        transaction.challengeBehavior = .throwError
        let context = NetceteraSDKSessionContext(
            transaction: transaction,
            sdkTransactionId: "tx",
            sdkAppId: "app",
            sdkEphemeralPublicKey: "{}",
            deviceInfo: "device"
        )
        let challenge = ThreeDSChallengeData(
            threeDSServerTransactionID: "server",
            acsTransactionID: "acs",
            acsSignedContent: nil,
            acsReferenceNumber: nil,
            sdkTransactionID: "sdk"
        )
        
        let returnURL: String? = nil
        performer(context, challenge, returnURL, UIViewController()) { result in
            if case .failed = result {
                expectation.fulfill()
            } else {
                XCTFail("Expected failure")
            }
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func test_prepareChallengeParametersSetsRequestorURL() {
        let params = NetceteraSDKBridge.prepareChallengeParameters(
            ThreeDSChallengeData(
                threeDSServerTransactionID: "server",
                acsTransactionID: "acs",
                acsSignedContent: nil,
                acsReferenceNumber: nil,
                sdkTransactionID: "sdk-id"
            ),
            returnURL: "app://callback"
        )
        
        XCTAssertEqual(params.getThreeDSRequestorAppURL(), "app://callback?transID=sdk-id")
    }
    
    func test_updateAppURLStringHandlesInvalid() {
        XCTAssertNil(NetceteraSDKBridge.updateAppURLString(nil, transactionID: "id"))
        XCTAssertNil(NetceteraSDKBridge.updateAppURLString("not a url", transactionID: "id"))
    }
    
    func test_newServiceUsesConfigProviderAndFactory() throws {
        let authParams = FakeAuthParameters()
        let transaction = FakeTransaction(authParams: authParams)
        let service = FakeService(transaction: transaction)
        let configProvider = StubConfigProvider()
        let serviceFactory: NetceteraSDKBridge.ServiceFactory = { service }
        let serviceInstance = try NetceteraSDKBridge.newService(
            configProvider: configProvider,
            config: sampleConfig(),
            uiCustomization: nil,
            serviceFactory: serviceFactory
        )
        _ = try serviceInstance.createTransaction(directoryServerId: "dir", messageVersion: "2.1.0")
        XCTAssertTrue(service.didInitialize)
    }
}

private enum DummyError: Error {
    case defaultError
}

private struct StubConfigProvider: NetceteraSDKConfigProviding {
    let logLevel: LogLevel = .info
    let locale: Locale? = Locale(identifier: "en-US")
    
    func apiKey(for config: NetceteraSDKConfig) throws -> String { "key" }
    func makeScheme(for config: NetceteraSDKConfig) -> Scheme? { nil }
}

private final class FakeService: ThreeDS2ServiceProviding {
    var didInitialize = false
    var didCreateTransaction = false
    let transaction: TransactionPerforming
    
    init(transaction: TransactionPerforming) {
        self.transaction = transaction
    }
    
    func initialize(_ configParameters: ConfigParameters, locale: String?, uiCustomization: UiCustomization?) throws {
        didInitialize = true
    }
    
    func createTransaction(directoryServerId: String, messageVersion: String) throws -> TransactionPerforming {
        didCreateTransaction = true
        return transaction
    }
}

private final class FakeTransaction: TransactionPerforming {
    enum Behavior {
        case complete
        case cancel
        case timeout
        case protocolError
        case runtimeError
        case throwError
    }
    
    var challengeBehavior: Behavior = .complete
    private let authParams: AuthParametersProviding
    
    init(authParams: AuthParametersProviding) {
        self.authParams = authParams
    }
    
    func doChallenge(
        challengeParameters: ChallengeParameters,
        challengeStatusReceiver: ChallengeStatusReceiver,
        timeOut: Int,
        inViewController: UIViewController
    ) throws {
        guard let receiver = challengeStatusReceiver as? BridgeChallengeStatusReceiver else { return }
        
        switch challengeBehavior {
        case .complete:
            receiver.onComplete?(.success(()))
        case .cancel:
            receiver.onComplete?(.failure(.cancelled))
        case .timeout:
            receiver.onComplete?(.failure(.timedOut))
        case .protocolError:
            receiver.onComplete?(.failure(.protocolError(event: nil)))
        case .runtimeError:
            receiver.onComplete?(.failure(.runtimeError(event: nil)))
        case .throwError:
            throw DummyError.defaultError
        }
    }
    
    func getAuthenticationRequestParameters() throws -> AuthParametersProviding {
        authParams
    }
}

private final class FakeAuthParameters: AuthParametersProviding {
    func getDeviceData() -> String { "device" }
    func getSDKTransactionId() -> String { "trans-id" }
    func getSDKAppID() -> String { "app-id" }
    func getSDKEphemeralPublicKey() -> String { "{}" }
}

private func sampleConfig() -> NetceteraSDKConfig {
    NetceteraSDKConfig(
        id: "id",
        deviceInfoEncryptionAlg: "alg",
        deviceInfoEncryptionEnc: "enc",
        deviceInfoEncryptionCertPem: "pem",
        directoryServerId: "dir",
        key: Data(repeating: 0, count: 32).base64EncodedString(),
        messageVersion: "2.1.0"
    )
}
