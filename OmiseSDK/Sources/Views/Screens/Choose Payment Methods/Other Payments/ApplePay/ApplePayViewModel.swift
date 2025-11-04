import Foundation
import PassKit

// MARK: - ApplePayViewModel Implementation

/// A view model that coordinates the Apple Pay payment process by interfacing with a payment handler and a delegate.
/// It converts the Apple Pay payment into a token payload and returns the result via its delegate.
class ApplePayViewModel: NSObject, ApplePayViewModelType {
    /// The input interface of the view model.
    var input: ApplePayViewModelInput { self }
    /// The output interface of the view model.
    var output: ApplePayViewModelOutput { self }
    
    // MARK: - Properties
    
    /// Merchant identifier from the Apple Developer Console.
    var applePayInfo: ApplePayInfo
    
    /// The payment amount in cents (e.g., 999 represents $9.99 for USD).
    var amount: Int64
    
    /// The currency code, such as "USD" or "SGD".
    var currency: String
    
    /// The country where the merchant is operating.
    var country: Country?
    
    /// The payment handler conforming to `ApplePaymentHandlerType` that drives the Apple Pay flow.
    private let applePaymentHandler: ApplePaymentHandlerType
    
    /// The delegate that handles the completion result of the Apple Pay process.
    private let delegate: ApplePayViewModelDelegate
    
    // MARK: - Init
    
    /// Initializes the ApplePayViewModel with the provided configuration and dependencies.
    ///
    /// - Parameters:
    ///   - applePayInfo: The Apple Pay configuration info, including the merchant identifier and billing address request flag.
    ///   - amount: The payment amount in cents.
    ///   - currency: The currency code.
    ///   - country: The country information.
    ///   - applePaymentHandler: The payment handler that manages the Apple Pay flow.
    ///   - delegate: The delegate to notify when the payment process finishes.
    init(
        applePayInfo: ApplePayInfo,
        amount: Int64,
        currency: String,
        country: Country?,
        applePaymentHandler: ApplePaymentHandlerType,
        delegate: ApplePayViewModelDelegate
    ) {
        self.applePayInfo = applePayInfo
        self.amount = amount
        self.currency = currency
        self.country = country
        self.applePaymentHandler = applePaymentHandler
        self.delegate = delegate
        super.init()
    }
    
    /// Creates an Apple Pay token payload from the given payment.
    ///
    /// - Parameters:
    ///   - payment: The authorized PKPayment from Apple Pay.
    ///   - requestBillingAddress: A Boolean flag indicating whether billing details should be added.
    /// - Returns: A `CreateTokenApplePayPayload` constructed from the payment data, or nil if creation fails.
    private func createApplePayTokenPayload(payment: PKPayment, requestBillingAddress: Bool) -> CreateTokenApplePayPayload? {
        let paymentDataString: String = String(data: payment.token.paymentData, encoding: .utf8) ?? ""
        
        var payload = CreateTokenApplePayPayload(
            tokenization: .init(
                method: "applepay",
                data: paymentDataString,
                merchantId: self.applePayInfo.merchantIdentifier,
                brand: payment.token.paymentMethod.network?.rawValue ?? ""
            )
        )
        
        if requestBillingAddress, let contact = payment.billingContact {
            payload.tokenization.addAddressDetails(
                billingName: contact.name?.fullname,
                billingCity: contact.postalAddress?.city,
                billingCountry: contact.postalAddress?.isoCountryCode,
                billingPostalCode: contact.postalAddress?.postalCode,
                billingState: contact.postalAddress?.state,
                billingStreet1: contact.postalAddress?.street,
                billingPhoneNumber: contact.phoneNumber?.stringValue)
        }
        
        return payload
    }
}

// MARK: - Input
extension ApplePayViewModel: ApplePayViewModelInput {
    
    /// Starts the Apple Pay payment process via the injected payment handler.
    ///
    /// Once a PKPayment is returned, it attempts to create the token payload.
    /// Depending on the outcome, it notifies the delegate with either a success (with the payload)
    /// or a failure (with an error). If no payment and no error are returned, the completion is simply called.
    ///
    /// - Parameter completion: A closure called after the payment process completes.
    func startPayment(completion: @escaping () -> Void) {
        // Convert the amount from cents to a decimal value (e.g., 999 becomes 9.99).
        let decimalAmount = currency == Currency.jpy.code
        ? NSDecimalNumber(value: amount)
        : NSDecimalNumber(value: amount).multiplying(by: 0.01)
        
        let request = applePaymentHandler.createPKPaymentRequest(with: decimalAmount,
                                                                 currency: currency,
                                                                 country: country,
                                                                 requiredBillingAddress: self.applePayInfo.requestBillingAddress,
                                                                 merchantId: self.applePayInfo.merchantIdentifier)
        let viewController = applePaymentHandler.createPaymentAuthViewController(from: request)
        applePaymentHandler.present(paymentController: viewController) { [weak self] payment, error in
            guard let self = self else { return }
            
            // If payment is dismissed with no data, simply complete without further action.
            if error == nil, payment == nil {
                completion()
                return
            }
            
            // If an error occurred during the Apple Pay flow, notify the delegate.
            if let error = error {
                self.delegate.didFinishApplePayWith(result: .failure(error), completion: completion)
                return
            }
            
            guard let payment = payment else {
                let noPaymentError = NSError(domain: "PaymentError",
                                             code: 2,
                                             userInfo: [NSLocalizedDescriptionKey: "No payment data returned from ApplePay"])
                self.delegate.didFinishApplePayWith(result: .failure(noPaymentError), completion: completion)
                return
            }
            
            if let tokenPayload = createApplePayTokenPayload(
                payment: payment,
                requestBillingAddress: self.applePayInfo.requestBillingAddress
            ) {
                self.delegate.didFinishApplePayWith(result: .success(tokenPayload), completion: completion)
            } else {
                let error = NSError(
                    domain: "CannotCreateApplePayTokenRequestError",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Apple Pay token request could not be created"]
                )
                self.delegate.didFinishApplePayWith(result: .failure(error), completion: completion)
            }
        }
    }
}

// MARK: - Output
extension ApplePayViewModel: ApplePayViewModelOutput {
    
    /// A Boolean value indicating whether Apple Pay is available on the current device.
    var canMakeApplePayPayment: Bool {
        ApplePaymentHandler.canMakeApplePayPayment
    }
}

private extension PersonNameComponents {
    
    /// Returns a full name constructed from the available name components.
    ///
    /// If any of the name components are missing, they are omitted from the result.
    var fullname: String {
        let prefix = namePrefix ?? ""
        let given = givenName ?? ""
        let middle = middleName ?? ""
        let family = familyName ?? ""
        let parts = [prefix, given, middle, family].filter { !$0.isEmpty }
        return parts.joined(separator: " ")
    }
}
