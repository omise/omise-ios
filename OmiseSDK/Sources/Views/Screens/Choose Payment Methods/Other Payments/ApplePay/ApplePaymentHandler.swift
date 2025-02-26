import UIKit
import PassKit

@available(iOS 11.0, *)
extension PKPaymentAuthorizationController: PaymentAuthorizationControllerProtocol {
    
    /// Presents the Apple Pay sheet using Apple’s built-in API.
    ///
    /// - Parameter completion: A closure called with a Boolean indicating whether the sheet was successfully presented.
    public func presentSheet(completion: ((Bool) -> Void)?) {
        self.present(completion: completion)
    }
    
    /// Dismisses the Apple Pay sheet using Apple’s built-in API.
    ///
    /// - Parameter completion: An optional closure called when the sheet has been dismissed.
    public func dismissSheet(completion: (() -> Void)?) {
        self.dismiss(completion: completion)
    }
}

/// A handler that manages the Apple Pay payment flow—including presenting the payment sheet and processing the authorization result.
/// Conforms to `ApplePaymentHandlerType` to allow dependency injection and easy testing.
@available(iOS 11.0, *)
class ApplePaymentHandler: NSObject, ApplePaymentHandlerType {
    
    /// The payment authorization controller conforming to `PaymentAuthorizationControllerProtocol`.
    var paymentController: PaymentAuthorizationControllerProtocol?
    
    /// The completion handler called after payment processing completes.
    private(set) var completionHandler: ((PKPayment?, Error?) -> Void)?
    
    /// The supported payment networks for Apple Pay.
    static let supportedNetworks: [PKPaymentNetwork] = [
        .amex, .discover, .masterCard, .visa, .JCB, .chinaUnionPay
    ]
    
    /// A Boolean value indicating whether the device is capable of making Apple Pay payments.
    static var canMakeApplePayPayment: Bool {
        return PKPaymentAuthorizationController.canMakePayments()
    }
    
    /// Creates a configured `PKPaymentRequest` for the specified parameters.
    ///
    /// - Parameters:
    ///   - amount: The total amount to be charged as an NSDecimalNumber.
    ///   - currency: The currency code (e.g., "USD").
    ///   - country: A `Country` object representing the country code.
    ///   - requiredBillingAddress: A Boolean indicating whether billing address details should be requested.
    ///   - merchantId: The merchant identifier registered for Apple Pay.
    /// - Returns: A configured `PKPaymentRequest` ready to be used in the payment flow.
    func createPKPaymentRequest(
        with amount: NSDecimalNumber,
        currency: String,
        country: Country?,
        requiredBillingAddress: Bool,
        merchantId: String
    ) -> PKPaymentRequest {
        let total = PKPaymentSummaryItem(label: "Total", amount: amount, type: .final)
        
        let paymentRequest = PKPaymentRequest()
        paymentRequest.paymentSummaryItems = [total]
        paymentRequest.merchantIdentifier = merchantId
        paymentRequest.merchantCapabilities = .capability3DS
        paymentRequest.countryCode = country?.code ?? "SG"
        paymentRequest.currencyCode = currency
        paymentRequest.supportedNetworks = Self.supportedNetworks
        
        if requiredBillingAddress {
            paymentRequest.requiredBillingContactFields = [.postalAddress, .name, .phoneNumber, .emailAddress]
        }
        
        return paymentRequest
    }
    
    /// Creates a payment authorization controller from the provided payment request.
    ///
    /// - Parameter request: The `PKPaymentRequest` used to create the payment authorization controller.
    /// - Returns: A new instance of `PKPaymentAuthorizationController` configured with the request.
    func createPaymentAuthViewController(from request: PKPaymentRequest) -> PKPaymentAuthorizationController {
        PKPaymentAuthorizationController(paymentRequest: request)
    }
    
    /// Presents the given payment authorization controller and stores the completion handler.
    ///
    /// - Parameters:
    ///   - controller: The payment authorization controller to present.
    ///   - completion: A closure called with either an authorized `PKPayment` on success or an `Error` on failure.
    func present(
        paymentController controller: PKPaymentAuthorizationController,
        completion: @escaping (PKPayment?, Error?) -> Void
    ) {
        completionHandler = completion
        
        paymentController = controller
        paymentController?.delegate = self
        
        // Present the Apple Pay sheet.
        paymentController?.presentSheet { [weak self] presented in
            guard let self = self else { return }
            if !presented {
                let error = NSError(
                    domain: "PaymentError",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Apple Pay sheet could not be presented"]
                )
                self.completionHandler?(nil, error)
            }
        }
    }
}

// MARK: - PKPaymentAuthorizationControllerDelegate

@available(iOS 11.0, *)
extension ApplePaymentHandler: PKPaymentAuthorizationControllerDelegate {
    
    /// Called when the user authorizes a payment.
    ///
    /// This method is invoked when the payment sheet is used to authorize a payment.
    /// It simulates a successful authorization by creating a `PKPaymentAuthorizationResult` with a `.success` status,
    /// and then passes the authorized payment to the stored completion handler.
    ///
    /// - Parameters:
    ///   - controller: The payment authorization controller.
    ///   - payment: The authorized payment object.
    ///   - completion: A closure used to return the authorization result.
    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        // Simulate a successful payment authorization.
        let result = PKPaymentAuthorizationResult(status: .success, errors: [])
        completion(result) // Dismiss native Apple Pay view controller.
        
        // Call the stored completion handler to pass the authorized payment to the caller.
        completionHandler?(payment, nil)
    }
    
    /// Called when the payment authorization controller has finished.
    ///
    /// This method dismisses the payment sheet and calls the stored completion handler with nil values if it hasn't been called already.
    ///
    /// - Parameter controller: The payment authorization controller.
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        paymentController?.dismissSheet { [weak self] in
            guard let self = self else { return }
            self.completionHandler?(nil, nil)
        }
    }
}
