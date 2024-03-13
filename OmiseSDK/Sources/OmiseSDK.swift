import Foundation
import UIKit

/// Omise Payment delegate protocol is required to process payment results
public protocol ChoosePaymentMethodDelegate: AnyObject {
    func choosePaymentMethodDidComplete(with source: Source)
    func choosePaymentMethodDidComplete(with token: Token)
    func choosePaymentMethodDidComplete(with error: Error)
    func choosePaymentMethodDidCancel()
}

/// Payment Results
public enum PaymentResult {
    /// Payment completed with Card payment and contains Token object
    case token(Token)
    /// Payment completed with Source payment and contains Source object
    case source(Source)
    /// Payment completed with Error
    case error(Error)
    /// Payment was cancelled by user
    case cancel
}

public class OmiseSDK {
    /// Static container that allows to assign a shared instance of OmiseSDK to be used as a Singleton object
    public static var shared = OmiseSDK(publicKey: "pkey_")

    /// OmiseSDK version
    public let version: String = "5.0.0"

    /// Public Key associated with this instance of OmiseSDK
    public let publicKey: String

    /// Client is used to communicate with Omise API
    public let client: Client

    /// Latest capability loaded with `client.capability()`
    var latestLoadedCapability: Capability? { client.latestLoadedCapability }

    /// Country associated with `latestLoadedCapability`
    var country: Country? {
        Country(code: latestLoadedCapability?.countryCode)
    }

    public private(set) weak var presentedViewController: UIViewController?

    /// Creates a new instance of Omise SDK that provides interface to functionallity that SDK provides
    ///
    /// - Parameters:
    ///    - publicKey: Omise public key
    ///    - configuration: Optional configuration is used for testing
    public init(publicKey: String, configuration: Configuration? = nil) {
        self.publicKey = publicKey
        self.client = Client(
            publicKey: publicKey,
            version: version,
            network: NetworkService(),
            apiURL: configuration?.apiURL,
            vaultURL: configuration?.vaultURL
        )

        preloadCapabilityAPI()
    }

    /// Creates and presents modal "Payment Methods" controller with a given parameters
    ///
    /// - Parameters:
    ///    - from: ViewController is used to present Choose Payment Methods
    ///    - animated: Presents controller with animation if `true`
    ///    - amount: Payment amount
    ///    - currency: Payment currency code  (ISO 4217)
    ///    - allowedPaymentMethods: Custom list of payment methods to be shown in the list. Only payment methods presented in the Capabilities will be shown
    ///    - forcePaymentMethods: If `true` all payment methods from `paymentMethods` will be shown if it's not empty (for test purposes)
    ///    - isCardPaymentAllowed: Should present Card Payment Method in the list
    ///    - handleErrors: If `true` the controller will show an error alerts in the UI, if `false` the controller will notify delegate
    ///    - completion: Completion handler triggered when payment completes with Token, Source, Error or was Cancelled
    public func presentChoosePaymentMethod(
        from topViewController: UIViewController,
        animated: Bool = true,
        amount: Int64,
        currency: String,
        allowedPaymentMethods: [SourceType] = [],
        forcePaymentMethods: Bool = false,
        isCardPaymentAllowed: Bool = true,
        handleErrors: Bool = true,
        delegate: ChoosePaymentMethodDelegate
    ) {
        dismiss(animated: false)

        let paymentFlow = ChoosePaymentCoordinator(
            client: client,
            amount: amount,
            currency: currency,
            currentCountry: country,
            handleErrors: handleErrors
        )

        let filter = SelectPaymentMethodViewModel.Filter(
            sourceTypes: allowedPaymentMethods,
            isCardPaymentAllowed: isCardPaymentAllowed,
            isForced: forcePaymentMethods
        )

        let viewController = paymentFlow.createChoosePaymentMethodController(
            filter: filter,
            delegate: delegate
        )

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.delegate = paymentFlow
        if #available(iOSApplicationExtension 11.0, *) {
            navigationController.navigationBar.prefersLargeTitles = true
        }

        topViewController.present(navigationController, animated: animated, completion: nil)
        presentedViewController = navigationController
    }

    /// Creates and presents modal "Credit Card Payment" controller with a given parameters
    ///
    /// - Parameters:
    ///    - from: ViewController is used to present Choose Payment Methods
    ///    - animated: Presents controller with animation if `true`
    ///    - countryCode: Country to be preselected in the form. If `nil` country from Capabilities will be used instead.
    ///    - handleErrors: If `true` the controller will show an error alerts in the UI, if `false` the controller will notify delegate
    ///    - delegate: Delegate to be notified when Source or Token is created
    public func presentCreditCardPayment(
        from topViewController: UIViewController,
        animated: Bool = true,
        countryCode: String? = nil,
        handleErrors: Bool = true,
        delegate: ChoosePaymentMethodDelegate
    ) {
        dismiss(animated: false)

        let paymentFlow = ChoosePaymentCoordinator(
            client: client,
            amount: 0,
            currency: "",
            currentCountry: Country(code: countryCode) ?? self.country,
            handleErrors: handleErrors
        )
        let viewController = paymentFlow.createCreditCardPaymentController(delegate: delegate)

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.delegate = paymentFlow
        if #available(iOSApplicationExtension 11.0, *) {
            navigationController.navigationBar.prefersLargeTitles = true
        }

        topViewController.present(navigationController, animated: animated, completion: nil)
        presentedViewController = navigationController
    }

    /// Creates and presents Authorizing Payment controller with a given parameters
    ///
    /// - Parameters:
    ///    - from: ViewController is used to present Choose Payment Methods
    ///    - animated: Presents controller with animation if `true`
    ///    - authorizeURL: The authorize URL given in `Charge` object
    ///    - expectedReturnURLPatterns: The expected return URL patterns.
    ///    - delegate: A delegate object that will recieved authorizing payment events.
    @available(iOSApplicationExtension, unavailable)
    public func presentAuthorizingPayment(
        from topViewController: UIViewController,
        animated: Bool = true,
        authorizeURL: URL,
        expectedReturnURLPatterns: [URLComponents],
        delegate: AuthorizingPaymentViewControllerDelegate
    ) {
        dismiss(animated: false)

        let viewController = AuthorizingPaymentViewController(nibName: nil, bundle: .omiseSDK)
        viewController.authorizeURL = authorizeURL
        viewController.expectedReturnURLPatterns = expectedReturnURLPatterns
        viewController.delegate = delegate
        viewController.applyNavigationBarStyle()

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.backgroundColor = .white

        if #available(iOSApplicationExtension 11.0, *) {
            navigationController.navigationBar.prefersLargeTitles = true
        }

        topViewController.present(navigationController, animated: animated, completion: nil)
        presentedViewController = navigationController
    }

    /// Dismiss any presented UI form by OmiseSDK
    public func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let presentedViewController = presentedViewController else { return }
        presentedViewController.dismiss(animated: animated, completion: completion)
    }
}

private extension OmiseSDK {
    private func preloadCapabilityAPI() {
        client.capability { _ in }
    }
}
