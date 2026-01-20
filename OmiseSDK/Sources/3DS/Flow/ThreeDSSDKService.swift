import Foundation
import UIKit

public final class NetceteraThreeDSSDKService: ThreeDSSDKServiceProtocol {
    private let bridge: NetceteraSDKBridgeProtocol
    
    public convenience init() {
        self.init(bridge: NetceteraSDKBridge())
    }
    
    init(bridge: NetceteraSDKBridgeProtocol) {
        self.bridge = bridge
    }
    
    public func beginSession(
        config: NetceteraSDKConfig,
        uiCustomization: ThreeDSUICustomization?
    ) throws -> ThreeDSSDKSession {
        let context = try bridge.createSession(config: config, uiCustomization: uiCustomization)
        return ThreeDSSDKSession(
            bridgeSession: context,
            sdkTransactionId: context.sdkTransactionId,
            sdkAppId: context.sdkAppId,
            sdkEphemeralPublicKey: context.sdkEphemeralPublicKey,
            deviceInfo: context.deviceInfo
        )
    }
    
    public func performChallenge(
        session: ThreeDSSDKSession,
        challenge: ThreeDSChallengeData,
        returnURL: String?,
        from viewController: UIViewController,
        completion: @escaping (ThreeDSFlowResult) -> Void
    ) {
        guard let context = session.bridgeSession as? NetceteraSDKSessionContext else {
            completion(.failed("Invalid session context"))
            return
        }
        
        bridge.performChallenge(
            context: context,
            challenge: challenge,
            returnURL: returnURL,
            from: viewController,
            completion: completion
        )
    }
    
    public func openDeepLink(_ url: URL) -> Bool {
        bridge.handleDeepLink(url)
    }
}
