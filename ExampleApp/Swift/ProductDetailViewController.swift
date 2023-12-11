import UIKit
import OmiseSDK

@objc(OMSExampleProductDetailViewController)
// swiftlint:disable:next attributes
class ProductDetailViewController: OMSBaseViewController {
    private let publicKey = LocalConfig.default.publicKey
    
    private var capability: Capability?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupClient()
    }

    private func setupClient() {
        // Setup dev environment for staging
        Configuration.setDefault(Configuration(environment: LocalConfig.default.env))

        let client = Client(publicKey: publicKey)

        client.capabilityDataWithCompletionHandler { (result) in
            if case .success(let capability) = result {
                self.capability = capability
                print("Capability Country: \(capability.countryCode)")
            }
        }

        AuthorizingPayment.shared.setAPIKey(LocalConfig.default.netceteraAPIKey)
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
        } else if segue.identifier == "ShowCreditFormWithCustomFields",
            let vc = segue.destination as? CustomCreditCardFormViewController {
            vc.delegate = self
        }
    }
    
    @IBAction private func showModalCreditCardForm(_ sender: Any) {
        guard currentCodePathMode == .code else {
            return
        }
        let creditCardFormController = CreditCardFormViewController.makeCreditCardFormViewController(withPublicKey: publicKey)
        creditCardFormController.handleErrors = true
        creditCardFormController.delegate = self
        let navigationController = UINavigationController(rootViewController: creditCardFormController)
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction private func showCreditCardForm(_ sender: UIButton) {
        guard currentCodePathMode == .code else {
            return
        }
        let creditCardFormController = CreditCardFormViewController.makeCreditCardFormViewController(withPublicKey: publicKey)
        creditCardFormController.handleErrors = true
        creditCardFormController.delegate = self
        show(creditCardFormController, sender: self)
    }
    
    @IBAction private func showModalPaymentCreator(_ sender: Any) {
        guard currentCodePathMode == .code else {
            return
        }
        let paymentCreatorController = PaymentCreatorController.makePaymentCreatorControllerWith(
            publicKey: publicKey,
            amount: paymentAmount,
            currency: Currency(code: paymentCurrencyCode),
            allowedPaymentMethods: allowedPaymentMethods,
            paymentDelegate: self
        )
        present(paymentCreatorController, animated: true, completion: nil)
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
        alertController.addAction(UIAlertAction(title: "Go", style: UIAlertAction.Style.default) { [weak self] (_) in
            guard let self = self,
                  let textField = alertController.textFields?.first,
                  let text = textField.text,
                  let url = URL(string: text),
                  let deeplinkURL = AppDeeplink.threeDSChallenge.url,
                  let expectedWebReturnURL = URL(string: "https://omise.co/orders")
            else { return }

            AuthorizingPayment.shared.presentAuthPaymentController(
                from: self,
                url: url,
                expectedWebViewReturnURL: expectedWebReturnURL,
                deeplinkURL: deeplinkURL,
                uiCustomization: self.threeDSUICustomization) { [weak self] result in
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                        let alertController = UIAlertController(title: "Authorizing Payment",
                                                                message: "Status: \(result)",
                                                                preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                        self?.present(alertController, animated: true, completion: nil)
                    }

            }
        })
        present(alertController, animated: true, completion: nil)
    }
}

private extension ProductDetailViewController {
    var threeDSUICustomization: ThreeDSUICustomization? {
        let threeDSUICustomization = ThreeDSUICustomization()
        threeDSUICustomization.buttonCustomization = [
            .RESEND:
                ThreeDSButtonCustomization()
                .backgroundColorHex("#93C572"), // Green shade
            .SUBMIT:
                ThreeDSButtonCustomization()
                .backgroundColorHex("#FFBF00") // Orange
        ]
        threeDSUICustomization.labelCustomization = ThreeDSLabelCustomization()
            .headingTextColorHex("#FFAA33") // Yellow-Orange
        threeDSUICustomization.toolbarCustomization = ThreeDSToolbarCustomization()
            .headerText("Omise 3DS Challenge")
            .buttonText("Ok")
        threeDSUICustomization.textBoxCustomization = ThreeDSTextBoxCustomization()
            .borderWidth(10)
            .borderColorHex("#00FF00") // Green
            .cornerRadius(6)
        return threeDSUICustomization
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

extension ProductDetailViewController: AuthorizingPaymentWebViewControllerDelegate {
    func authorizingPaymentWebViewController(_ viewController: AuthorizingPaymentWebViewController, didCompleteAuthorizingPaymentWithRedirectedURL redirectedURL: URL) {
        print(redirectedURL)
        dismiss(animated: true, completion: nil)
    }
    
    func authorizingPaymentWebViewControllerDidCancel(_ viewController: AuthorizingPaymentWebViewController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Payment Creator Controller Delegate

extension ProductDetailViewController: PaymentCreatorControllerDelegate {
    
    func paymentCreatorController(_ paymentCreatorController: PaymentCreatorController, didCreatePayment payment: Payment) {
        dismissForm {
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
        }
    }
    
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
