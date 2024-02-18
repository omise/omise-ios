import UIKit
import OmiseSDK

class ProductDetailViewController: BaseViewController {
    let omiseSDK = OmiseSDK(
        publicKey: LocalConfig.default.publicKey,
        configuration: LocalConfig.default.configuration
    )

    private func loadCapability() {
        omiseSDK.client.capability { (result) in
            if case .success(let capability) = result {
                print("Capability Country: \(capability.countryCode)")
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

    override func viewDidLoad() {
        super.viewDidLoad()

        OmiseSDK.shared = omiseSDK
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        super.prepare(for: segue, sender: sender)
//        
//        if segue.identifier == "PresentCreditFormWithModal",
//            let creditCardFormNavigationController = segue.destination as? UINavigationController,
//            let creditCardFormController = creditCardFormNavigationController.topViewController as? CreditCardFormViewController {
//            creditCardFormController.publicKey = publicKey
//            creditCardFormController.handleErrors = true
//            creditCardFormController.delegate = self
//        } else if segue.identifier == "ShowCreditForm",
//            let creditCardFormController = segue.destination as? CreditCardFormViewController {
//            creditCardFormController.publicKey = publicKey
//            creditCardFormController.handleErrors = true
//            creditCardFormController.delegate = self
//        } else if segue.identifier == "PresentPaymentCreator",
//            let paymentCreatorController = segue.destination as? PaymentCreatorController {
//            paymentCreatorController.publicKey = self.publicKey
//            paymentCreatorController.paymentAmount = paymentAmount
//            paymentCreatorController.paymentCurrency = Currency(code: paymentCurrencyCode)
//            if usesCapabilityDataForPaymentMethods, let capability = self.capability {
//                paymentCreatorController.applyPaymentMethods(from: capability)
//            } else {
//                paymentCreatorController.allowedPaymentMethods = allowedPaymentMethods
//            }
//            paymentCreatorController.paymentDelegate = self
//        } else if segue.identifier == "ShowCreditFormWithCustomFields",
//            let vc = segue.destination as? CustomCreditCardFormViewController {
//            vc.delegate = self
//        }
//    }
    
    @IBAction private func showModalCreditCardForm(_ sender: Any) {
        guard currentCodePathMode == .code else {
            return
        }
//        let creditCardFormController = CreditCardFormViewController.makeCreditCardFormViewController(withPublicKey: publicKey)
//        creditCardFormController.handleErrors = true
//        creditCardFormController.delegate = self
//        let navigationController = UINavigationController(rootViewController: creditCardFormController)
//        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction private func showCreditCardForm(_ sender: UIButton) {
        guard currentCodePathMode == .code else {
            return
        }
//        let creditCardFormController = CreditCardFormViewController.makeCreditCardFormViewController(withPublicKey: publicKey)
//        creditCardFormController.handleErrors = true
//        creditCardFormController.delegate = self
//        show(creditCardFormController, sender: self)
    }
    
    @IBAction private func showModalPaymentCreator(_ sender: Any) {
        guard currentCodePathMode == .code else {
            return
        }

        if usesCapabilityDataForPaymentMethods {
            let viewController = omiseSDK.choosePaymentMethodFromCapabilityController(
                amount: paymentAmount,
                currency: paymentCurrencyCode,
                delegate: self
            )
            present(viewController, animated: true, completion: nil)
        } else {
            let viewController = omiseSDK.choosePaymentMethodController(
                amount: paymentAmount,
                currency: paymentCurrencyCode,
                allowedPaymentMethods: allowedPaymentMethods,
                allowedCardPayment: true,
                delegate: self
            )
            present(viewController, animated: true, completion: nil)
        }
    }
    
    @IBAction private func showCustomCreditCardForm(_ sender: Any) {
        guard currentCodePathMode == .code else {
            return
        }
        let customCreditCardFormController = CustomCreditCardFormViewController(nibName: nil, bundle: nil)
        customCreditCardFormController.delegate = self
        show(customCreditCardFormController, sender: sender)
    }
    
    @IBAction private func handlingAuthorizingPayment(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Authorizing Payment",
                                                message: "Please input your given authorized URL",
                                                preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Go", style: UIAlertAction.Style.default) { (_) in
            guard let textField = alertController.textFields?.first,
                  let text = textField.text,
                  let url = URL(string: text),
                  let expectedReturnURL = URLComponents(string: "https://opn.ooo/") else { return }

            let handlerController =
                AuthorizingPaymentViewController
                    .makeAuthorizingPaymentViewControllerNavigationWithAuthorizedURL(
                        url, expectedReturnURLPatterns: [expectedReturnURL], delegate: self)
            self.present(handlerController, animated: true, completion: nil)
        })
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Credit Card Form View Controller Delegate

extension ProductDetailViewController: CreditCardFormViewControllerDelegate {
    func creditCardFormViewControllerDidCancel(_ controller: CreditCardFormViewController) {
        dismissForm()
    }
    
    func creditCardFormViewController(_ controller: CreditCardFormViewController, didSucceedWithToken token: Token) {
        dismissForm {
            let alertController = UIAlertController(
                title: "Token Created",
                message: "A token with id of \(token.id) was successfully created. Please send this id to server to create a charge.",
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func creditCardFormViewController(_ controller: CreditCardFormViewController, didFailWithError error: Error) {
        dismissForm {
            let alertController = UIAlertController(
                title: "Error",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
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

// MARK: - Custom Credit Card Form View Controller Delegate

extension ProductDetailViewController: CustomCreditCardFormViewControllerDelegate {
    func creditCardFormViewController(_ controller: CustomCreditCardFormViewController, didSucceedWithToken token: Token) {
        dismissForm {
            let alertController = UIAlertController(
                title: "Token Created",
                message: "A token with id of \(token.id) was successfully created. Please send this id to server to create a charge.",
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func creditCardFormViewController(_ controller: CustomCreditCardFormViewController, didFailWithError error: Error) {
        dismissForm {
            let alertController = UIAlertController(
                title: "Error",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

/// Processing result of choosing Payment Method screen
extension ProductDetailViewController: ChoosePaymentMethodDelegate {
    func choosePaymentMethodDidComplete(with source: Source) {
        let alertController = UIAlertController(
            title: "Source Created",
            message: "A source with id of \(source.id) was successfully created. Please send this id to server to create a charge.",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    func choosePaymentMethodDidComplete(with token: Token) {
        let alertController = UIAlertController(
            title: "Token Created",
            message: "A token with id of \(token.id) was successfully created. Please send this id to server to create a charge.",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    func choosePaymentMethodDidComplete(with error: Error) {
        dismissForm {
            let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func choosePaymentMethodDidCancel() {
        dismissForm()
    }
}
