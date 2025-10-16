import UIKit

protocol PasskeyAuthenticationProtocol {
    func shouldHandlePasskey(_ url: URL) -> Bool
    
    func presentPasskeyAuthentication(
        from viewController: UIViewController,
        authorizeURL: URL,
        expectedReturnURLStrings: [String],
        delegate: AuthorizingPaymentDelegate
    )
    
    func handlePasskeyCallback(_ url: URL) -> Bool
}
