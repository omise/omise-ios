// swiftlint:disable file_length

import UIKit
import os

/// Drop-in UI flow controller that let user choose the payment method with the given payment options
public class PaymentCreatorController: UINavigationController {

    /// Omise public key for calling tokenization API.
    public var publicKey: String? {
        didSet {
            guard let publicKey = publicKey else {
                os_log("Missing or invalid public key information - %{private}@", log: uiLogObject, type: .error, self.publicKey ?? "")
                assertionFailure("Missing public key information. Please set the public key before request token.")
                return
            }

            self.client = OmiseSDK(publicKey: publicKey).client
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

    /// Boolean indicates that the form should show the Credit Card payment option or not
    public var showsCreditCardPayment = true {
        didSet {
            paymentChooserController.viewModel.showsCreditCardPayment = showsCreditCardPayment
        }
    }

    private let paymentChooserController = ChoosePaymentMethodController(nibName: nil, bundle: .omiseSDK)

    /// Available Source payment options to let user to choose.
    /// The default value is the default available payment method for merchant in Thailand
    public var allowedPaymentMethods: [SourceType] = SourceType.availableByDefaultInThailand {
        didSet {
            paymentChooserController.viewModel.allowedPaymentMethods = allowedPaymentMethods
        }
    }

    /// A boolean flag to enables or disables automatic error handling.
    ///
    /// The controller will show an error alert in the UI if the value is true,
    /// otherwise the controller will ask its delegate.
    /// Defaults to `true`.
    public var handleErrors = true

    /// Delegate to receive CreditCardFormController result.
//    public weak var paymentDelegate: PaymentCreatorControllerDelegate?

    var client: Client? {
        didSet {
            paymentSourceCreatorFlowSession.client = client
        }
    }

    private let paymentSourceCreatorFlowSession = PaymentCreatorFlowSession()

    private var noticeViewHeightConstraint: NSLayoutConstraint!
    private let displayingNoticeView: NoticeView = {
        let noticeViewNib = UINib(nibName: "NoticeView", bundle: .omiseSDK)
        let noticeView = noticeViewNib.instantiate(withOwner: nil, options: nil).first as! NoticeView // swiftlint:disable:this force_cast
        noticeView.translatesAutoresizingMaskIntoConstraints = false
        noticeView.backgroundColor = .error
        return noticeView
    }()

    @IBInspectable public var preferredPrimaryColor: UIColor?
    @IBInspectable public var preferredSecondaryColor: UIColor? {
        didSet {
            #if compiler(>=5.1)
            if #available(iOS 13, *) {
                let appearance = UINavigationBarAppearance(barAppearance: navigationBar.standardAppearance)
                appearance.shadowColor = preferredSecondaryColor ?? defaultPaymentChooserUISecondaryColor
                navigationBar.standardAppearance = appearance
            }
            #endif
        }
    }

//    /// Factory method for creating CreditCardFormController with given public key.
//    /// - parameter publicKey: Omise public key.
//    public static func makePaymentCreatorControllerWith(
//        publicKey: String,
//        amount: Int64,
//        currency: Currency,
//        allowedPaymentMethods: [SourceType],
//        paymentDelegate: PaymentCreatorControllerDelegate?
//    ) -> PaymentCreatorController {
//        let paymentCreatorController = PaymentCreatorController()
//        paymentCreatorController.publicKey = publicKey
//        paymentCreatorController.paymentAmount = amount
//        paymentCreatorController.paymentCurrency = currency
//        paymentCreatorController.allowedPaymentMethods = allowedPaymentMethods
//        paymentCreatorController.paymentDelegate = paymentDelegate
//        return paymentCreatorController
//    }

    public init() {
        super.init(rootViewController: paymentChooserController)
        initializeWithPaymentChooserViewController(paymentChooserController)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewControllers = [paymentChooserController]
        initializeWithPaymentChooserViewController(paymentChooserController)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initializeWithPaymentChooserViewController(paymentChooserController)
    }

    public override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        initializeWithPaymentChooserViewController(paymentChooserController)
    }
    
    public func applyPaymentMethods(from capability: Capability) {
        paymentChooserController.viewModel.allowedPaymentMethods(from: capability)
    }

    private func initializeWithPaymentChooserViewController(_ viewController: ChoosePaymentMethodController) {
        viewController.viewModel.flowSession = paymentSourceCreatorFlowSession
        viewController.viewModel.allowedPaymentMethods = allowedPaymentMethods
        viewController.viewModel.showsCreditCardPayment = showsCreditCardPayment

        paymentSourceCreatorFlowSession.delegate = self

        noticeViewHeightConstraint = displayingNoticeView.heightAnchor.constraint(equalToConstant: 0)
        noticeViewHeightConstraint.isActive = true

        let dismissErrorBannerTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                            action: #selector(self.dismissErrorMessageBanner(_:)))
        displayingNoticeView.addGestureRecognizer(dismissErrorBannerTapGestureRecognizer)
    }

    /// Displays an error banner at the top of the UI with the given error message.
    ///
    /// - Parameters:
    ///   - title: Title message to be displayed in the banner
    ///   - message: Subtitle message to be displayed in the banner
    ///   - animated: Pass true to animate the presentation; otherwise, pass false
    ///   - sender: The object that initiated the request
    public override func displayErrorWith(title: String, message: String?, animated: Bool, sender: Any?) {
        displayingNoticeView.titleLabel.text = title
        displayingNoticeView.detailLabel.text = message
        view.insertSubview(self.displayingNoticeView, belowSubview: navigationBar)

        NSLayoutConstraint.activate([
            displayingNoticeView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            displayingNoticeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            displayingNoticeView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        noticeViewHeightConstraint.isActive = true
        view.layoutIfNeeded()

        let animationBlock = {
            self.noticeViewHeightConstraint.isActive = false
            self.view.layoutIfNeeded()
            if #available(iOS 13, *) {
                self.topViewController?.additionalSafeAreaInsets.top = self.displayingNoticeView.bounds.height
            } else if #available(iOS 11, *) {
                self.additionalSafeAreaInsets.top = self.displayingNoticeView.bounds.height
            }
        }

        if animated {
            UIView.animate(withDuration: TimeInterval(UINavigationController.hideShowBarDuration) + 0.07,
                           delay: 0.0,
                           options: [.layoutSubviews, .beginFromCurrentState],
                           animations: animationBlock)
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
            if #available(iOS 13, *) {
                self.topViewController?.additionalSafeAreaInsets.top = 0
            } else if #available(iOS 11, *) {
                self.additionalSafeAreaInsets.top = 0
            }
        }

        if animated {
            UIView.animate(
                withDuration: TimeInterval(UINavigationController.hideShowBarDuration),
                delay: 0.0,
                options: [.layoutSubviews],
                animations: animationBlock
            ) { _ in
                var isCompleted: Bool {
                    if #available(iOS 13, *) {
                        return self.topViewController?.additionalSafeAreaInsets.top == 0
                    } else if #available(iOS 11, *) {
                        return self.additionalSafeAreaInsets.top == 0
                    } else {
                        return true
                    }
                }
                guard isCompleted else { return }
                self.displayingNoticeView.removeFromSuperview()
            }
        } else {
            animationBlock()
            self.displayingNoticeView.removeFromSuperview()
        }
    }

    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        dismissErrorMessage(animated: false, sender: self)

        if let viewController = viewController as? ChoosePaymentMethodController {
            viewController.viewModel.flowSession = self.paymentSourceCreatorFlowSession
        }
        super.pushViewController(viewController, animated: animated)
    }

    public override func popViewController(animated: Bool) -> UIViewController? {
        dismissErrorMessage(animated: false, sender: self)
        return super.popViewController(animated: animated)
    }

    public override func addChild(_ childController: UIViewController) {
        if let viewController = childController as? ChoosePaymentMethodController {
            viewController.viewModel.flowSession = self.paymentSourceCreatorFlowSession
        }
        super.addChild(childController)
    }

    // need to refactor loadView, removing super results in crash
    // swiftlint:disable:next prohibited_super_call
    public override func loadView() {
        super.loadView()

        view.backgroundColor = .background
        applyNavigationBarStyle(.shadow(color: preferredSecondaryColor ?? defaultPaymentChooserUISecondaryColor))
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        if self.displayingNoticeView.superview != nil {
            coordinator.animate(alongsideTransition: { _ in
                if #available(iOS 13, *) {
                    self.additionalSafeAreaInsets.top = 0
                } else if #available(iOS 11, *) {
                    self.additionalSafeAreaInsets.top = self.displayingNoticeView.bounds.height
                }
            }, completion: nil)
        }
    }

    @objc func dismissErrorMessageBanner(_ sender: AnyObject) {
        dismissErrorMessage(animated: true, sender: sender)
    }
}

extension PaymentCreatorController: PaymentCreatorFlowSessionDelegate {
    func paymentCreatorFlowSessionWillCreateSource(_ paymentSourceCreatorFlowSession: PaymentCreatorFlowSession) {
        dismissErrorMessage(animated: true, sender: self)
    }

    func paymentCreatorFlowSession(_ paymentSourceCreatorFlowSession: PaymentCreatorFlowSession, didCreateToken token: Token) {
        os_log("Credit Card Form in Payment Createor - Request succeed %{private}@, trying to notify the delegate",
               log: uiLogObject,
               type: .default,
               token.id)


//        if let paymentDelegate = self.paymentDelegate {
//            paymentDelegate.paymentCreatorController(self, didCreatePayment: Payment.token(token))
//        }
    }

    func paymentCreatorFlowSession(_ paymentSourceCreatorFlowSession: PaymentCreatorFlowSession, didCreatedSource source: Source) {
        os_log("Payment Creator Create Source Request succeed %{private}@, trying to notify the delegate",
               log: uiLogObject,
               type: .default,
               source.id)

//        if let paymentDelegate = self.paymentDelegate {
//            paymentDelegate.paymentCreatorController(self, didCreatePayment: Payment.source(source))
//            os_log("Payment Creator Created Source succeed delegate notified", log: uiLogObject, type: .default)
//        } else {
//            os_log("There is no Payment Creator delegate to notify about the created source", log: uiLogObject, type: .default)
//        }
    }

    func paymentCreatorFlowSession(_ paymentSourceCreatorFlowSession: PaymentCreatorFlowSession, didFailWithError error: Error) {
        if !handleErrors {
            os_log("Payment Creator Request failed %{private}@, automatically error handling turned off. Trying to notify the delegate",
                   log: uiLogObject,
                   type: .info,
                   error.localizedDescription)
//            if let paymentDelegate = self.paymentDelegate {
//                paymentDelegate.paymentCreatorController(self, didFailWithError: error)
//                os_log("Payment Creator error handling delegate notified", log: uiLogObject, type: .default)
//            } else {
//                os_log("There is no Payment Creator delegate to notify about the error", log: uiLogObject, type: .default)
//            }
        } else if let error = error as? OmiseError {
            displayErrorWith(title: error.localizedDescription,
                             message: error.localizedRecoverySuggestion,
                             animated: true,
                             sender: self)
        } else if let error = error as? LocalizedError {
            displayErrorWith(title: error.localizedDescription,
                             message: error.recoverySuggestion,
                             animated: true,
                             sender: self)
        } else {
            displayErrorWith(title: error.localizedDescription,
                             message: nil,
                             animated: true,
                             sender: self)
        }

        os_log("Payment Creator Request failed %{private}@, automatically error handling turned on.",
               log: uiLogObject,
               type: .default,
               error.localizedDescription)
    }

    func paymentCreatorFlowSessionDidCancel(_ paymentSourceCreatorFlowSession: PaymentCreatorFlowSession) {
        os_log("Payment Creator dismissal requested. Asking the delegate what should the controler do", log: uiLogObject, type: .default)

//        if let paymentDelegate = self.paymentDelegate {
//            paymentDelegate.paymentCreatorControllerDidCancel(self)
//        } else {
//            os_log("Payment Creator dismissal requested but there is no delegate to ask. Ignore the request",
//                   log: uiLogObject,
//                   type: .default)
//        }
    }
}


class NoticeView: UIView {

    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!

}
