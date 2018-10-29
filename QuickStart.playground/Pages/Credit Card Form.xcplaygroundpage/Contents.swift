import UIKit
import OmiseSDK
import PlaygroundSupport

 let publicKey = "pkey_test_<#Omise Public Key#>"

/*: credit-card-form
 
 To get going quickly, the SDK provides ready-made credit card form that you can integrate directly into your application's checkout process.
 
 Additionally, to provide consistent experience for the form, we recommend wrapping the form in a `UINavigationController`.
 
 Let's make a simple view checkout button to try this out:
 
 */

let checkoutController = CheckoutViewController()
checkoutController.delegate = checkoutController

let navigationController = UINavigationController(rootViewController: checkoutController)

PlaygroundPage.current.liveView = navigationController
PlaygroundPage.current.needsIndefiniteExecution = true



/*: implement-delegate
 
 The form will automatically tokenizes credit card data for you as the user click on the submit button. To receive the resulting token data, implement the `CreditCardFormDelegate` methods on your view controller.
 
 */
extension CheckoutViewController: CreditCardFormViewControllerDelegate {
  public func creditCardFormViewController(_ controller: CreditCardFormViewController, didSucceedWithToken token: Token) {
    dismiss(animated: true, completion: nil)
    print("token created: \(token.id )")
    
    let alert = UIAlertController(title: "Token", message: token.id, preferredStyle: .alert)
    present(alert, animated: true, completion: nil)
    
  }
  
  public func creditCardFormViewController(_ controller: CreditCardFormViewController, didFailWithError error: Error) {
    dismiss(animated: true, completion: nil)
    print("error: \(error)")
    
    let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
    present(alert, animated: true, completion: nil)
    
  }
  
  public func creditCardFormViewControllerDidCancel(_ controller: CreditCardFormViewController) {
    dismiss(animated: true, completion: nil)
  }
}


extension CheckoutViewController: CheckoutViewControllerDelegate {
  public func checkoutViewControllerDidTapCheckout(_ checkoutViewController: CheckoutViewController) {
    let creditCardForm = CreditCardFormViewController.makeCreditCardFormViewController(withPublicKey: publicKey)
    creditCardForm.delegate = self
    
    let navigationController = UINavigationController(rootViewController: creditCardForm)
    present(navigationController, animated: true, completion: nil)
  }
}

