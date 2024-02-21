import UIKit

class ChoosePaymentCoordinator: ViewAttachable {
    let client: Client
    let amount: Int64
    let currency: String

    enum ResultState {
        case cancelled
        case selectedPaymentMethod(PaymentMethod)
    }
    
    weak var choosePaymentMethodDelegate: ChoosePaymentMethodDelegate?

    weak var rootViewController: UIViewController?

    init(client: Client, amount: Int64, currency: String) {
        self.client = client
        self.amount = amount
        self.currency = currency
    }

    /// Creates SelectPaymentController and attach current flow object inside created controller to be deallocated together
    ///
    /// - Parameters:
    ///   - allowedPaymentMethods: List of Payment Methods to be presented in the list if `usePaymentMethodsFromCapability` is `false`
    ///   - allowedCardPayment: Shows credit card payment option if `true` and `usePaymentMethodsFromCapability` is `false`
    ///   - usePaymentMethodsFromCapability: If `true`then it loads list of Payment Methods from Capability API and ignores previous parameters
    func createChoosePaymentMethodController(
        allowedPaymentMethods paymentMethods: [SourceType] = [],
        allowedCardPayment isCardEnabled: Bool = true,
        usePaymentMethodsFromCapability useCapability: Bool,
        delegate: ChoosePaymentMethodDelegate
    ) -> SelectPaymentController {
        let viewModel = SelectPaymentMethodViewModel(client: client, delegate: self)
        if useCapability {
            viewModel.setupCapability()
        } else {
            viewModel.setupAllowedPaymentMethods(paymentMethods, isCardEnabled: isCardEnabled)
        }

        let listController = SelectPaymentController(viewModel: viewModel)
        listController.attach(self)

        self.choosePaymentMethodDelegate = delegate
        self.rootViewController = listController

        return listController
    }

    /// Creates Mobile Banking screen and attach current flow object inside created controller to be deallocated together
    func createMobileBankingController() -> SelectPaymentController {
        let viewModel = SelectSourceTypePaymentViewModel(
            title: PaymentMethod.mobileBanking.localizedTitle,
            sourceTypes: SourceType.mobileBanking,
            delegate: self
        )

        let listController = SelectPaymentController(viewModel: viewModel)
        return listController
    }

    /// Creates Mobile Banking screen and attach current flow object inside created controller to be deallocated together
    func createInternetBankingController() -> SelectPaymentController {
        let viewModel = SelectSourceTypePaymentViewModel(
            title: PaymentMethod.internetBanking.localizedTitle,
            sourceTypes: SourceType.internetBanking,
            delegate: self
        )

        let listController = SelectPaymentController(viewModel: viewModel)
        return listController
    }

    /// Creates Installement screen and attach current flow object inside created controller to be deallocated together
    func createInstallmentController() -> SelectPaymentController {
        let viewModel = SelectSourceTypePaymentViewModel(
            title: PaymentMethod.installment.localizedTitle,
            sourceTypes: SourceType.installments,
            delegate: self
        )

        let listController = SelectPaymentController(viewModel: viewModel)
        return listController
    }

    /// Creates Installement screen and attach current flow object inside created controller to be deallocated together
    func createInstallmentTermsController(sourceType: SourceType) -> SelectPaymentController {
        let viewModel = SelectInstallmentTermsViewModel(sourceType: sourceType, delegate: self)
        let listController = SelectPaymentController(viewModel: viewModel)
        return listController
    }

    /// Creates Atome screen and attach current flow object inside created controller to be deallocated together
    func createAtomeController() -> AtomePaymentController {
        let viewModel = AtomePaymentViewModel(amount: amount, delegate: self)
        let viewController = AtomePaymentController(viewModel: viewModel)
        viewController.title = SourceType.atome.localizedTitle
        return viewController
    }
}

extension ChoosePaymentCoordinator: SelectPaymentMethodDelegate {
    func didSelectPaymentMethod(_ paymentMethod: PaymentMethod) {
        if paymentMethod.requiresAdditionalDetails {
            switch paymentMethod {
            case .mobileBanking: navigate(to: createMobileBankingController())
            case .internetBanking: navigate(to: createInternetBankingController())
            case .installment: navigate(to: createInstallmentController())
            case .sourceType(.atome): navigate(to: createAtomeController())
            default: break
            }
        } else if let sourceType = paymentMethod.sourceType {
            processPayment(.sourceType(sourceType))
        } else {
            assertionFailure("Unexpected case for selected payment method: \(paymentMethod)")
        }
    }

    func didCancelPayment() {
        choosePaymentMethodDelegate?.choosePaymentMethodDidCancel()
    }
}

extension ChoosePaymentCoordinator: SelectSourceTypeDelegate {
    func didSelectSourceType(_ sourceType: SourceType) {
        if sourceType.isInstallment {
            navigate(to: createInstallmentTermsController(sourceType: sourceType))
        } else {
            processPayment(.sourceType(sourceType))
        }
    }
}

extension ChoosePaymentCoordinator: SelectSourcePaymentDelegate {
    func didSelectSourcePayment(_ payment: Source.Payment) {
        processPayment(payment)
    }
}

extension ChoosePaymentCoordinator {
    func navigate(to viewController: UIViewController) {
        rootViewController?.navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }

    func processPayment(_ payment: Source.Payment) {
        guard let delegate = choosePaymentMethodDelegate else { return }
        let sourcePayload = CreateSourcePayload(
            amount: amount,
            currency: currency,
            details: payment
        )

        client.createSource(payload: sourcePayload) { [weak delegate] result in
            switch result {
            case .success(let source):
                delegate?.choosePaymentMethodDidComplete(with: source)
            case .failure(let error):
                delegate?.choosePaymentMethodDidComplete(with: error)
            }
        }
    }
}

// protocol NavigationFlow<Route> {
//    associatedtype Route
//    func navigate(to: Route)
// }
//
// extension ChoosePaymentCoordinator: NavigationFlow {
//    enum Route {
//        case creditCard
//        case installments
//        case mobileBanking
//        case internetBanking
//        case atome
//        case trueMoneyWallet
//        case duitNowOBW
//        case eContext
//        case fpx
//    }
//
//    func navigate(to: Route) {
//        //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        //        switch (segue.identifier, segue.destination) {
//        //        case ("GoToCreditCardFormSegue"?, let controller as CreditCardFormViewController):
//        //            controller.publicKey = viewModel.flowSession?.client?.publicKey
//        //            controller.delegate = viewModel.flowSession
//        //            controller.navigationItem.rightBarButtonItem = nil
//        //        case ("GoToInternetBankingChooserSegue"?, let controller as InternetBankingSourceChooserViewController):
//        //            controller.showingValues = allowedPaymentMethods.filter({ $0.isInternetBanking })
//        //            controller.flowSession = self.viewModel.flowSession
//        //        case ("GoToMobileBankingChooserSegue"?, let controller as MobileBankingSourceChooserViewController):
//        //            controller.showingValues = allowedPaymentMethods.filter({ $0.isMobileBanking })
//        //            controller.flowSession = self.viewModel.flowSession
//        //        case ("GoToInstallmentBrandChooserSegue"?, let controller as InstallmentBankingSourceChooserViewController):
//        //            controller.showingValues = allowedPaymentMethods.filter({ $0.isInstallment })
//        //            controller.flowSession = self.viewModel.flowSession
//        //        case (_, let controller as EContextInformationInputViewController):
//        //            controller.flowSession = self.viewModel.flowSession
//        //            if let element = (sender as? UITableViewCell).flatMap(tableView.indexPath(for:)).map(item(at:)) {
//        //                switch element {
//        //                case .conbini:
//        //                    controller.navigationItem.title = NSLocalizedString(
//        //                        "econtext.convenience-store.navigation-item.title",
//        //                        bundle: .omiseSDK,
//        //                        value: "Konbini",
//        //                        comment: "A navigaiton title for the EContext screen when the `Konbini` is selected"
//        //                    )
//        //                case .netBanking:
//        //                    controller.navigationItem.title = NSLocalizedString(
//        //                        "econtext.netbanking.navigation-item.title",
//        //                        bundle: .omiseSDK,
//        //                        value: "Net Bank",
//        //                        comment: "A navigaiton title for the EContext screen when the `Net Bank` is selected"
//        //                    )
//        //                case .payEasy:
//        //                    controller.navigationItem.title = NSLocalizedString(
//        //                        "econtext.pay-easy.navigation-item.title",
//        //                        bundle: .omiseSDK,
//        //                        value: "Pay-easy",
//        //                        comment: "A navigaiton title for the EContext screen when the `Pay-easy` is selected"
//        //                    )
//        //                default: break
//        //                }
//        //            }
//        //        case ("GoToTrueMoneyFormSegue"?, let controller as TrueMoneyFormViewController):
//        //            controller.flowSession = self.viewModel.flowSession
//        //        case ("GoToFPXFormSegue"?, let controller as FPXFormViewController):
//        //            //            controller.showingValues = capability?.paymentMethod(for: .fpx)?.banks
//        //            //            capability?[.fpx]?.banks ?? []
//        //
//        //            controller.flowSession = self.viewModel.flowSession
//        //        case ("GoToDuitNowOBWBankChooserSegue"?, let controller as DuitNowOBWBankChooserViewController):
//        ////            controller.showingValues = [.duitNowOBWBanks]
//        ////            [Payment.DuitNowOBW.Bank]
//        //            controller.flowSession = self.viewModel.flowSession
//        //        default:
//        //            break
//        //        }
//        //
//        //        if let paymentShourceChooserUI = segue.destination as? PaymentChooserUI {
//        //            paymentShourceChooserUI.preferredPrimaryColor = self.preferredPrimaryColor
//        //            paymentShourceChooserUI.preferredSecondaryColor = self.preferredSecondaryColor
//        //        }
//        //    }
//    }
//
//    private func viewController(for route: Route) -> UIViewController {
//        switch self {
//        default:
//            return UIViewController()
//        }
//    }
// }
