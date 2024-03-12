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

    @IBAction private func showModalCreditCardPayment(_ sender: Any) {
        omiseSDK.presentCreditCardPayment(from: self, handleErrors: false, delegate: self)
    }
    
    @IBAction private func showChoosePaymentMethods(_ sender: Any) {
        omiseSDK.presentChoosePaymentMethod(
            from: self,
            amount: paymentAmount,
            currency: paymentCurrencyCode,
            allowedPaymentMethods: usesCapabilityDataForPaymentMethods ? [] : allowedPaymentMethods,
            forcePaymentMethods: true,
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
                                                message: "Please input your given authorized URL",
                                                preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Go", style: UIAlertAction.Style.default) { [weak self ](_) in
            guard let self = self,
                  let textField = alertController.textFields?.first,
                  let text = textField.text,
                  let url = URL(string: text),
                  let expectedReturnURL = URLComponents(string: "https://opn.ooo/") else { return }

            self.omiseSDK.presentAuthorizedController(
                from: self,
                authorizedURL: url,
                expectedReturnURLPatterns: [expectedReturnURL],
                delegate: self
            )
        })
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Authorizing Payment View Controller Delegate

extension ProductDetailViewController: AuthorizingPaymentViewControllerDelegate {
    func authorizingPaymentViewController(_ viewController: AuthorizingPaymentViewController, didCompleteAuthorizingPaymentWithRedirectedURL redirectedURL: URL) {
        print(redirectedURL)
        omiseSDK.dismiss()
    }
    
    func authorizingPaymentViewControllerDidCancel(_ viewController: AuthorizingPaymentViewController) {
        omiseSDK.dismiss()
    }
}

// MARK: - Custom Credit Card Form View Controller Delegate

extension ProductDetailViewController: CustomCreditCardPaymentControllerDelegate {
    func creditCardFormViewController(_ controller: CustomCreditCardPaymentController, didSucceedWithToken token: Token) {
        omiseSDK.dismiss {
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
        omiseSDK.dismiss {
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
        omiseSDK.dismiss {
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
        omiseSDK.dismiss {
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
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)

        let vc = omiseSDK.presentedViewController ?? self
        vc.present(alertController, animated: true, completion: nil)
    }

    func choosePaymentMethodDidCancel() {
        omiseSDK.dismiss()
    }
}
