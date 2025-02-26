import PassKit

/// A type alias representing the result of an Apple Pay operation, with success carrying a
/// `CreateTokenApplePayPayload` and failure carrying an `Error`.
typealias OmiseApplePayResult = Result<CreateTokenApplePayPayload, Error>

/// A protocol that abstracts the essential functionality of a payment authorization controller.
/// This allows for dependency injection and mocking for unit tests, enabling easy testing of payment-related logic.
protocol PaymentAuthorizationControllerProtocol {
    /// The delegate responsible for handling payment authorization events.
    /// Must conform to `PKPaymentAuthorizationControllerDelegate` to receive events (e.g., payment success or cancellation).
    var delegate: PKPaymentAuthorizationControllerDelegate? { get set }
    
    /// Presents the Apple Pay sheet to the user.
    ///
    /// - Parameter completion: An optional closure called with a Boolean indicating whether the sheet was successfully presented.
    func presentSheet(completion: ((Bool) -> Void)?)
    
    /// Dismisses the Apple Pay sheet.
    ///
    /// - Parameter completion: An optional closure called once the sheet has been dismissed.
    func dismissSheet(completion: (() -> Void)?)
}

struct ApplePayInfo: Equatable {
    /// The merchant identifier used for Apple Pay transactions.
    let merchantIdentifier: String
    
    /// Indicates whether the billing address should be requested from the user.
    let requestBillingAddress: Bool
}

/// A protocol defining the interface for the Apple Pay view model, exposing input and output properties.
protocol ApplePayViewModelType {
    /// The input interface for triggering actions.
    var input: ApplePayViewModelInput { get }
    
    /// The output interface reflecting the view model's state.
    var output: ApplePayViewModelOutput { get }
}

/// A protocol defining the input actions for the Apple Pay view model.
protocol ApplePayViewModelInput {
    /// Starts the Apple Pay payment process.
    ///
    /// - Parameter completion: A closure called when the payment process is complete.
    func startPayment(completion: @escaping () -> Void)
}

/// A protocol defining the output properties for the Apple Pay view model.
protocol ApplePayViewModelOutput {
    /// A Boolean value indicating whether Apple Pay is available on the current device and configuration.
    var canMakeApplePayPayment: Bool { get }
}

/// A delegate protocol for handling the result of an Apple Pay payment operation.
/// Notifies the caller when the process finishes with either a success or failure result.
protocol ApplePayViewModelDelegate: AnyObject {
    /// Notifies the delegate that the Apple Pay process has finished.
    ///
    /// - Parameters:
    ///   - result: An `OmiseApplePayResult` representing either success (with a token payload) or failure.
    ///   - completion: A closure to call after the delegate has processed the result.
    func didFinishApplePayWith(result: OmiseApplePayResult, completion: @escaping () -> Void)
}

/// A protocol describing the minimal interface required from an Apple payment handler.
protocol ApplePaymentHandlerType {
    /// Creates a PKPaymentRequest configured with the provided parameters.
    ///
    /// - Parameters:
    ///   - amount: The total amount to be charged as an NSDecimalNumber.
    ///   - currency: The currency code (e.g., "USD").
    ///   - country: A Country object representing the country code.
    ///   - requiredBillingAddress: A Boolean indicating whether billing address details are required.
    ///   - merchantId: The merchant identifier registered for Apple Pay.
    /// - Returns: A configured PKPaymentRequest.
    func createPKPaymentRequest(
        with amount: NSDecimalNumber,
        currency: String,
        country: Country?,
        requiredBillingAddress: Bool,
        merchantId: String
    ) -> PKPaymentRequest
    
    /// Creates a payment authorization controller from a given payment request.
    ///
    /// - Parameter request: The PKPaymentRequest to use.
    /// - Returns: A new PKPaymentAuthorizationController.
    func createPaymentAuthViewController(from request: PKPaymentRequest) -> PKPaymentAuthorizationController
    
    /// Presents the Apple Pay sheet using the specified payment controller.
    ///
    /// - Parameters:
    ///   - controller: The payment authorization controller to present.
    ///   - completion: A closure called with either an authorized PKPayment on success or an Error on failure.
    func present(
        paymentController controller: PKPaymentAuthorizationController,
        completion: @escaping (PKPayment?, Error?) -> Void
    )
}
