import UIKit
import OmiseSDK

class ProductDetailViewController: UIViewController {
    private let publicKey = "pkey_test_4y7dh41kuvvawbhslxw"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PresentCreditFormWithModal",
            let creditCardFormNavigationController = segue.destination as? UINavigationController,
            let creditCardFormController = creditCardFormNavigationController.topViewController as? CreditCardFormController {
            creditCardFormController.publicKey = publicKey
            creditCardFormController.handleErrors = true
            creditCardFormController.delegate = self
            
            creditCardFormController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(dismissCreditCardForm))
        }
    }
    
    @IBAction func showCreditCardForm(_ sender: UIButton) {
        let creditCardFormController = CreditCardFormController.creditCardFormWithPublicKey(publicKey)
        creditCardFormController.handleErrors = true
        creditCardFormController.delegate = self
        show(creditCardFormController, sender: self)
    }
    
    @objc fileprivate func dismissCreditCardForm() {
        dismissCreditCardFormWithCompletion(nil)
    }
    
    @objc fileprivate func dismissCreditCardFormWithCompletion(_ completion: (() -> Void)?) {
        if presentedViewController != nil {
            dismiss(animated: true, completion: completion)
        } else {
            _ = navigationController?.popToViewController(self, animated: true)
            completion?()
        }
    }
}

extension ProductDetailViewController: CreditCardFormDelegate {
    func creditCardForm(_ controller: CreditCardFormController, didSucceedWithToken token: OmiseToken) {
        dismissCreditCardFormWithCompletion({
            self.performSegue(withIdentifier: "CompletePayment", sender: self)
        })
    }
    
    func creditCardForm(_ controller: CreditCardFormController, didFailWithError error: Error) {
        dismissCreditCardForm()
    }
}

