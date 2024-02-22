import UIKit
import OmiseSDK

class ProductDetailViewController: BaseViewController {
    let omiseSDK = {
        // Initialize OmiseSDK instance with given publicKey and optional configuration used for testing
        let omiseSDK = OmiseSDK(
            publicKey: LocalConfig.default.publicKey,
            configuration: LocalConfig.default.configuration
        )
        // Setup shared instance to use from other screens if required
        OmiseSDK.shared = omiseSDK
        return omiseSDK
    }()

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
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        super.prepare(for: segue, sender: sender)
//        
//        if segue.identifier == "PresentCreditFormWithModal",
//            let creditCardFormNavigationController = segue.destination as? UINavigationController,
//            let creditCardFormController = creditCardFormNavigationController.topViewController as? CreditCardPaymentController {
//            creditCardFormController.publicKey = publicKey
//            creditCardFormController.handleErrors = true
//            creditCardFormController.delegate = self
//        } else if segue.identifier == "ShowCreditForm",
//            let creditCardFormController = segue.destination as? CreditCardPaymentController {
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
//            let vc = segue.destination as? CustomCreditCardPaymentController {
//            vc.delegate = self
//        }
//    }
    
    @IBAction private func showModalCreditCardPayment(_ sender: Any) {
        guard currentCodePathMode == .code else {
            return
        }
//        let creditCardFormController = CreditCardPaymentController.makeCreditCardPaymentController(withPublicKey: publicKey)
//        creditCardFormController.handleErrors = true
//        creditCardFormController.delegate = self
//        let navigationController = UINavigationController(rootViewController: creditCardFormController)
//        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction private func showCreditCardPayment(_ sender: UIButton) {
        guard currentCodePathMode == .code else {
            return
        }
//        let creditCardFormController = CreditCardPaymentController.makeCreditCardPaymentController(withPublicKey: publicKey)
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
    
    @IBAction private func showCustomCreditCardPayment(_ sender: Any) {
        guard currentCodePathMode == .code else {
            return
        }
        let customCreditCardPaymentController = CustomCreditCardPaymentController(nibName: nil, bundle: nil)
        customCreditCardPaymentController.delegate = self
        show(customCreditCardPaymentController, sender: sender)
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

extension ProductDetailViewController: CustomCreditCardPaymentControllerDelegate {
    func creditCardFormViewController(_ controller: CustomCreditCardPaymentController, didSucceedWithToken token: Token) {
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
    
    func creditCardFormViewController(_ controller: CustomCreditCardPaymentController, didFailWithError error: Error) {
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
        dismissForm {
            let alertController = UIAlertController(
                title: "Source Created\n(\(source.paymentInformation.sourceType.rawValue))",
                message: "A source with id of \(source.id) was successfully created. Please send this id to server to create a charge.",
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func choosePaymentMethodDidComplete(with token: Token) {
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
