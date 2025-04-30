import UIKit
import OmiseSDK

class ProductDetailViewController: BaseViewController {
    lazy var omiseSDK: OmiseSDK = {
        // Initialize OmiseSDK instance with given publicKey and optional configuration used for testing
        let omiseSDK = OmiseSDK(
            publicKey: self.pkeyFromSettings.isEmpty ? LocalConfig.default.publicKey : self.pkeyFromSettings,
            configuration: LocalConfig.default.configuration
        )
        
        // Setup merchant ID for ApplePay
        omiseSDK.setupApplePay(for: LocalConfig.default.merchantId, requiredBillingAddress: true)
        
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

    @IBAction private func showModalCreditCardPayment(_ sender: Any) {
        omiseSDK.presentCreditCardPayment(from: self, delegate: self)
    }
    
    @IBAction private func showChoosePaymentMethods(_ sender: Any) {
        omiseSDK.presentChoosePaymentMethod(
            from: self,
            amount: paymentAmount,
            currency: paymentCurrencyCode,
            allowedPaymentMethods: usesCapabilityDataForPaymentMethods ? nil : allowedPaymentMethods,
            isCardPaymentAllowed: true,
            handleErrors: true,
            delegate: self
        )
    }
    
    @IBAction private func showCustomCreditCardPayment(_ sender: Any) {
        let customCreditCardPaymentController = CustomCreditCardPaymentController(nibName: nil, bundle: nil)
        customCreditCardPaymentController.delegate = self
        show(customCreditCardPaymentController, sender: sender)
    }
    
    @IBAction private func handlingAuthorizingPayment(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Authorizing Payment",
                                                message: "Please input your given authorize URL",
                                                preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Go", style: UIAlertAction.Style.default) { [weak self ](_) in
            guard let self = self,
                  let textField = alertController.textFields?.first,
                  let text = textField.text,
                  let url = URL(string: text) else { return }

            // Optional 3DS challenge screen customization
            let toolbarUI = ThreeDSToolbarCustomization(
                backgroundColorHex: "#FFFFFF",
                headerText: "Secure Checkout",
                buttonText: "Close",
                textFontName: "Arial-BoldMT",
                textColorHex: "#000000",
                textFontSize: 20
            )

            let threeDSUICustomization = ThreeDSUICustomization(toolbarCustomization: toolbarUI)

            self.omiseSDK.presentAuthorizingPayment(
                from: self,
                authorizeURL: url,
                expectedReturnURLStrings: ["https://omise.co"],
                threeDSRequestorAppURLString: AppDeeplink.threeDSChallenge.urlString,
                threeDSUICustomization: threeDSUICustomization,
                delegate: self
            )
        })
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Authorizing Payment View Controller Delegate

extension ProductDetailViewController: AuthorizingPaymentDelegate {
    func authorizingPaymentDidComplete(with redirectedURL: URL?) {
        print("Payment is authorized with redirect url `\(String(describing: redirectedURL))`")
        omiseSDK.dismiss()
    }
    func authorizingPaymentDidCancel() {
        print("Payment is not authorized")
        omiseSDK.dismiss()
    }
}

/// Processing result of choosing Payment Method screen
extension ProductDetailViewController: ChoosePaymentMethodDelegate {
    func choosePaymentMethodDidComplete(with source: Source) {
        print("Source is created with id '\(source.id)'")
        copyToPasteboard(source.id)
        omiseSDK.dismiss {
            let alertController = UIAlertController(
                title: "Source Created\n(\(source.paymentInformation.sourceType.rawValue))",
                message: "A source with id of \(source.id) was successfully created. Please send this id to server to create a charge. ID is copied to your pastedboard",
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func choosePaymentMethodDidComplete(with token: Token) {
        print("Token is created with id '\(token.id)'")
        copyToPasteboard(token.id)
        omiseSDK.dismiss {
            let alertController = UIAlertController(
                title: "Token Created",
                message: "A token with id of \(token.id) was successfully created. Please send this id to server to create a charge. ID is copied to your pastedboard",
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func choosePaymentMethodDidComplete(with error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)

        let vc = omiseSDK.presentedViewController ?? self
        vc.present(alertController, animated: true, completion: nil)
    }

    func choosePaymentMethodDidCancel() {
        omiseSDK.dismiss()
    }

    func choosePaymentMethodDidComplete(with source: Source, token: Token) {
        print("White-label installment payment Token is created with id '\(token.id)', Source id: '\(source.id)'")
        copyToPasteboard("\(token.id) \(source.id)")
        omiseSDK.dismiss {
            let alertController = UIAlertController(
                title: "Token & Source Created\n(\(source.paymentInformation.sourceType.rawValue))",
                message: "A token with id of \(token.id) and source with id of \(source.id) was successfully created. Please send this id to server to create a charge. Token and Source IDs are copied to your pastedboard separated by space.",
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }

    }
}

// MARK: - Custom Credit Card Form View Controller Delegate
extension ProductDetailViewController: CustomCreditCardPaymentControllerDelegate {
    func creditCardFormViewController(_ controller: CustomCreditCardPaymentController, didSucceedWithToken token: Token) {
        print("Token is created by using custom form with id '\(token.id)'")
        copyToPasteboard(token.id)
        dismissForm {
            let alertController = UIAlertController(
                title: "Token Created",
                message: "A token with id of \(token.id) was successfully created. Please send this id to server to create a charge. ID is copied to your pastedboard",
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

private extension ProductDetailViewController {
    func copyToPasteboard(_ string: String) {
        UIPasteboard.general.string = string
    }
}
