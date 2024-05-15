import Foundation
import UIKit

public class OmiseSDK {
    /// Static container that allows to assign a shared instance of OmiseSDK to be used as a Singleton object
    public static var shared = OmiseSDK(publicKey: "pkey_")

    /// OmiseSDK version
    public let version: String = "5.0.0"

    /// Public Key associated with this instance of OmiseSDK
    public let publicKey: String

    /// Client is used to communicate with Omise API
    public let client: ClientProtocol

    /// Latest capability loaded with `client.capability()`
    var latestLoadedCapability: Capability? { client.latestLoadedCapability }

    /// Country associated with `latestLoadedCapability`
    var country: Country? {
        Country(code: latestLoadedCapability?.countryCode)
    }

    public private(set) weak var presentedViewController: UIViewController?

    private var expectedReturnURLStrings: [String] = []
    private var netceteraThreeDSController: NetceteraThreeDSController?

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
    ///    - allowedPaymentMethods: Payment methods to be presented in the list
    ///    - skipCapabilityValidation: Set `false` to filter payment methods presented in Capability (default), `true` to skip validation (for testing)
    ///    - isCardPaymentAllowed: Should present Card Payment Method in the list
    ///    - handleErrors: If `true` the controller will show an error alerts in the UI, if `false` the controller will notify delegate
    ///    - completion: Completion handler triggered when payment completes with Token, Source, Error or was Cancelled
    public func presentChoosePaymentMethod(
        from topViewController: UIViewController,
        animated: Bool = true,
        amount: Int64,
        currency: String,
        allowedPaymentMethods: [SourceType]? = nil,
        skipCapabilityValidation: Bool = false,
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
            sourceTypes: allowedPaymentMethods ?? [],
            isCardPaymentAllowed: isCardPaymentAllowed,
            isForced: skipCapabilityValidation
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
            navigationController.navigationBar.prefersLargeTitles = false
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
    ///    - expectedReturnURLStrings: The expected return URL patterns for web view 3DS.
    ///    - threeDSRequestorAppURLString: 3DS requestor app URL string (deeplink).
    ///    - delegate: A delegate object that will recieved authorizing payment events.
    @available(iOSApplicationExtension, unavailable)
    public func presentAuthorizingPayment(
        from topViewController: UIViewController,
        animated: Bool = true,
        authorizeURL: URL,
        expectedReturnURLStrings: [String],
        threeDSRequestorAppURLString: String,
        threeDSUICustomization: ThreeDSUICustomization? = nil,
        delegate: AuthorizingPaymentDelegate
    ) {
        guard authorizeURL.absoluteString.contains("acs=true") else {
            presentWebViewAuthorizingPayment(
                from: topViewController,
                animated: animated,
                authorizeURL: authorizeURL,
                expectedReturnURLStrings: expectedReturnURLStrings,
                delegate: delegate
            )
            return
        }

        netceteraThreeDSController = NetceteraThreeDSController()
        netceteraThreeDSController?.processAuthorizedURL(
            authorizeURL,
            threeDSRequestorAppURL: threeDSRequestorAppURLString,
            uiCustomization: threeDSUICustomization,
            in: topViewController) { [weak self] result in
                switch result {
                case .success:
                    delegate.authorizingPaymentDidComplete(with: nil)
                case .failure(let error):
                    typealias NetceteraFlowError = NetceteraThreeDSController.Errors
                    switch error {
                    case NetceteraFlowError.incomplete,
                        NetceteraFlowError.cancelled,
                        NetceteraFlowError.timedout,
                        NetceteraFlowError.authResStatusFailed,
                        NetceteraFlowError.authResStatusUnknown:
                        delegate.authorizingPaymentDidCancel()
                    default:
                        DispatchQueue.main.async {
                            self?.presentWebViewAuthorizingPayment(
                                from: topViewController,
                                animated: animated,
                                authorizeURL: authorizeURL,
                                expectedReturnURLStrings: expectedReturnURLStrings,
                                delegate: delegate
                            )
                        }
                    }
                }
        }
    }

    /// Dismiss any presented UI form by OmiseSDK
    public func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let presentedViewController = presentedViewController else { return }
        presentedViewController.dismiss(animated: animated, completion: completion)
    }

    /// Handle URL Callback received by AppDelegate
    public func handleURLCallback(_ url: URL) -> Bool {
        // Will handle callback with 3ds library
        let containsURL = expectedReturnURLStrings
            .map {
                url.match(string: $0)
            }
            .contains(true)

        return containsURL
    }
}

private extension OmiseSDK {
    private func preloadCapabilityAPI() {
        client.capability { _ in }
    }
}

private extension OmiseSDK {
    @available(iOSApplicationExtension, unavailable)
    func presentWebViewAuthorizingPayment(
        from topViewController: UIViewController,
        animated: Bool = true,
        authorizeURL: URL,
        expectedReturnURLStrings: [String],
        delegate: AuthorizingPaymentDelegate
    ) {
        dismiss(animated: false)

        let viewController = AuthorizingPaymentWebViewController(nibName: nil, bundle: .omiseSDK)
        viewController.authorizeURL = authorizeURL
        viewController.expectedReturnURLStrings = expectedReturnURLStrings.compactMap {
            URLComponents(string: $0)
        }
        viewController.completion = { [weak delegate] result in
            switch result {
            case .cancel:
                delegate?.authorizingPaymentDidCancel()
            case .complete(let redirectedURL):
                delegate?.authorizingPaymentDidComplete(with: redirectedURL)
            }
        }

        viewController.applyNavigationBarStyle()
        viewController.title = "AuthorizingPayment.title".localized()

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.backgroundColor = .white

        if #available(iOSApplicationExtension 11.0, *) {
            navigationController.navigationBar.prefersLargeTitles = false
        }

        topViewController.present(navigationController, animated: animated, completion: nil)
        presentedViewController = navigationController

        self.expectedReturnURLStrings = expectedReturnURLStrings
    }
}
