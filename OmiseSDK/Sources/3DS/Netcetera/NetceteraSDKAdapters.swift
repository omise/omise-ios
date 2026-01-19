import ThreeDS_SDK

public protocol ThreeDS2ServiceProviding {
    func initialize(_ configParameters: ConfigParameters, locale: String?, uiCustomization: UiCustomization?) throws
    func createTransaction(directoryServerId: String, messageVersion: String) throws -> TransactionPerforming
}

public protocol TransactionPerforming {
    func doChallenge(
        challengeParameters: ChallengeParameters,
        challengeStatusReceiver: ChallengeStatusReceiver,
        timeOut: Int,
        inViewController: UIViewController
    ) throws
    func getAuthenticationRequestParameters() throws -> AuthParametersProviding
}

public protocol AuthParametersProviding {
    func getDeviceData() -> String
    func getSDKTransactionId() -> String
    func getSDKAppID() -> String
    func getSDKEphemeralPublicKey() -> String
}

struct AuthParametersAdapter: AuthParametersProviding {
    private let parameters: AuthenticationRequestParameters
    
    init(parameters: AuthenticationRequestParameters) throws {
        self.parameters = parameters
    }
    
    func getDeviceData() -> String { parameters.getDeviceData() }
    func getSDKTransactionId() -> String { parameters.getSDKTransactionId() }
    func getSDKAppID() -> String { parameters.getSDKAppID() }
    func getSDKEphemeralPublicKey() -> String { parameters.getSDKEphemeralPublicKey() }
}

final class ThreeDS2ServiceAdapter: ThreeDS2ServiceProviding {
    private let service: ThreeDS2ServiceSDK
    
    init(service: ThreeDS2ServiceSDK) {
        self.service = service
    }
    
    func initialize(_ configParameters: ConfigParameters, locale: String?, uiCustomization: UiCustomization?) throws {
        try service.initialize(configParameters, locale: locale, uiCustomization: uiCustomization)
    }
    
    func createTransaction(directoryServerId: String, messageVersion: String) throws -> TransactionPerforming {
        let transaction = try service.createTransaction(directoryServerId: directoryServerId, messageVersion: messageVersion)
        return TransactionAdapter(transaction: transaction)
    }
}

final class TransactionAdapter: TransactionPerforming {
    private let transaction: Transaction
    
    init(transaction: Transaction) {
        self.transaction = transaction
    }
    
    func doChallenge(
        challengeParameters: ChallengeParameters,
        challengeStatusReceiver: ChallengeStatusReceiver,
        timeOut: Int,
        inViewController: UIViewController
    ) throws {
        try transaction.doChallenge(
            challengeParameters: challengeParameters,
            challengeStatusReceiver: challengeStatusReceiver,
            timeOut: timeOut,
            inViewController: inViewController
        )
    }
    
    func getAuthenticationRequestParameters() throws -> AuthParametersProviding {
        try AuthParametersAdapter(parameters: transaction.getAuthenticationRequestParameters())
    }
}
