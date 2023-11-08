import UIKit
import OmiseSDK
import PlaygroundSupport

/*: authorizing-payment
 Some payment method or credit card need customer to verify their payment with the issuer provider.
 In most case, customers need to visit a website. So Omise iOS SDK provides a built-in class for that.
 The `authorizedURL` parameter is an authorizedURL comes with a charge.
 The expected URL patterns is an array of URL Components which the contains a scheme, host and prefix of your defined return URL(s)
 */

let authroizedURL = URL(string: "https://authorized-url")!

let expectedURLPatterns = [
    URLComponents(string: "https://example.com")!,
    URLComponents(string: "https://omise.co")!,
    URLComponents(string: "https://example.com/returned")!
]

let checkoutController = CheckoutViewController()
checkoutController.delegate = checkoutController

let navigationController = UINavigationController(rootViewController: checkoutController)

PlaygroundPage.current.liveView = navigationController
PlaygroundPage.current.needsIndefiniteExecution = true

/*: implement-delegate
 
 The controller will automatically display a website and will notify the delegate
 when the customer is redirected to the expected URL. To receive the result data,
 implement the `AuthorizingPaymentWebViewControllerDelegate` methods on your view controller.
 */
extension CheckoutViewController: AuthorizingPaymentWebViewControllerDelegate {
  
  public func AuthorizingPaymentWebViewController(_ viewController: AuthorizingPaymentWebViewController, didCompleteAuthorizingPaymentWithRedirectedURL redirectedURL: URL) {
    dismiss(animated: true, completion: nil)
    print("Customer was just redirected to \(redirectedURL)")
    
    let alert = UIAlertController(title: "Authorized", message: redirectedURL.absoluteString, preferredStyle: .alert)
    present(alert, animated: true, completion: nil)
  }
  
  public func AuthorizingPaymentWebViewControllerDidCancel(_ viewController: AuthorizingPaymentWebViewController) {
    dismiss(animated: true, completion: nil)
  }
}

extension CheckoutViewController: CheckoutViewControllerDelegate {
  public func checkoutViewControllerDidTapCheckout(_ checkoutViewController: CheckoutViewController) {
    let navigationController = AuthorizingPaymentWebViewController.makeAuthorizingPaymentWebViewControllerNavigationWithAuthorizedURL(
        authroizedURL,
        expectedReturnURLPatterns: expectedURLPatterns,
        delegate: self
    )
    present(navigationController, animated: true, completion: nil)
  }
}
