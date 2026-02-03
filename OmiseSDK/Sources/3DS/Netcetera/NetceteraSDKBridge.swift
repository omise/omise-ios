import Foundation
import ThreeDS_SDK
import UIKit
import CommonCrypto

final class ActiveChallengeState {
    private let queue = DispatchQueue(label: "com.omise.n3ds.challenge-state")
    private var transaction: TransactionPerforming?
    private var receiver: BridgeChallengeStatusReceiver?

    func trySet(transaction: TransactionPerforming, receiver: BridgeChallengeStatusReceiver) -> Bool {
        var accepted = false
        queue.sync {
            if self.transaction == nil {
                self.transaction = transaction
                self.receiver = receiver
                accepted = true
            }
        }
        return accepted
    }

    func clear() {
        queue.sync {
            transaction = nil
            receiver = nil
        }
    }
}

public protocol NetceteraSDKBridgeProtocol {
    func createSession(
        config: NetceteraSDKConfig,
        uiCustomization: ThreeDSUICustomization?
    ) throws -> NetceteraSDKSessionContext
    
    func performChallenge(
        context: NetceteraSDKSessionContext,
        challenge: ThreeDSChallengeData,
        returnURL: String?,
        from viewController: UIViewController,
        completion: @escaping (ThreeDSFlowResult) -> Void
    )
    
    func handleDeepLink(_ url: URL) -> Bool
}

final class NetceteraSDKBridge: NetceteraSDKBridgeProtocol {
    typealias ServiceFactory = () -> ThreeDS2ServiceProviding
    typealias SessionCreator = (NetceteraSDKConfig, ThreeDSUICustomization?) throws -> NetceteraSDKSessionContext
    typealias ChallengePerformer = (
        NetceteraSDKSessionContext,
        ThreeDSChallengeData,
        String?,
        UIViewController,
        @escaping (ThreeDSFlowResult) -> Void
    ) -> Void
    typealias DeepLinkHandler = (URL) -> Bool
    
    private let sessionCreator: SessionCreator
    private let challengePerformer: ChallengePerformer
    private let deepLinkHandler: DeepLinkHandler
    private let activeState: ActiveChallengeState
    
    init(
        configProvider: NetceteraSDKConfigProviding = NetceteraSDKConfigProvider(),
        serviceFactory: @escaping ServiceFactory = { ThreeDS2ServiceAdapter(service: ThreeDS2ServiceSDK()) },
        sessionCreator: SessionCreator? = nil,
        challengePerformer: ChallengePerformer? = nil,
        deepLinkHandler: DeepLinkHandler? = nil
    ) {
        let activeState = ActiveChallengeState()
        self.activeState = activeState
        
        self.sessionCreator = sessionCreator ?? NetceteraSDKBridge.makeDefaultSessionCreator(
            configProvider: configProvider,
            serviceFactory: serviceFactory
        )
        self.challengePerformer = challengePerformer
        ?? NetceteraSDKBridge.makeDefaultChallengePerformer(activeState: activeState)
        self.deepLinkHandler = deepLinkHandler
        ?? NetceteraSDKBridge.makeDefaultDeepLinkHandler()
    }
    
    func createSession(
        config: NetceteraSDKConfig,
        uiCustomization: ThreeDSUICustomization?
    ) throws -> NetceteraSDKSessionContext {
        try sessionCreator(config, uiCustomization)
    }
    
    func performChallenge(
        context: NetceteraSDKSessionContext,
        challenge: ThreeDSChallengeData,
        returnURL: String?,
        from viewController: UIViewController,
        completion: @escaping (ThreeDSFlowResult) -> Void
    ) {
        challengePerformer(context, challenge, returnURL, viewController, completion)
    }
    
    func handleDeepLink(_ url: URL) -> Bool {
        deepLinkHandler(url)
    }
}

// MARK: - Extension
extension NetceteraSDKBridge {
    static func makeDefaultDeepLinkHandler() -> DeepLinkHandler {
        { url in
            ThreeDSSDKAppDelegate.shared.appOpened(url: url)
        }
    }
    
    static func makeDefaultSessionCreator(
        configProvider: NetceteraSDKConfigProviding,
        serviceFactory: @escaping ServiceFactory = { ThreeDS2ServiceAdapter(service: ThreeDS2ServiceSDK()) }
    ) -> SessionCreator {
        { config, uiCustomization in
            let threeDS2Service = try NetceteraSDKBridge.newService(
                configProvider: configProvider,
                config: config,
                uiCustomization: uiCustomization,
                serviceFactory: serviceFactory
            )
            let transaction = try threeDS2Service.createTransaction(
                directoryServerId: config.directoryServerId,
                messageVersion: config.messageVersion
            )
            
            let authParameters = try transaction.getAuthenticationRequestParameters()
            let deviceInfo = authParameters.getDeviceData()
            
            return NetceteraSDKSessionContext(
                transaction: transaction,
                sdkTransactionId: authParameters.getSDKTransactionId(),
                sdkAppId: authParameters.getSDKAppID(),
                sdkEphemeralPublicKey: authParameters.getSDKEphemeralPublicKey(),
                deviceInfo: deviceInfo
            )
        }
    }
    
    static func makeDefaultChallengePerformer(
        activeState: ActiveChallengeState
    ) -> ChallengePerformer {
        { context, challenge, returnURL, viewController, completion in
            let receiver = makeReceiver(activeState: activeState, completion: completion)
            guard activeState.trySet(transaction: context.transaction, receiver: receiver) else {
                completion(.failed("Another challenge is already in progress"))
                return
            }

            let parameters = NetceteraSDKBridge.prepareChallengeParameters(challenge, returnURL: returnURL)
            let execution = ChallengeExecution(
                context: context,
                parameters: parameters,
                receiver: receiver,
                viewController: viewController
            )
            runChallenge(execution: execution, activeState: activeState, completion: completion)
        }
    }

    static func mapChallengeResult<E: Error>(_ result: Result<Void, E>) -> ThreeDSFlowResult {
        switch result {
        case .success:
            return .completed
        case .failure(let error):
            if let bridgeError = error as? NetceteraSDKBridgeError {
                switch bridgeError {
                case .cancelled, .timedOut:
                    return .cancelled
                case .protocolError(let event):
                    return .failed(event?.getErrorMessage().getErrorDescription() ?? "Protocol error")
                case .runtimeError(let event):
                    return .failed(event?.getErrorMessage() ?? "Runtime error")
                case .incomplete:
                    return .failed("Challenge incomplete")
                }
            }
            return .failed(error.localizedDescription)
        }
    }
    
    static func newService(
        configProvider: NetceteraSDKConfigProviding,
        config: NetceteraSDKConfig,
        uiCustomization: ThreeDSUICustomization?,
        serviceFactory: ServiceFactory = { ThreeDS2ServiceAdapter(service: ThreeDS2ServiceSDK()) }
    ) throws -> ThreeDS2ServiceProviding {
        let threeDS2Service = serviceFactory()
        let configBuilder = ConfigurationBuilder()
        
        if let scheme = configProvider.makeScheme(for: config) {
            try configBuilder.add(scheme)
        }
        
        let apiKey = try configProvider.apiKey(for: config)
        try configBuilder.api(key: apiKey)
        try configBuilder.log(to: configProvider.logLevel)
        let configParameters = configBuilder.configParameters()
        
        var netceteraUICustomization: UiCustomization?
        if let uiCustomization = uiCustomization {
            netceteraUICustomization = try UiCustomization(uiCustomization)
        }
        
        try threeDS2Service.initialize(
            configParameters,
            locale: configProvider.locale?.identifier,
            uiCustomization: netceteraUICustomization
        )
        
        return threeDS2Service
    }
    
    static func newScheme(config: NetceteraSDKConfig) -> Scheme? {
        let formattedCert = config.deviceInfoEncryptionCertPem.pemCertificate
        
        let scheme = Scheme(name: config.id)
        scheme.ids = [config.directoryServerId]
        scheme.encryptionKeyValue = formattedCert
        scheme.rootCertificateValue = formattedCert
        return scheme
    }
    
    static func prepareChallengeParameters(
        _ data: ThreeDSChallengeData,
        returnURL: String?
    ) -> ChallengeParameters {
        let challengeParameters = ChallengeParameters(
            threeDSServerTransactionID: data.threeDSServerTransactionID,
            acsTransactionID: data.acsTransactionID,
            acsRefNumber: data.acsReferenceNumber,
            acsSignedContent: data.acsSignedContent
        )
        
        if let appUrl = updateAppURLString(returnURL, transactionID: data.sdkTransactionID) {
            challengeParameters.setThreeDSRequestorAppURL(threeDSRequestorAppURL: appUrl)
        }
        
        return challengeParameters
    }
    
    static func updateAppURLString(_ urlString: String?, transactionID: String) -> String? {
        guard
            let urlString = urlString,
            let url = URL(string: urlString),
            url.scheme != nil
        else {
            return nil
        }
        
        return url.appendQueryItem(name: "transID", value: transactionID)?.absoluteString
    }
}

final class BridgeChallengeStatusReceiver: ChallengeStatusReceiver {
    var onComplete: ((Result<Void, NetceteraSDKBridgeError>) -> Void)?
    
    func completed(completionEvent: CompletionEvent) {
        if completionEvent.getTransactionStatus() == "Y" {
            onComplete?(.success(()))
        } else {
            onComplete?(.failure(.incomplete(event: completionEvent)))
        }
    }
    
    func cancelled() {
        onComplete?(.failure(.cancelled))
    }
    
    func timedout() {
        onComplete?(.failure(.timedOut))
    }
    
    func protocolError(protocolErrorEvent: ProtocolErrorEvent) {
        onComplete?(.failure(.protocolError(event: protocolErrorEvent)))
    }
    
    func runtimeError(runtimeErrorEvent: RuntimeErrorEvent) {
        onComplete?(.failure(.runtimeError(event: runtimeErrorEvent)))
    }
}

// MARK: - Helpers

extension NetceteraSDKBridge {
    static func makeReceiver(
        activeState: ActiveChallengeState,
        completion: @escaping (ThreeDSFlowResult) -> Void
    ) -> BridgeChallengeStatusReceiver {
        let receiver = BridgeChallengeStatusReceiver()
        receiver.onComplete = { result in
            activeState.clear()
            DispatchQueue.main.async {
                completion(mapChallengeResult(result))
            }
        }
        return receiver
    }

    struct ChallengeExecution {
        let context: NetceteraSDKSessionContext
        let parameters: ChallengeParameters
        let receiver: BridgeChallengeStatusReceiver
        let viewController: UIViewController
    }

    static func runChallenge(
        execution: ChallengeExecution,
        activeState: ActiveChallengeState,
        completion: @escaping (ThreeDSFlowResult) -> Void
    ) {
        DispatchQueue.main.async {
            do {
                try execution.context.transaction.doChallenge(
                    challengeParameters: execution.parameters,
                    challengeStatusReceiver: execution.receiver,
                    timeOut: 5,
                    inViewController: execution.viewController
                )
            } catch {
                activeState.clear()
                completion(.failed(error.localizedDescription))
            }
        }
    }
}
