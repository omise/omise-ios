import UIKit

class ChoosePaymentCoordinator: NSObject, ViewAttachable {
    let client: ClientProtocol
    let amount: Int64
    let currency: String
    let currentCountry: Country?
    let applePayInfo: ApplePayInfo?
    let handleErrors: Bool
    
    enum ResultState {
        case cancelled
        case selectedPaymentMethod(PaymentMethod)
    }
    
    weak var choosePaymentMethodDelegate: ChoosePaymentMethodDelegate?
    weak var rootViewController: UIViewController?
    
    var errorViewHeightConstraint: NSLayoutConstraint?
    let errorView: OmiseBannerView = {
        let view = OmiseBannerView()
        view.translatesAutoresizingMaskIntoConstraints(false)
        return view
    }()
    
    init(client: ClientProtocol, amount: Int64, currency: String, currentCountry: Country?, applePayInfo: ApplePayInfo?, handleErrors: Bool) {
        self.client = client
        self.amount = amount
        self.currency = currency
        self.currentCountry = currentCountry
        self.applePayInfo = applePayInfo
        self.handleErrors = handleErrors
        super.init()
        
        self.setupErrorView()
    }
    
    /// Creates CreditCardController and attach current flow object inside created controller to be deallocated together
    ///
    /// - Parameters:
    ///   - delegate: Payment method delegate
    func createCreditCardPaymentController(delegate: ChoosePaymentMethodDelegate) -> CreditCardPaymentController {
        let viewController = createCreditCardPaymentController()
        viewController.attach(self)
        
        self.choosePaymentMethodDelegate = delegate
        self.rootViewController = viewController
        
        return viewController
    }
    
    /// Creates Credit Carc Payment screen and attach current flow object inside created controller to be deallocated together
    func createCreditCardPaymentController(paymentType: CreditCardPaymentOption = .card) -> CreditCardPaymentController {
        let vm = CreditCardPaymentFormViewModel(country: self.currentCountry,
                                                paymentOption: paymentType,
                                                delegate: self)
        let vc = CreditCardPaymentController(viewModel: vm)
        vc.title = localized("PaymentMethod.creditCard", text: "Credit Card")
        return vc
    }
}

extension ChoosePaymentCoordinator: CreditCardPaymentDelegate {
    func didSelectCardPayment(
        paymentType: CreditCardPaymentOption,
        card: CreateTokenPayload.Card,
        completion: @escaping () -> Void
    ) {
        switch paymentType {
        case .card:
            processPayment(card, completion: completion)
        case .whiteLabelInstallment(let payment):
            processWhiteLabelInstallmentPayment(payment, card: card, completion: completion)
        }
    }
    
    func didCancelCardPayment() {
        choosePaymentMethodDelegate?.choosePaymentMethodDidCancel()
    }
}

extension ChoosePaymentCoordinator: SelectSourcePaymentDelegate {
    func didSelectSourcePayment(_ payment: Source.Payment, completion: @escaping () -> Void) {
        if payment.sourceType.isWhiteLabelInstallment {
            navigate(to: createCreditCardPaymentController(
                paymentType: .whiteLabelInstallment(payment: payment)
            ))
        } else {
            processPayment(payment, completion: completion)
        }
    }
}
