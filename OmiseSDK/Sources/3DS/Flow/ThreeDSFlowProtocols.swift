import Foundation
import UIKit

public enum ThreeDSChallengeStatus: Equatable {
    case succeeded
    case cancelled
    case timedOut
    case failed(String)
}

public enum ThreeDSFlowResult: Equatable {
    case completed
    case cancelled
    case failed(String)
}

public enum ThreeDSAuthStatus: Equatable {
    case success
    case challenge(ThreeDSChallengeData)
    case failed
    case unknown(String)
}

public struct ThreeDSChallengeData: Equatable {
    public let threeDSServerTransactionID: String
    public let acsTransactionID: String
    public let acsSignedContent: String?
    public let acsReferenceNumber: String?
    public let sdkTransactionID: String
}

public struct ThreeDSAuthenticationRequest: Equatable {
    public let sdkTransactionId: String
    public let sdkAppId: String
    public let sdkEphemeralPublicKey: String
    public let maxTimeout: Int
    public let encryptedDeviceInfo: String
}

public struct ThreeDSAuthenticationResponse: Equatable {
    public let status: ThreeDSAuthStatus
}

public enum ThreeDSFlowState: Equatable {
    case idle
    case loadingConfig
    case startingSDK
    case authenticating
    case challenging
    case completed(ThreeDSFlowResult)
}

public protocol ThreeDSRepositoryProtocol {
    func fetchConfig(authURL: URL, completion: @escaping (Result<NetceteraSDKConfig, Error>) -> Void)
    func performAuthentication(
        authURL: URL,
        request: ThreeDSAuthenticationRequest,
        completion: @escaping (Result<ThreeDSAuthenticationResponse, Error>) -> Void
    )
}

public struct ThreeDSSDKSession {
    /// Opaque vendor session, only the bridge should decode this.
    public let bridgeSession: Any
    public let sdkTransactionId: String
    public let sdkAppId: String
    public let sdkEphemeralPublicKey: String
    public let deviceInfo: String
    
    public init(
        bridgeSession: Any,
        sdkTransactionId: String,
        sdkAppId: String,
        sdkEphemeralPublicKey: String,
        deviceInfo: String
    ) {
        self.bridgeSession = bridgeSession
        self.sdkTransactionId = sdkTransactionId
        self.sdkAppId = sdkAppId
        self.sdkEphemeralPublicKey = sdkEphemeralPublicKey
        self.deviceInfo = deviceInfo
    }
}

public protocol ThreeDSSDKServiceProtocol {
    func beginSession(
        config: NetceteraSDKConfig,
        uiCustomization: ThreeDSUICustomization?
    ) throws -> ThreeDSSDKSession
    func performChallenge(
        session: ThreeDSSDKSession,
        challenge: ThreeDSChallengeData,
        returnURL: String?,
        from viewController: UIViewController,
        completion: @escaping (ThreeDSFlowResult) -> Void
    )
    func openDeepLink(_ url: URL) -> Bool
}

public protocol ThreeDSFlowCoordinatorProtocol: AnyObject {
    func start(
        authURL: URL,
        returnURL: String?,
        uiCustomization: ThreeDSUICustomization?,
        from viewController: UIViewController,
        completion: @escaping (ThreeDSFlowResult) -> Void
    )
    
    func handleDeepLink(_ url: URL) -> Bool
}

public protocol ThreeDSFlowViewModelProtocol: AnyObject {
    var state: ThreeDSFlowState { get } // NOSONAR: protocol exposure intentional
    var onStateChange: ((ThreeDSFlowState) -> Void)? { get set }
    
    func start(
        authURL: URL,
        returnURL: String?,
        uiCustomization: ThreeDSUICustomization?,
        from viewController: UIViewController
    )
    func handleDeepLink(_ url: URL) -> Bool
}
