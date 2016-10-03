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
        let creditCardFormController = CreditCardFormController.makeCreditCardForm(withPublicKey: publicKey)
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
    
    @IBAction func handling3DS(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "3DS verification", message: "Please input your given authorized URL", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Go", style: UIAlertActionStyle.default, handler: { (_) in
            guard let textField = alertController.textFields?.first, let text = textField.text,
                let url = URL(string: text) else { return }

            let handlerController = Omise3DSViewController.make3DSViewControllerNavigationWithAuthorizedURL(url, delegate: self)
            self.present(handlerController, animated: true, completion: nil)
        }))
        present(alertController, animated: true, completion: nil)
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

extension ProductDetailViewController: Omise3DSViewControllerDelegate {
    func omise3DSViewController(_ viewController: Omise3DSViewController, didComplete3DSProcessWithRedirectedURL redirectedURL: URL) {
        print(redirectedURL)
        dismiss(animated: true, completion: nil)
    }
    
    func omise3DSViewControllerDidCancel(_ viewController: Omise3DSViewController) {
        dismiss(animated: true, completion: nil)
    }
}


