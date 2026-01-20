import Foundation
import UIKit

public final class ThreeDSFlowCoordinator: ThreeDSFlowCoordinatorProtocol {
    
    private let repository: ThreeDSRepositoryProtocol
    private let sdkService: ThreeDSSDKServiceProtocol
    private let callbackQueue: DispatchQueue
    
    public init(
        repository: ThreeDSRepositoryProtocol,
        sdkService: ThreeDSSDKServiceProtocol,
        callbackQueue: DispatchQueue = .main
    ) {
        self.repository = repository
        self.sdkService = sdkService
        self.callbackQueue = callbackQueue
    }
    
    public func handleDeepLink(_ url: URL) -> Bool {
        sdkService.openDeepLink(url)
    }
    
    public func start(
        authURL: URL,
        returnURL: String?,
        uiCustomization: ThreeDSUICustomization?,
        from viewController: UIViewController,
        completion: @escaping (ThreeDSFlowResult) -> Void
    ) {
        
        repository.fetchConfig(authURL: authURL) { [weak self] configResult in
            guard let self else { return }
            switch configResult {
            case .failure:
                self.callbackQueue.async {
                    completion(.failed("Config unavailable"))
                }
            case .success(let config):
                self.start(with: config,
                           authURL: authURL,
                           returnURL: returnURL,
                           uiCustomization: uiCustomization,
                           from: viewController,
                           completion: completion)
            }
        }
    }
}

private extension ThreeDSFlowCoordinator {
    // swiftlint:disable:next function_parameter_count
    func start(
        with config: NetceteraSDKConfig,
        authURL: URL,
        returnURL: String?,
        uiCustomization: ThreeDSUICustomization?,
        from viewController: UIViewController,
        completion: @escaping (ThreeDSFlowResult) -> Void
    ) {
        do {
            let session = try sdkService.beginSession(config: config, uiCustomization: uiCustomization)
            let authRequest = ThreeDSAuthenticationRequest(
                sdkTransactionId: session.sdkTransactionId,
                sdkAppId: session.sdkAppId,
                sdkEphemeralPublicKey: session.sdkEphemeralPublicKey,
                maxTimeout: 5,
                encryptedDeviceInfo: session.deviceInfo
            )
            
            repository.performAuthentication(authURL: authURL, request: authRequest) { [weak self] authResult in
                guard let self else { return }
                switch authResult {
                case .failure(let error):
                    self.callbackQueue.async {
                        completion(.failed("Auth failed: \(error.localizedDescription)"))
                    }
                case .success(let response):
                    self.handleAuthenticationResponse(response,
                                                      session: session,
                                                      returnURL: returnURL,
                                                      viewController: viewController,
                                                      completion: completion)
                }
            }
        } catch {
            callbackQueue.async {
                completion(.failed("SDK start failed: \(error.localizedDescription)"))
            }
        }
    }
    
    func handleAuthenticationResponse(
        _ response: ThreeDSAuthenticationResponse,
        session: ThreeDSSDKSession,
        returnURL: String?,
        viewController: UIViewController,
        completion: @escaping (ThreeDSFlowResult) -> Void
    ) {
        switch response.status {
        case .success:
            callbackQueue.async {
                completion(.completed)
            }
        case .failed:
            callbackQueue.async {
                completion(.failed("Authentication failed"))
            }
        case .unknown(let status):
            callbackQueue.async {
                completion(.failed("Unknown authentication status: \(status)"))
            }
        case .challenge(let challengeData):
            sdkService.performChallenge(session: session,
                                        challenge: challengeData,
                                        returnURL: returnURL,
                                        from: viewController) { [weak self] flowResult in
                guard let self else { return }
                self.callbackQueue.async {
                    completion(flowResult)
                }
            }
        }
    }
}
