import UIKit
import OmiseSDK


@objc(OMSExampleProductDetailViewController)
class ProductDetailViewController: OMSBaseViewController {
    private let publicKey = "pkey_test_<#Omise Public Key#>"
    
    private var capability: Capability? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let client = Client(publicKey: publicKey)
        client.capabilityDataWithCompletionHandler { (result) in
            if case .success(let capability) = result {
                self.capability = capability
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "PresentCreditFormWithModal" ||
            identifier == "ShowCreditForm" ||
            identifier == "PresentPaymentCreator" ||
            identifier == "ShowCreditFormWithCustomFields" {
            return currentCodePathMode == .storyboard
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "PresentCreditFormWithModal",
            let creditCardFormNavigationController = segue.destination as? UINavigationController,
            let creditCardFormController = creditCardFormNavigationController.topViewController as? CreditCardFormViewController {
            creditCardFormController.publicKey = publicKey
            creditCardFormController.handleErrors = true
            creditCardFormController.delegate = self
        } else if segue.identifier == "ShowCreditForm",
            let creditCardFormController = segue.destination as? CreditCardFormViewController {
            creditCardFormController.publicKey = publicKey
            creditCardFormController.handleErrors = true
            creditCardFormController.delegate = self
        } else if segue.identifier == "PresentPaymentCreator",
            let paymentCreatorController = segue.destination as? PaymentCreatorController {
            paymentCreatorController.publicKey = self.publicKey
            paymentCreatorController.paymentAmount = paymentAmount
            paymentCreatorController.paymentCurrency = Currency(code: paymentCurrencyCode)
            if usesCapabilityDataForPaymentMethods, let capability = self.capability {
                paymentCreatorController.applyPaymentMethods(from: capability)
            } else {
                paymentCreatorController.allowedPaymentMethods = allowedPaymentMethods
            }
            paymentCreatorController.paymentDelegate = self
        }
    }
    
    @IBAction func showModalCreditCardForm(_ sender: Any) {
        guard currentCodePathMode == .code else {
            return
        }
        let creditCardFormController = CreditCardFormViewController.makeCreditCardFormViewController(withPublicKey: publicKey)
        creditCardFormController.handleErrors = true
        creditCardFormController.delegate = self
        let navigationController = UINavigationController(rootViewController: creditCardFormController)
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func showCreditCardForm(_ sender: UIButton) {
        guard currentCodePathMode == .code else {
            return
        }
        let creditCardFormController = CreditCardFormViewController.makeCreditCardFormViewController(withPublicKey: publicKey)
        creditCardFormController.handleErrors = true
        creditCardFormController.delegate = self
        show(creditCardFormController, sender: self)
    }
    
    @IBAction func showModalPaymentCreator(_ sender: Any) {
        guard currentCodePathMode == .code else {
            return
        }
        let paymentCreatorController = PaymentCreatorController.makePaymentCreatorControllerWith(publicKey: publicKey, amount: paymentAmount, currency: Currency(code: paymentCurrencyCode), allowedPaymentMethods: allowedPaymentMethods, paymentDelegate: self)
        present(paymentCreatorController, animated: true, completion: nil)
    }
    
    @IBAction func showCustomCreditCardForm(_ sender: Any) {
        guard currentCodePathMode == .code else {
            return
        }
        let customCreditCardFormController = CustomCreditCardFormViewController(nibName: nil, bundle: nil)
        customCreditCardFormController.delegate = self
        show(customCreditCardFormController, sender: sender)
    }
    
    @IBAction func handlingAuthorizingPayment(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Authorizing Payment", message: "Please input your given authorized URL", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        alertController.addAction(UIAlertAction(title: "Cancel", style: AlertActionStyle.cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Go", style: AlertActionStyle.default, handler: { (_) in
            guard let textField = alertController.textFields?.first, let text = textField.text,
                let url = URL(string: text) else { return }
            
            let expectedReturnURL = URLComponents(string: "http://www.example.com/orders")!
            let handlerController =
                AuthorizingPaymentViewController
                    .makeAuthorizingPaymentViewControllerNavigationWithAuthorizedURL(
                        url, expectedReturnURLPatterns: [expectedReturnURL], delegate: self)
            self.present(handlerController, animated: true, completion: nil)
        }))
        present(alertController, animated: true, completion: nil)
    }
}


// MARK: - Credit Card Form View Controller Delegate

extension ProductDetailViewController: CreditCardFormViewControllerDelegate {
    func creditCardFormViewControllerDidCancel(_ controller: CreditCardFormViewController) {
        dismissForm()
    }
    
    func creditCardFormViewController(_ controller: CreditCardFormViewController, didSucceedWithToken token: Token) {
        dismissForm(completion: {
            let alertController = UIAlertController(
                title: "Token Created",
                message: "A token with id of \(token.id) was successfully created. Please send this id to server to create a charge.",
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    func creditCardFormViewController(_ controller: CreditCardFormViewController, didFailWithError error: Error) {
        dismissForm(completion: {
            let alertController = UIAlertController(
                title: "Error",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        })
    }
}


// MARK: - Authorizing Payment View Controller Delegate

extension ProductDetailViewController: AuthorizingPaymentViewControllerDelegate {
    func authorizingPaymentViewController(_ viewController: AuthorizingPaymentViewController, didCompleteAuthorizingPaymentWithRedirectedURL redirectedURL: URL) {
        print(redirectedURL)
        dismiss(animated: true, completion: nil)
    }
    
    func authorizingPaymentViewControllerDidCancel(_ viewController: AuthorizingPaymentViewController) {
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - Payment Creator Controller Delegate

extension ProductDetailViewController: PaymentCreatorControllerDelegate {
    
    func paymentCreatorController(_ paymentCreatorController: PaymentCreatorController, didCreatePayment payment: Payment) {
        dismissForm(completion: {
            let title: String
            let message: String
            
            switch payment {
            case .token(let token):
                title = "Token Created"
                message = "A token with id of \(token.id) was successfully created. Please send this id to server to create a charge."
            case .source(let source):
                title = "Token Created"
                message = "A source with id of \(source.id) was successfully created. Please send this id to server to create a charge."
            }
            
            let alertController = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        })    }
    
    func paymentCreatorController(_ paymentCreatorController: PaymentCreatorController, didFailWithError error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        paymentCreatorController.present(alertController, animated: true, completion: nil)
    }
    
    func paymentCreatorControllerDidCancel(_ paymentCreatorController: PaymentCreatorController) {
        dismissForm()
    }
}


// MARK: - Custom Credit Card Form View Controller Delegate

extension ProductDetailViewController: CustomCreditCardFormViewControllerDelegate {
    func creditCardFormViewController(_ controller: CustomCreditCardFormViewController, didSucceedWithToken token: Token) {
        dismissForm(completion: {
            let alertController = UIAlertController(
                title: "Token Created",
                message: "A token with id of \(token.id) was successfully created. Please send this id to server to create a charge.",
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    func creditCardFormViewController(_ controller: CustomCreditCardFormViewController, didFailWithError error: Error) {
        dismissForm(completion: {
            let alertController = UIAlertController(
                title: "Error",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        })
    }
}

