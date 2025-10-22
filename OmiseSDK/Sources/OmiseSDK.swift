import Foundation
import UIKit
import Flutter
import FlutterPluginRegistrant

// swiftlint:disable file_length
public class OmiseSDK {
    /// Static container that allows to assign a shared instance of OmiseSDK to be used as a Singleton object
    public static var shared = OmiseSDK(publicKey: "pkey_")
    
    /// OmiseSDK version
    public let version: String = "6.0.0-alpha.1"
    
    /// Public Key associated with this instance of OmiseSDK
    public private(set) var publicKey: String
    
    /// Client is used to communicate with Omise API
    public let client: ClientProtocol
    
    /// Latest capability loaded with `client.capability()`
    var latestLoadedCapability: Capability? { client.latestLoadedCapability }
    
    /// Country associated with `latestLoadedCapability`
    var country: Country? {
        Country(code: latestLoadedCapability?.countryCode)
    }
    
    private(set) var applePayInfo: ApplePayInfo?
    
    public private(set) weak var presentedViewController: UIViewController?
    
    private var expectedReturnURLStrings: [String] = []
    private var netceteraThreeDSController: NetceteraThreeDSController?
    private var passkeyHandler: PasskeyAuthenticationProtocol
    private var securePaymentEnabled: Bool = false
    
    internal var flutterEngineManager: FlutterEngineManager
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
        
        /// Setup the Flutter engine and custom engine manager for presenting and communicating with the Flutter SDK.
        ///
        /// This section initializes the Flutter engine, creates the method channel for communication between the
        /// native iOS SDK and Flutter, and sets up the custom handler for Flutter method calls. The manager is then
        /// initialized to coordinate the communication and manage the Flutter engine lifecycle.
        ///
        /// - Parameters:
        ///     - flutterEngine: The Flutter engine instance responsible for running the Flutter code.
        ///     - methodChannel: The method channel used to send and receive messages between native iOS and Flutter.
        ///     - channelHander: The custom handler for managing the method result communication callback from Flutter.
        ///     - publicKey: The public key used for Omise API, which is passed into the manager.
        let flutterEngine = FlutterEngine(name: OmiseFlutter.engineName)  // Initialize a new Flutter engine with a custom name
        flutterEngine.run()  // Start the Flutter engine to prepare it for communication
        GeneratedPluginRegistrant.register(with: flutterEngine)
        
        /// Create a Flutter method channel with a specified name
        /// Use the engine's binary messenger for communication
        let methodChannel = FlutterMethodChannel(name: OmiseFlutter.channelName,
                                                 binaryMessenger: flutterEngine.binaryMessenger)
        /// Instantiate the custom channel handler to handle communication via the method channel
        let channelHander = FlutterChannelHandlerImpl(channel: FlutterMethodChannelWrapper(channel: methodChannel))
        
        flutterEngineManager = FlutterEngineManagerImpl(
            flutterEngine: flutterEngine,
            methodChannel: methodChannel,
            channelHander: channelHander
        )
        
        self.passkeyHandler = SafariPasskeyAuthenticationHandler()
        
        preloadCapabilityAPI()
    }
    
    // Internal initializer for testing
    internal init(
        publicKey: String,
        configuration: Configuration? = nil,
        passkeyAuthenticationHandler: PasskeyAuthenticationProtocol
    ) {
        self.publicKey = publicKey
        self.client = Client(
            publicKey: publicKey,
            version: version,
            network: NetworkService(),
            apiURL: configuration?.apiURL,
            vaultURL: configuration?.vaultURL
        )
        self.passkeyHandler = passkeyAuthenticationHandler
        
        // flutter
        let flutterEngine = FlutterEngine(name: OmiseFlutter.engineName)  // Initialize a new Flutter engine with a custom name
        flutterEngine.run()  // Start the Flutter engine to prepare it for communication
        GeneratedPluginRegistrant.register(with: flutterEngine)
        
        /// Create a Flutter method channel with a specified name
        /// Use the engine's binary messenger for communication
        let methodChannel = FlutterMethodChannel(name: OmiseFlutter.channelName,
                                                 binaryMessenger: flutterEngine.binaryMessenger)
        /// Instantiate the custom channel handler to handle communication via the method channel
        let channelHander = FlutterChannelHandlerImpl(channel: FlutterMethodChannelWrapper(channel: methodChannel))
        
        flutterEngineManager = FlutterEngineManagerImpl(
            flutterEngine: flutterEngine,
            methodChannel: methodChannel,
            channelHander: channelHander
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
    ///    - collect3DSData: either none, phone, email or all, default is none. this will render email and/or phone fields in credit card form to support 3DS and PASSKEY auth
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
        collect3DSData: Required3DSData = .none,
        delegate: ChoosePaymentMethodDelegate
    ) {
        dismiss(animated: false)
        
        /// replace flutter screen with existing flow.
        /// however, this doesn't have the filter functions :allowed payment method, card ayment
        /// we will integrate that later when Flutter module supports the funciton.
        /// flutter module doesn't support this flag: handleErrors: Bool
        
        let paymentMethod: [String] = allowedPaymentMethods?.compactMap { $0.rawValue } ?? []
        let tokenizationMethod: [String] = allowedPaymentMethods?.filter { $0 == .applePay }.compactMap { $0.rawValue } ?? []
        
        let args = self.buildPaymentArguments(publicKey: publicKey,
                                              amount: amount,
                                              currency: currency,
                                              paymentMethods: paymentMethod,
                                              tokenizationMethods: tokenizationMethod,
                                              merchantId: applePayInfo?.merchantIdentifier,
                                              requestBillingAddress: applePayInfo?.requestBillingAddress ?? false,
                                              collect3DSData: collect3DSData
        )
        
        flutterEngineManager.presentFlutterViewController(for: .selectPaymentMethod,
                                                          on: topViewController,
                                                          arguments: args,
                                                          delegate: delegate)
    }
    
    /// Creates and presents modal "Credit Card Payment" controller with a given parameters
    ///
    /// - Parameters:
    ///    - from: ViewController is used to present Choose Payment Methods
    ///    - animated: Presents controller with animation if `true`
    ///    - countryCode: Country to be preselected in the form. If `nil` country from Capabilities will be used instead.
    ///    - handleErrors: If `true` the controller will show an error alerts in the UI, if `false` the controller will notify delegate
    ///    - collect3DSData: either none, phone, email or all, default is none. this will render email and/or phone fields in credit card form to support 3DS and PASSKEY auth
    ///    - delegate: Delegate to be notified when Source or Token is created
    public func presentCreditCardPayment(
        from topViewController: UIViewController,
        animated: Bool = true,
        countryCode: String? = nil,
        handleErrors: Bool = true,
        collect3DSData: Required3DSData = .none,
        delegate: ChoosePaymentMethodDelegate
    ) {
        dismiss(animated: false)
        let args: [String: Any] = buildBasicArgument(with: publicKey, collect3DSData: collect3DSData)
        flutterEngineManager.presentFlutterViewController(for: .openCardPage,
                                                          on: topViewController,
                                                          arguments: args,
                                                          delegate: delegate)
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
        // Passkey
        if passkeyHandler.shouldHandlePasskey(authorizeURL) {
            passkeyHandler.presentPasskeyAuthentication(
                from: topViewController,
                authorizeURL: authorizeURL,
                expectedReturnURLStrings: expectedReturnURLStrings,
                delegate: delegate
            )
            return
        }
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
            in: topViewController
        ) { [weak self] result in
            switch result {
            case .success:
                delegate.authorizingPaymentDidComplete(with: nil)
            case .failure(let error):
                switch error {
                case NetceteraThreeDSController.Errors.incomplete,
                    NetceteraThreeDSController.Errors.cancelled,
                    NetceteraThreeDSController.Errors.timedout,
                    NetceteraThreeDSController.Errors.authResStatusFailed,
                    NetceteraThreeDSController.Errors.authResStatusUnknown:
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
    /// Clear Flutter Screen
    public func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        // Clean up Safari passkey authentication if active
        if let handler = passkeyHandler as? SafariPasskeyAuthenticationHandler {
            handler.dismiss(animated: animated, completion: completion)
        }
        
        flutterEngineManager.detachFlutterViewController(animated: animated)
        
        guard let presentedViewController = presentedViewController else {
            completion?()
            return
        }
        presentedViewController.dismiss(animated: animated, completion: completion)
    }
    
    /// Handle URL Callback received by AppDelegate
    public func handleURLCallback(_ url: URL) -> Bool {
        // First try passkey authentication handler
        if passkeyHandler.handlePasskeyCallback(url) {
            return true
        }
        
        // Will handle callback with 3ds library
        let containsURL = expectedReturnURLStrings
            .map {
                url.match(string: $0)
            }
            .contains(true)
        
        return containsURL
    }
    
    /// Enables or disables secure payment presentation behavior such as preventing screenshots in supported flows.
    /// - Parameter isEnabled: Pass `true` to enable secure payment mode for subsequent presentation calls.
    public func setupSecurePayment(isEnabled: Bool) {
        securePaymentEnabled = isEnabled
    }
    
    public func setupApplePay(for merchantId: String, requiredBillingAddress: Bool = false) {
        self.applePayInfo = ApplePayInfo(merchantIdentifier: merchantId,
                                         requestBillingAddress: requiredBillingAddress)
    }
    
    public func updatePublicKey(key: String) {
        self.publicKey = key
        self.client.updatePublicKey(key)
        self.preloadCapabilityAPI()
    }
}

private extension OmiseSDK {
    private func preloadCapabilityAPI() {
        client.capability { _ in
            // Preload capability and auto cache it as client.latestLoadedCapability
        }
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

// MARK: - Flutter Bridge
extension OmiseSDK {
    func buildPaymentArguments(
        publicKey: String,
        amount: Int64,
        currency: String,
        paymentMethods: [String]? = nil,
        tokenizationMethods: [String]? = nil,
        authorizationURL: String? = nil,
        returnURLs: [String]? = nil,
        merchantId: String? = nil,
        requestBillingAddress: Bool,
        collect3DSData: Required3DSData = .none,
        atomeItems: [[String: Any]]? = nil
    ) -> [String: Any] {
        var arguments = buildBasicArgument(with: publicKey, collect3DSData: collect3DSData)
        
        arguments["amount"] = amount
        arguments["currency"] = currency
        
        // Add optional parameters only if they're provided
        if let paymentMethods = paymentMethods, !paymentMethods.isEmpty {
            arguments["selectedPaymentMethods"] = paymentMethods
        }
        
        if let tokenizationMethods = tokenizationMethods, !tokenizationMethods.isEmpty {
            arguments["selectedTokenizationMethods"] = tokenizationMethods
        }
        
        if let merchantId = merchantId {
            arguments["applePayMerchantId"] = merchantId
            arguments["applePayCardBrands"] = ["visa", "amex", "discover", "masterCard", "JCB", "chinaUnionPay"]
        }
        
        if requestBillingAddress {
            arguments["applePayRequiredBillingContactFields"] = ["emailAddress", "name", "phoneNumber", "postalAddress"]
        }
        
        return arguments
    }
    
    func buildBasicArgument(
        with pkey: String,
        collect3DSData: Required3DSData
    ) -> [String: Any] {
        var arguments: [String: Any] = [
            "pkey": pkey,
            "securePaymentFlag": securePaymentEnabled
        ]
        if let cardHolderData = collect3DSData.parsedArgument {
            arguments["cardHolderData"] = cardHolderData
        }
        return arguments
    }
}

// swiftlint:enable file_length
