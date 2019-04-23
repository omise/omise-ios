import UIKit
import OmiseSDK
import PlaygroundSupport

let publicKey = "pkey_test_<#Omise Public Key#>"

/*: payment-creator
 
The easiest way to ask a customer for their preferred Payment Method is to use the `PaymentCreatorController`
 */

let checkoutController = CheckoutViewController()
checkoutController.delegate = checkoutController

let navigationController = UINavigationController(rootViewController: checkoutController)

PlaygroundPage.current.liveView = navigationController
PlaygroundPage.current.needsIndefiniteExecution = true



/*: implement-delegate
 
 The controller will automatically tokenizes credit card data or create a payment source for you. To receive the result data, implement the `PaymentCreatorControllerDelegate` methods on your view controller.
 
 */
extension CheckoutViewController: PaymentCreatorControllerDelegate {

  public func paymentCreatorController(_ paymentCreatorController: PaymentCreatorController, didCreatePayment payment: Payment) {
    dismiss(animated: true, completion: nil)
    let title: String
    let message: String
    
    switch payment {
    case .token(let token):
      title = "Token"
      message = token.id
    case .source(let source):
      title = "Source"
      message = source.id
    }
    print("\(title) created: \(message)")
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    present(alert, animated: true, completion: nil)
    
  }
  
  public func paymentCreatorController(_ paymentCreatorController: PaymentCreatorController, didFailWithError error: Error) {
    dismiss(animated: true, completion: nil)
    print("error: \(error)")
    
    let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
    present(alert, animated: true, completion: nil)
    
  }
  
  public func paymentCreatorControllerDidCancel(_ paymentCreatorController: PaymentCreatorController) {
    dismiss(animated: true, completion: nil)
  }
}


extension CheckoutViewController: CheckoutViewControllerDelegate {
  public func checkoutViewControllerDidTapCheckout(_ checkoutViewController: CheckoutViewController) {
    let paymentCreatorController = PaymentCreatorController.makePaymentCreatorControllerWith(
      publicKey: publicKey,
      amount: 5_000_00, currency: .thb,
      allowedPaymentMethods: PaymentCreatorController.japanDefaultAvailableSourceMethods,
      paymentDelegate: self
    )
    
    present(paymentCreatorController, animated: true, completion: nil)
  }
}

