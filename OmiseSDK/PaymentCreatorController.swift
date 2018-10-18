import UIKit
import os



public protocol PaymentCreatorControllerDelegate: NSObjectProtocol {
    func paymentCreatorController(_ paymentCreatorController: PaymentCreatorController,
                                  didCreatePayment payment: Payment)
    func paymentCreatorController(_ paymentCreatorController: PaymentCreatorController,
                                  didFailWithError error: Error)
    func paymentCreatorControllerDidCancel(_ paymentCreatorController: PaymentCreatorController)
}


@objc public protocol OMSPaymentCreatorControllerDelegate: NSObjectProtocol {
    @objc func paymentCreatorController(_ paymentCreatorController: PaymentCreatorController,
                                  didCreateToken token: __OmiseToken)
    @objc func paymentCreatorController(_ paymentCreatorController: PaymentCreatorController,
                                  didCreateSource source: __OmiseSource)
    @objc func paymentCreatorController(_ paymentCreatorController: PaymentCreatorController,
                                  didFailWithError error: Error)
    @objc optional func paymentCreatorControllerDidCancel(_ paymentCreatorController: PaymentCreatorController)
}


public enum Payment {
    case token(Token)
    case source(Source)
}

public protocol PaymentChooserUI: AnyObject {
    var preferredPrimaryColor: UIColor? { get set }
    var preferredSecondaryColor: UIColor? { get set }
}


/// Drop-in UI flow controller that let user choose the payment method with the given payment options
@objc(OMSPaymentCreatorController)
public class PaymentCreatorController : UINavigationController {
    /// Omise public key for calling tokenization API.
    @objc public var publicKey: String? {
        didSet {
            guard let publicKey = publicKey else {
                  if #available(iOS 10.0, *) {
                    os_log("Missing or invalid public key information - %{private}@", log: uiLogObject, type: .error, self.publicKey ?? "")
                }
                assertionFailure("Missing public key information. Please set the public key before request token.")
                return
            }
            
            self.client = Client(publicKey: publicKey)
        }
    }
    
    /// Amount to create a Source payment
    public var paymentAmount: Int64? {
        didSet {
            paymentSourceCreatorFlowSession.paymentAmount = paymentAmount
        }
    }
    /// Currency to create a Source payment
    public var paymentCurrency: Currency? {
        didSet {
            paymentSourceCreatorFlowSession.paymentCurrency = paymentCurrency
        }
    }
    
    /// Amount to create a Source payment
    @objc(paymentAmount) public var __paymentAmount: Int64 {
        get {
            return paymentAmount ?? 0
        }
        set {
            paymentAmount = newValue > 0 ? Int64(newValue) : nil
        }
    }
    
    /// Currency to create a Source payment
    @objc(paymentCurrencyCode) public var __paymentCurrencyCode: String? {
        get {
            return paymentCurrency?.code
        }
        set {
            paymentCurrency = newValue.map(Currency.init(code:))
        }
    }
    
    /// Boolean indicates that the form should show the Credit Card payment option or not
    @objc public var showsCreditCardPayment: Bool = true {
        didSet {
            paymentChooserViewController.showsCreditCardPayment = showsCreditCardPayment
        }
    }
    
    /// Available Source payment options to let user to choose.
    /// The default value is the default available payment method for merchant in Thailand
    @objc public var allowedPaymentMethods: [OMSSourceTypeValue] = PaymentCreatorController.thailandDefaultAvailableSourceMethods {
        didSet {
            paymentChooserViewController.allowedPaymentMethods = allowedPaymentMethods
        }
    }
 
        /// A boolean flag to enables or disables automatic error handling.
    ///
    /// The controller will show an error alert in the UI if the value is true,
    /// otherwise the controller will ask its delegate.
    /// Defaults to `true`.
    @objc public var handleErrors: Bool = true
    
    /// Delegate to receive CreditCardFormController result.
    public weak var paymentDelegate: PaymentCreatorControllerDelegate?
    /// Delegate to receive CreditCardFormController result.
    @objc(paymentDelegate) public weak var __paymentDelegate: OMSPaymentCreatorControllerDelegate?

    var client: Client? {
        didSet {
            paymentSourceCreatorFlowSession.client = client
        }
    }
    
    private let paymentSourceCreatorFlowSession = PaymentCreatorFlowSession()
    
    private var paymentChooserViewController: PaymentChooserViewController {
        return topViewController as! PaymentChooserViewController
    }
    
    private var noticeViewHeightConstraint: NSLayoutConstraint!
    private let displayingNoticeView: NoticeView = {
        let bundle = Bundle.omiseSDKBundle
        let noticeViewNib = UINib(nibName: "NoticeView", bundle: bundle)
        let noticeView = noticeViewNib.instantiate(withOwner: nil, options: nil).first as! NoticeView
        noticeView.translatesAutoresizingMaskIntoConstraints = false
        return noticeView
    }()
    
    
    @objc @IBInspectable public var preferredPrimaryColor: UIColor?
    @objc @IBInspectable public var preferredSecondaryColor: UIColor?

    /// Factory method for creating CreditCardFormController with given public key.
    /// - parameter publicKey: Omise public key.
    public static func makePaymentCreatorControllerWith(
        publicKey: String, amount: Int64, currency: Currency,
        allowedPaymentMethods: [OMSSourceTypeValue],
        paymentDelegate: PaymentCreatorControllerDelegate?) -> PaymentCreatorController {
        let omiseBundle = Bundle(for: self)
        let storyboard = UIStoryboard(name: "OmiseSDK", bundle: omiseBundle)
        let paymentCreatorController = storyboard.instantiateViewController(withIdentifier: "PaymentCreatorController") as! PaymentCreatorController
        paymentCreatorController.publicKey = publicKey
        paymentCreatorController.paymentAmount = amount
        paymentCreatorController.paymentCurrency = currency
        paymentCreatorController.allowedPaymentMethods = allowedPaymentMethods
        paymentCreatorController.paymentDelegate = paymentDelegate
        
        return paymentCreatorController
    }
    
    /// Factory method for creating CreditCardFormController with given public key.
    /// - parameter publicKey: Omise public key.
    @objc(paymentCreatorControllerWithPublicKey:amount:currency:allowedPaymentMethods:paymentDelegate:)
    public static func __makePaymentCreatorViewControllerWith(
        publicKey: String, amount: Int64, currencyCode: String,
        allowedPaymentMethods: [OMSSourceTypeValue],
        paymentDelegate: OMSPaymentCreatorControllerDelegate) -> PaymentCreatorController {
        let controller = PaymentCreatorController.makePaymentCreatorControllerWith(
            publicKey: publicKey, amount: amount, currency: Currency(code: currencyCode),
            allowedPaymentMethods: allowedPaymentMethods,
            paymentDelegate: nil)
        controller.__paymentDelegate = paymentDelegate
        return controller
    }

    public init() {
        let storyboard = UIStoryboard(name: "OmiseSDK", bundle: Bundle.omiseSDKBundle)
        let viewController = storyboard.instantiateViewController(withIdentifier: "PaymentChooserController")
        
        guard let paymentChooserViewController = viewController as? PaymentChooserViewController else {
            preconditionFailure("This Payment Creator doesn't allow the root view controller to be other class than the PaymentChooserViewcontroller")
        }
        
        super.init(rootViewController: paymentChooserViewController)
        
        initializeWithPaymentChooserViewController(paymentChooserViewController)
    }
    
    @available(iOS, unavailable)
    public override init(rootViewController: UIViewController) {
        guard let rootViewController = rootViewController as? PaymentChooserViewController else {
            preconditionFailure("This Payment Creator doesn't allow the root view controller to be other class than the PaymentChooserViewcontroller")
        }
        super.init(rootViewController: rootViewController)

        initializeWithPaymentChooserViewController(rootViewController)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        guard let rootViewController = topViewController as? PaymentChooserViewController else {
            preconditionFailure("This Payment Creator doesn't allow the root view controller to be other class than the PaymentChooserViewcontroller")
            return nil
        }
        initializeWithPaymentChooserViewController(rootViewController)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        guard let rootViewController = topViewController as? PaymentChooserViewController else {
            preconditionFailure("This Payment Creator doesn't allow the root view controller to be other class than the PaymentChooserViewcontroller")
        }
        initializeWithPaymentChooserViewController(rootViewController)
    }
    
    public override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        
        guard let rootViewController = topViewController as? PaymentChooserViewController else {
            preconditionFailure("This Payment Creator doesn't allow the root view controller to be other class than the PaymentChooserViewcontroller")
        }
        initializeWithPaymentChooserViewController(rootViewController)
    }
    
    public override var viewControllers: [UIViewController] {
        willSet {
            if !(viewControllers.first is PaymentChooserViewController) {
                preconditionFailure("This Payment Creator doesn't allow the root view controller to be other class than the PaymentChooserViewcontroller")
            }
        }
    }
    
    private func initializeWithPaymentChooserViewController(_ viewController: PaymentChooserViewController) {
        viewController.preferredPrimaryColor = preferredPrimaryColor
        viewController.preferredSecondaryColor = preferredSecondaryColor
        
        viewController.flowSession = paymentSourceCreatorFlowSession
        viewController.allowedPaymentMethods = allowedPaymentMethods
        viewController.showsCreditCardPayment = showsCreditCardPayment
        
        paymentSourceCreatorFlowSession.delegate = self
        
        if #available(iOS 9.0, *) {
            noticeViewHeightConstraint = displayingNoticeView.heightAnchor.constraint(equalToConstant: 0)
        } else {
            noticeViewHeightConstraint = NSLayoutConstraint(
                item: displayingNoticeView, attribute: .height, relatedBy: .equal,
                toItem: nil, attribute: .notAnAttribute,
                multiplier: 1.0, constant: 0
            )
        }
        noticeViewHeightConstraint.isActive = true
        
        let dismissErrorBannerTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissErrorMessageBanner(_:)))
        displayingNoticeView.addGestureRecognizer(dismissErrorBannerTapGestureRecognizer)
    }
    
    
    /// Displays an error banner at the top of the UI with the given error message.
    ///
    /// - Parameters:
    ///   - message: Message to be displayed in the banner
    ///   - animated: Pass true to animate the presentation; otherwise, pass false
    ///   - sender: The object that initiated the request
    public override func displayErrorMessage(_ message: String, animated: Bool, sender: Any?) {
        displayingNoticeView.detailLabel.text = message
        view.insertSubview(self.displayingNoticeView, belowSubview: navigationBar)
        
        if #available(iOS 9.0, *) {
            NSLayoutConstraint.activate([
                displayingNoticeView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
                displayingNoticeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                displayingNoticeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                ])
        } else {
            let views = ["displayingNoticeView": displayingNoticeView] as [String: UIView]
            let constraints = NSLayoutConstraint.constraints(withVisualFormat: "|[displayingNoticeView]|", options: [], metrics: nil, views: views) +
                [ NSLayoutConstraint(item: displayingNoticeView, attribute: .top, relatedBy: .equal, toItem: navigationBar, attribute: .bottom, multiplier: 1.0, constant: 0)]
            view.addConstraints(constraints)
        }
        
        noticeViewHeightConstraint.isActive = true
        view.layoutIfNeeded()
        
        let animationBlock = {
            self.noticeViewHeightConstraint.isActive = false
            self.view.layoutIfNeeded()
            if #available(iOS 11, *) {
                self.additionalSafeAreaInsets.top = self.displayingNoticeView.bounds.height
            }
        }
        
        if animated {
            UIView.animate(withDuration: TimeInterval(NavigationControllerHideShowBarDuration) + 0.07, delay: 0.0, options: [.layoutSubviews], animations: animationBlock)
        } else {
            animationBlock()
        }
    }
    
    override func dismissErrorMessage(animated: Bool, sender: Any?) {
        guard self.displayingNoticeView.superview != nil else {
            return
        }
        
        let animationBlock = {
            self.noticeViewHeightConstraint.isActive = true
            self.view.layoutIfNeeded()
            if #available(iOS 11, *) {
                self.additionalSafeAreaInsets.top = 0
            }
        }
        
        if animated {
            UIView.animate(
                withDuration: TimeInterval(NavigationControllerHideShowBarDuration), delay: 0.0,
                options: [.layoutSubviews], animations: animationBlock,
                completion: { _ in
                    self.displayingNoticeView.removeFromSuperview()
            })
        } else {
            animationBlock()
            self.displayingNoticeView.removeFromSuperview()
        }
    }
    
    
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if let viewController = viewController as? PaymentChooserUI {
            viewController.preferredPrimaryColor = preferredPrimaryColor
            viewController.preferredSecondaryColor = preferredSecondaryColor
        }
        if let viewController = viewController as? PaymentChooserViewController {
            viewController.flowSession = self.paymentSourceCreatorFlowSession
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    #if swift(>=4.2)
    public override func addChild(_ childController: UIViewController) {
        if let viewController = childController as? PaymentChooserUI {
            viewController.preferredPrimaryColor = preferredPrimaryColor
            viewController.preferredSecondaryColor = preferredSecondaryColor
        }
        if let viewController = childController as? PaymentChooserViewController {
            viewController.flowSession = self.paymentSourceCreatorFlowSession
        }
        super.addChild(childController)
    }
    #else
    public override func addChildViewController(_ childController: UIViewController) {
        if let viewController = childController as? PaymentChooserUI {
            viewController.preferredPrimaryColor = preferredPrimaryColor
            viewController.preferredSecondaryColor = preferredSecondaryColor
        }
            if let viewController = childController as? PaymentChooserViewController {
            viewController.flowSession = self.paymentSourceCreatorFlowSession
        }
        super.addChildViewController(childController)
    }
    #endif
    
    public override func loadView() {
        super.loadView()
        view.backgroundColor = .white
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if #available(iOS 11, *), self.displayingNoticeView.superview != nil {
            coordinator.animate(alongsideTransition: { (context) in
                self.additionalSafeAreaInsets.top = self.displayingNoticeView.bounds.height
            }, completion: nil)
        }
    }
    
    
    @objc func dismissErrorMessageBanner(_ sender: AnyObject) {
        dismissErrorMessage(animated: true, sender: sender)
    }
}


extension PaymentCreatorController : PaymentCreatorFlowSessionDelegate {
    func paymentCreatorFlowSessionWillCreateSource(_ paymentSourceCreatorFlowSession: PaymentCreatorFlowSession) {
        dismissErrorMessage(animated: true, sender: self)
    }
    
    func paymentCreatorFlowSession(_ paymentSourceCreatorFlowSession: PaymentCreatorFlowSession, didCreateToken token: Token) {
        if let paymentDelegate = self.paymentDelegate {
            paymentDelegate.paymentCreatorController(self, didCreatePayment: Payment.token(token))
        } else if let paymentDelegate = self.__paymentDelegate {
            paymentDelegate.paymentCreatorController(self, didCreateToken: __OmiseToken(token: token))
        }
    }
    
    func paymentCreatorFlowSession(_ paymentSourceCreatorFlowSession: PaymentCreatorFlowSession, didCreatedSource source: Source) {
        if let paymentDelegate = self.paymentDelegate {
            paymentDelegate.paymentCreatorController(self, didCreatePayment: Payment.source(source))
        } else if let paymentDelegate = self.__paymentDelegate {
            paymentDelegate.paymentCreatorController(self, didCreateSource: __OmiseSource(source: source))
        }
    }
    
    func paymentCreatorFlowSession(_ paymentSourceCreatorFlowSession: PaymentCreatorFlowSession, didFailWithError error: Error) {
        if !handleErrors {
            if let paymentDelegate = self.paymentDelegate {
                paymentDelegate.paymentCreatorController(self, didFailWithError: error)
            } else if let paymentDelegate = self.__paymentDelegate {
                paymentDelegate.paymentCreatorController(self, didFailWithError: error)
            }
        } else if let error = error as? OmiseError {
            displayErrorMessage(paymentSourceCreatorFlowSession.localizedErrorMessageFor(error), animated: true, sender: self)
        } else {
            displayErrorMessage(error.localizedDescription, animated: true, sender: self)
        }
    }
    
    func paymentCreatorFlowSessionDidCancel(_ paymentSourceCreatorFlowSession: PaymentCreatorFlowSession) {
        if let paymentDelegate = self.paymentDelegate {
            paymentDelegate.paymentCreatorControllerDidCancel(self)
        } else if let paymentDidCancelDelegateMethod = self.__paymentDelegate?.paymentCreatorControllerDidCancel {
            paymentDidCancelDelegateMethod(self)
        }
    }
}


extension PaymentCreatorFlowSession {
    func localizedErrorMessageFor(_ error: OmiseError) -> String {
        switch error {
        case .api(code: let code, message: _, location: _):
            switch code {
            case .invalidCard(let invalidCardReasons):
                switch invalidCardReasons.first {
                case .invalidCardNumber?:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.invalid-card-number.message",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Invalid card number.",
                        comment: "The displaying message showing in the error banner in the built-in Payment Creator when there is the `invalid-card-number` API error occured"
                    )
                case .invalidExpirationDate?:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.invalid-expiration-date.message",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Invalid card expiration date.",
                        comment: "The displaying message showing in the error banner in the built-in Payment Creator when there is the `invalid-expiration-date` API error occured"
                    )
                case .emptyCardHolderName?:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.empty-card-holder-name.message",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Invalid card holder name.",
                        comment: "The displaying message showing in the error banner in the built-in Payment Creator when there is the `empty-card-holder-name` API error occured"
                    )
                case .unsupportedBrand?:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.unsupported-brand.message",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Unsupported card brand.",
                        comment: "The displaying message showing in the error banner in the built-in Payment Creator when there is the `unsupported-brand` API error occured"
                    )
                case .other?, nil:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.other.message",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Unknown error occurred.",
                        comment: "The displaying message showing in the error banner in the built-in Payment Creator when there is the `other` API error occured"
                    )
                }
            case .badRequest(let badRequestReasons):
                switch badRequestReasons.first {
                case .amountIsLessThanValidAmount(validAmount: let validAmount, currency: let currency)?:
                    if let validAmount = validAmount {
                        let preferredErrorDescriptionFormat = NSLocalizedString(
                            "payment-creator.error.api.bad_request.amount-is-less-than-valid-amount.with-valid-amount.message",
                            tableName: "Error", bundle: Bundle.omiseSDKBundle,
                            value: "Amount is less than the valid amount of %@",
                            comment: "The displaying message showing in the error banner an `Bad request` error with `amount-is-less-than-valid-amount.with-valid-amount` from the backend has occurred"
                        )
                        let formatter = NumberFormatter.makeAmountFormatter(for: self.paymentCurrency ?? currency)
                        return String.localizedStringWithFormat(preferredErrorDescriptionFormat, formatter.string(from: NSNumber(value: validAmount)) ?? "\(validAmount)")
                    } else {
                        return NSLocalizedString(
                            "payment-creator.error.api.bad_request.amount-is-less-than-valid-amount.without-valid-amount.message",
                            tableName: "Error", bundle: Bundle.omiseSDKBundle,
                            value: "Amount is less than the valid amount",
                            comment: "The displaying message showing in the error banner an `Bad request` error with `amount-is-less-than-valid-amount.without-valid-amount` from the backend has occurred"
                        )
                    }
                case .amountIsGreaterThanValidAmount(validAmount: let validAmount, currency: let currency)?:
                    if let validAmount = validAmount {
                        let preferredErrorDescriptionFormat = NSLocalizedString(
                            "payment-creator.error.api.bad_request.amount-is-greater-than-valid-amount.with-valid-amount.message",
                            tableName: "Error", bundle: Bundle.omiseSDKBundle,
                            value: "Amount is greater than the valid amount of %@",
                            comment: "The displaying message showing in the error banner an `Bad request` error with `amount-is-greater-than-valid-amount.with-valid-amount` from the backend has occurred"
                        )
                        let formatter = NumberFormatter.makeAmountFormatter(for: self.paymentCurrency ?? currency)
                        return String.localizedStringWithFormat(preferredErrorDescriptionFormat, formatter.string(from: NSNumber(value: validAmount)) ?? "\(validAmount)")
                    } else {
                        return NSLocalizedString(
                            "payment-creator.error.api.bad_request.amount-is-greater-than-valid-amount.without-valid-amount.message",
                            tableName: "Error", bundle: Bundle.omiseSDKBundle,
                            value: "Amount is greater than the valid amount",
                            comment: "The displaying message showing in the error banner an `Bad request` error with `amount-is-greater-than-valid-amount.without-valid-amount` from the backend has occurred"
                        )
                    }
                case .invalidCurrency?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.invalid-currency.message",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "The currency is invalid",
                        comment: "The displaying message showing in the error banner an `Bad request` error with `invalid-currency` from the backend has occurred"
                    )
                    
                case .emptyName?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.empty-name.message",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "The customer name is empty",
                        comment: "The displaying message showing in the error banner an `Bad request` error with `empty-name` from the backend has occurred"
                    )
                    
                case .nameIsTooLong(maximum: let maximumLength)?:
                    if let maximumLength = maximumLength {
                        let preferredErrorDescriptionFormat = NSLocalizedString(
                            "payment-creator.error.api.bad_request.name-is-too-long.with-valid-length.message",
                            tableName: "Error", bundle: Bundle.omiseSDKBundle,
                            value: "The customer name is longer than %d characters",
                            comment: "The displaying message showing in the error banner an `Bad request` error with `name-is-too-long.with-valid-length` from the backend has occurred"
                        )
                        return String.localizedStringWithFormat(preferredErrorDescriptionFormat, maximumLength)
                    } else {
                        return NSLocalizedString(
                            "payment-creator.error.api.bad_request.name-is-too-long.without-valid-length.message",
                            tableName: "Error", bundle: Bundle.omiseSDKBundle,
                            value: "The customer name is too long.",
                            comment: "The displaying message showing in the error banner an `Bad request` error with `name-is-too-long.without-valid-length` from the backend has occurred"
                        )
                    }
                case .invalidName?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.invalid-name.message",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "The customer name is invalid",
                        comment: "The displaying message showing in the error banner an `Bad request` error with `invalid-name` from the backend has occurred"
                    )
                    
                case .invalidEmail?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.invalid-email.message",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "The customer email is invalid",
                        comment: "The displaying message showing in the error banner an `Bad request` error with `invalid-email` from the backend has occurred"
                    )
                    
                case .invalidPhoneNumber?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.invalid-phone-number.message",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "The customer phone number is invalid",
                        comment: "The displaying message showing in the error banner an `Bad request` error with `invalid-phone-number` from the backend has occurred"
                    )
                    
                case .typeNotSupported?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.type-not-supported.message",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "The source type is not supported for this account",
                        comment: "The displaying message showing in the error banner an `Bad request` error with `type-not-supported` from the backend has occurred"
                    )
                    
                case .currencyNotSupported?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.currency-not-supported.message",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "The currency is not supported for this account",
                        comment: "The displaying message showing in the error banner an `Bad request` error with `currency-not-supported` from the backend has occurred"
                    )
                case .other?, nil:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.other.message",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Unknown error occurred",
                        comment: "The displaying message showing in the error banner an `Bad request` error with `other` from the backend has occurred"
                    )
                }
            case .authenticationFailure, .serviceNotFound:
                return NSLocalizedString(
                    "payment-creator.error.api.unexpected.message",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Unexpected error",
                    comment: "The displaying message showing in the error banner in the built-in Payment Creator when there is the `unexpected` API error occured"
                )
            case .other:
                return NSLocalizedString(
                    "payment-creator.error.api.unknown.message",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Unknown error occured",
                    comment: "The displaying message showing in the error banner when there is an `unknown` API error occured"
                )
            }
        case .unexpected:
            return NSLocalizedString(
                "payment-creator.error.unexpected.message",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "Unexpected error",
                comment: "The displaying message showing in the error banner when there is the `unexpected` error occured"
            )
        }
    }
    
    func localizedSuggestionRecoveryMessageFor(_ error: OmiseError) -> String {
        switch error {
        case .api(code: let code, message: _, location: _):
            switch code {
            case .invalidCard(let invalidCardReasons):
                switch invalidCardReasons.first {
                case .invalidCardNumber?:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.invalid-card-number.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please review the card number again.",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator in the built-in Payment Creator when there is the `invalid-card-number` API error occured"
                    )
                case .invalidExpirationDate?:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.invalid-expiration-date.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please review the card expiration date again.",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator in the built-in Payment Creator when there is the `invalid-expiration-date` API error occured"
                    )
                case .emptyCardHolderName?:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.empty-card-holder-name.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please review the card holder name again.",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator in the built-in Payment Creator when there is the `empty-card-holder-name` API error occured"
                    )
                case .unsupportedBrand?:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.unsupported-brand.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please use other card.",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator in the built-in Payment Creator when there is the `unsupported-brand` API error occured"
                    )
                case .other?, nil:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.other.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please try again later.",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator in the built-in Payment Creator when there is the `other` API error occured"
                    )
                }
            case .badRequest(let badRequestReasons):
                switch badRequestReasons.first {
                case .amountIsLessThanValidAmount(validAmount: let validAmount, currency: let currency)?:
                    if let validAmount = validAmount {
                        let preferredErrorDescriptionFormat = NSLocalizedString(
                            "payment-creator.error.api.bad_request.amount-is-less-than-valid-amount.with-valid-amount.recovery-suggestion",
                            tableName: "Error", bundle: Bundle.omiseSDKBundle,
                            value: "",
                            comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `amount-is-less-than-valid-amount.with-valid-amount` from the backend has occurred"
                        )
                        let formatter = NumberFormatter.makeAmountFormatter(for: self.paymentCurrency ?? currency)
                        return String.localizedStringWithFormat(preferredErrorDescriptionFormat, formatter.string(from: NSNumber(value: validAmount)) ?? "\(validAmount)")
                    } else {
                        return NSLocalizedString(
                            "payment-creator.error.api.bad_request.amount-is-less-than-valid-amount.without-valid-amount.recovery-suggestion",
                            tableName: "Error", bundle: Bundle.omiseSDKBundle,
                            value: "",
                            comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `amount-is-less-than-valid-amount.without-valid-amount` from the backend has occurred"
                        )
                    }
                case .amountIsGreaterThanValidAmount(validAmount: let validAmount, currency: let currency)?:
                    if let validAmount = validAmount {
                        let preferredErrorDescriptionFormat = NSLocalizedString(
                            "payment-creator.error.api.bad_request.amount-is-greater-than-valid-amount.with-valid-amount.recovery-suggestion",
                            tableName: "Error", bundle: Bundle.omiseSDKBundle,
                            value: "",
                            comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `amount-is-greater-than-valid-amount.with-valid-amount` from the backend has occurred"
                        )
                        let formatter = NumberFormatter.makeAmountFormatter(for: self.paymentCurrency ?? currency)
                        return String.localizedStringWithFormat(preferredErrorDescriptionFormat, formatter.string(from: NSNumber(value: validAmount)) ?? "\(validAmount)")
                    } else {
                        return NSLocalizedString(
                            "payment-creator.error.api.bad_request.amount-is-greater-than-valid-amount.without-valid-amount.recovery-suggestion",
                            tableName: "Error", bundle: Bundle.omiseSDKBundle,
                            value: "",
                            comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `amount-is-greater-than-valid-amount.without-valid-amount` from the backend has occurred"
                        )
                    }
                case .invalidCurrency?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.invalid-currency.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please choose other currency or contact the support",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `invalid-currency` from the backend has occurred"
                    )
                    
                case .emptyName?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.empty-name.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please fill the custemer name",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `empty-name` from the backend has occurred"
                    )
                    
                case .nameIsTooLong(maximum: _)?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.name-is-too-long.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please review the customer name.",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `name-is-too-long.without-valid-length` from the backend has occurred"
                    )
                case .invalidName?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.invalid-name.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please review the custemer name",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `invalid-name` from the backend has occurred"
                    )
                    
                case .invalidEmail?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.invalid-email.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please review the email.",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `invalid-email` from the backend has occurred"
                    )
                    
                case .invalidPhoneNumber?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.invalid-phone-number.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please review the phone number.",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `invalid-phone-number` from the backend has occurred"
                    )
                    
                case .typeNotSupported?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.type-not-supported.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please contact the support.",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `type-not-supported` from the backend has occurred"
                    )
                    
                case .currencyNotSupported?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.currency-not-supported.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please choose other currency.",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `currency-not-supported` from the backend has occurred"
                    )
                case .other?, nil:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.other.recovery-suggestion",
                        tableName: "Error", bundle: Bundle.omiseSDKBundle,
                        value: "Please try again later.",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `other` from the backend has occurred"
                    )
                }
            case .authenticationFailure, .serviceNotFound:
                return NSLocalizedString(
                    "payment-creator.error.api.unexpected.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Please try again later.",
                    comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator when there is the `unexpected` API error occured"
                )
            case .other:
                return NSLocalizedString(
                    "payment-creator.error.api.unknown.recovery-suggestion",
                    tableName: "Error", bundle: Bundle.omiseSDKBundle,
                    value: "Please try again later.",
                    comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator when there is an `unknown` API error occured"
                )
            }
        case .unexpected:
            return NSLocalizedString(
                "payment-creator.error.unexpected.recovery-suggestion",
                tableName: "Error", bundle: Bundle.omiseSDKBundle,
                value: "Unexpected error",
                comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator when there is the `unexpected` error occured"
            )
        }
    }
}

extension PaymentCreatorController {
    public static let thailandDefaultAvailableSourceMethods: [OMSSourceTypeValue] = [
        .internetBankingBAY,
        .internetBankingKTB,
        .internetBankingSCB,
        .internetBankingBBL,
        .alipay,
        .billPaymentTescoLotus,
        .installmentBAY,
        .installmentFirstChoice,
        .installmentBBL,
        .installmentKTC,
        .installmentKBank,
        ]
    
    public static let japanDefaultAvailableSourceMethods: [OMSSourceTypeValue] = [
        OMSSourceTypeValue.eContext,
        ]
    
    public static let internetBankingAvailablePaymentMethods: [OMSSourceTypeValue] = [
        .internetBankingBAY,
        .internetBankingKTB,
        .internetBankingSCB,
        .internetBankingBBL,
        ]
    
    public static let installmentsBankingAvailablePaymentMethods: [OMSSourceTypeValue] = [
        .installmentBAY,
        .installmentFirstChoice,
        .installmentBBL,
        .installmentKTC,
        .installmentKBank,
        ]
    
    public static let billPaymentAvailablePaymentMethods: [OMSSourceTypeValue] = [
        .billPaymentTescoLotus,
        ]
    
    public static let barcodeAvailablePaymentMethods: [OMSSourceTypeValue] = [
        .barcodeAlipay,
        ]
}


class NoticeView: UIView {
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var detailLabel: UILabel!

}
