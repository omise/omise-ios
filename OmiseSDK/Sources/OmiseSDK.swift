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

    /// If it's `true` SDK will handle errors and will not notify ChoosePaymentMethodDelegate
    public let handleErrors: Bool

    /// Latest capability loaded with `client.capability()`
    var latestLoadedCapability: Capability? { client.latestLoadedCapability }

    /// Country associated with `latestLoadedCapability`
    var country: Country? {
        Country(code: latestLoadedCapability?.countryCode)
    }

    /// Creates a new instance of Omise SDK that provides interface to functionallity that SDK provides
    ///
    /// - Parameters:
    ///    - publicKey: Omise public key
    ///    - configuration: Optional configuration is used for testing
    public init(publicKey: String, handleErrors: Bool = true, configuration: Configuration? = nil) {
        self.publicKey = publicKey
        self.handleErrors = handleErrors
        self.client = Client(
            publicKey: publicKey,
            version: version,
            network: NetworkService(),
            apiURL: configuration?.apiURL,
            vaultURL: configuration?.vaultURL
        )

        let color = UIColor(red: 0.26, green: 0.27, blue: 0.28, alpha: 0.5)
        print(color.hexString)
        client.capability { _ in }
    }

    /// Creates a Payment controller with given payment methods details comes in UINavigationController stack
    ///
    /// - Parameters:
    ///    - amount: Payment amount
    ///    - currency: Payment currency code
    ///    - allowedPaymentMethods: Custom list of payment methods to be shown in the list. If value is nill then SDK will load list from Capability API
    ///    - allowedCardPayment: Should present Card Payment Method in the list
    ///    - completion: Completion handler triggered when payment completes with Token, Source, Error or was Cancelled
    public func choosePaymentMethodController(
        amount: Int64,
        currency: String,
        allowedPaymentMethods: [SourceType],
        allowedCardPayment: Bool,
        delegate: ChoosePaymentMethodDelegate
    ) -> UINavigationController {
        let paymentFlow = ChoosePaymentCoordinator(
            client: client,
            amount: amount,
            currency: currency,
            currentCountry: country,
            handleErrors: handleErrors
        )
        let viewController = paymentFlow.createChoosePaymentMethodController(
            allowedPaymentMethods: allowedPaymentMethods,
            allowedCardPayment: allowedCardPayment,
            usePaymentMethodsFromCapability: false,
            delegate: delegate
        )

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.delegate = paymentFlow
        return navigationController
    }

    /// Creates a Payment controller with payment methods loaded from Capability API comes in UINavigationController stack
    ///
    /// - Parameters:
    ///    - from: ViewController is used as a base to present UINavigationController
    ///    - allowedPaymentMethods: Custom list of payment methods to be shown in the list. If value is nill then SDK will load list from Capability API
    ///    - allowedCardPayment: Should present Card Payment Method in the list
    ///    - delegate: Delegate to be notified when Source or Token is created
    public func choosePaymentMethodFromCapabilityController(
        amount: Int64,
        currency: String,
        delegate: ChoosePaymentMethodDelegate
    ) -> UINavigationController {
        let paymentFlow = ChoosePaymentCoordinator(
            client: client,
            amount: amount,
            currency: currency,
            currentCountry: country,
            handleErrors: handleErrors
        )
        let viewController = paymentFlow.createChoosePaymentMethodController(
            usePaymentMethodsFromCapability: true,
            delegate: delegate
        )

        let navigationController = UINavigationController(rootViewController: viewController)
        if #available(iOSApplicationExtension 11.0, *) {
            navigationController.navigationBar.prefersLargeTitles = true
        }

        navigationController.delegate = paymentFlow
        return navigationController
    }

    /// Creates a Credit Card Controller comes in UINavigationController stack
    ///
    /// - Parameters:
    ///    - delegate: Delegate to be notified when Source or Token is created
    public func creditCardController(delegate: ChoosePaymentMethodDelegate) -> UINavigationController {
        let paymentFlow = ChoosePaymentCoordinator(
            client: client,
            amount: 0,
            currency: "",
            currentCountry: country,
            handleErrors: handleErrors
        )
        let viewController = paymentFlow.createCreditCardPaymentController(delegate: delegate)

        let navigationController = UINavigationController(rootViewController: viewController)
        if #available(iOSApplicationExtension 11.0, *) {
            navigationController.navigationBar.prefersLargeTitles = true
        }

        navigationController.delegate = paymentFlow
        return navigationController
    }

    /// Creates a authorizing payment view controller comes in UINavigationController stack.
    ///
    /// - parameter authorizedURL: The authorized URL given in `Charge` object that will be set to `OmiseAuthorizingPaymentViewController`
    /// - parameter expectedReturnURLPatterns: The expected return URL patterns.
    /// - parameter delegate: A delegate object that will recieved authorizing payment events.
    ///
    /// - returns: A UINavigationController with `OmiseAuthorizingPaymentViewController` as its root view controller
    public func authorizedController(
        authorizedURL: URL,
        expectedReturnURLPatterns: [URLComponents],
        delegate: AuthorizingPaymentViewControllerDelegate
    ) -> UINavigationController {
        let viewController = AuthorizingPaymentViewController(nibName: nil, bundle: .omiseSDK)
        viewController.authorizedURL = authorizedURL
        viewController.expectedReturnURLPatterns = expectedReturnURLPatterns
        viewController.delegate = delegate
        viewController.applyNavigationBarStyle()

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.backgroundColor = .white

        if #available(iOSApplicationExtension 11.0, *) {
            navigationController.navigationBar.prefersLargeTitles = true
        }

        return navigationController
    }
}

private extension OmiseSDK {
    private func preloadCapabilityAPI() {
        client.capability { _ in }
    }
}
