import UIKit
import SafariServices

class SafariPasskeyAuthenticationHandler: PasskeyAuthenticationProtocol {
    private weak var safariViewController: SFSafariViewController?
    private weak var currentDelegate: AuthorizingPaymentDelegate?
    private var expectedReturnURLStrings: [String] = []
    private weak var presentingViewController: UIViewController?
    private var isAuthenticationActive: Bool = false
    
    func shouldHandlePasskey(_ url: URL) -> Bool {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = urlComponents.queryItems else {
            return false
        }
        
        let requiredParams = ["signature"] // "t", "sigv" - could add these if confirmd
        let presentParams = Set(queryItems.compactMap { $0.name })
        
        // Check if all required parameters are present
        return requiredParams.allSatisfy { presentParams.contains($0) }
    }
    
    func presentPasskeyAuthentication(
        from viewController: UIViewController,
        authorizeURL: URL,
        expectedReturnURLStrings: [String],
        delegate: AuthorizingPaymentDelegate
    ) {
        // Create SFSafariViewController for passkey authentication
        let safariViewController = SFSafariViewController(url: authorizeURL)
        
        // Configure Safari view controller
        safariViewController.dismissButtonStyle = .cancel
        safariViewController.preferredBarTintColor = .systemBackground
        safariViewController.preferredControlTintColor = .systemBlue
        
        // Store state for callback handling
        self.expectedReturnURLStrings = expectedReturnURLStrings
        self.currentDelegate = delegate
        self.presentingViewController = viewController
        self.isAuthenticationActive = true
        
        // Present Safari view controller
        viewController.present(safariViewController, animated: true)
        
        // Store reference
        self.safariViewController = safariViewController
    }
    
    func handlePasskeyCallback(_ url: URL) -> Bool {
        // Check if authentication is active and URL matches expected patterns
        guard isAuthenticationActive && currentDelegate != nil else {
            return false
        }
        
        let containsURL = expectedReturnURLStrings
            .map { url.match(string: $0) }
            .contains(true)
        
        if containsURL {
            // Dismiss Safari view controller if it exists
            if let safariViewController = safariViewController {
                safariViewController.dismiss(animated: true) { [weak self] in
                    self?.currentDelegate?.authorizingPaymentDidComplete(with: url)
                    self?.cleanup()
                }
            } else {
                // Handle case where Safari presentation may have failed (e.g., in tests)
                currentDelegate?.authorizingPaymentDidComplete(with: url)
                cleanup()
            }
            return true
        }
        
        return false
    }
    
    private func cleanup() {
        safariViewController = nil
        currentDelegate = nil
        expectedReturnURLStrings = []
        presentingViewController = nil
        isAuthenticationActive = false
    }
    
    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let safariViewController = safariViewController else {
            cleanup()
            completion?()
            return
        }
        
        safariViewController.dismiss(animated: animated) { [weak self] in
            self?.cleanup()
            completion?()
        }
    }
}
