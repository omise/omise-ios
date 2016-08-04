import UIKit
import OmiseSDK

class ProductDetailViewController: UIViewController {
    private let publicKey = "pkey_test_4y7dh41kuvvawbhslxw"

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PresentCreditFormWithModal",
            let creditCardFormNavigationController = segue.destinationViewController as? UINavigationController,
            let creditCardFormController = creditCardFormNavigationController.topViewController as? CreditCardFormController {
            creditCardFormController.publicKey = publicKey
            creditCardFormController.handleErrors = true
            creditCardFormController.delegate = self
            
            creditCardFormController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .Done, target: self, action: #selector(dismissCreditCardPopover))
        }
    }
    
    @IBAction func showCreditCardForm(sender: UIButton) {
        let creditCardFormController = CreditCardFormController.creditCardFormWithPublicKey(publicKey)
        creditCardFormController.handleErrors = true
        creditCardFormController.delegate = self
        showViewController(creditCardFormController, sender: self)
    }
    
    @objc private func dismissCreditCardPopover() {
        dismissCreditCardPopoverWithCompletion(nil)
    }
    
    @objc private func dismissCreditCardPopoverWithCompletion(completion: (() -> Void)?) {
        if presentedViewController != nil {
            dismissViewControllerAnimated(true, completion: completion)
        } else {
            navigationController?.popToViewController(self, animated: true)
            completion?()
        }
    }
}

extension ProductDetailViewController: CreditCardFormDelegate {
    func creditCardForm(controller: CreditCardFormController, didSucceedWithToken token: OmiseToken) {
        dismissCreditCardPopoverWithCompletion({
            self.performSegueWithIdentifier("CompletePayment", sender: self)
        })
    }
    
    func creditCardForm(controller: CreditCardFormController, didFailWithError error: ErrorType) {
        dismissCreditCardPopover()
    }
}

