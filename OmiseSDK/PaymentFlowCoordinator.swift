import UIKit

class PaymentFlowCoordinator: ViewAttachable {
    let client: Client
    let amount: Int64
    let currency: String

    enum ResultState {
        case cancelled
        case selectedPaymentMethod(PaymentMethod)
    }
    
    weak var choosePaymentMethodDelegate: ChoosePaymentMethodDelegate?

    init(client: Client, amount: Int64, currency: String) {
        self.client = client
        self.amount = amount
        self.currency = currency
    }

    /// Creates RootViewController and attach current flow object inside created controller to be deallocated together
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
    ) -> PaymentListController {
        self.choosePaymentMethodDelegate = delegate

        let viewModel = ChoosePaymentMethodViewModel(client: client, delegate: self)
        if useCapability {
            viewModel.setupCapability()
        } else {
            viewModel.setupAllowedPaymentMethods(paymentMethods, isCardEnabled: isCardEnabled)
        }

        let listController = PaymentListController(viewModel: viewModel)
        listController.attach(self)
        return listController
    }
}

extension PaymentFlowCoordinator {
    func didSelectPaymentMethod(
        _ paymentMethod: PaymentMethod,
        listController: TableListController,
        delegate: ChoosePaymentMethodDelegate
    ) {
        let viewController: UIViewController?

        switch paymentMethod {
        case .creditCard:
            viewController = UIViewController()
        case .installment:
            viewController = UIViewController()
        case .internetBanking:
            viewController = UIViewController()
        case .mobileBanking:
            viewController = UIViewController()
        case .eContextConbini:
            viewController = UIViewController()
        case .eContextPayEasy:
            viewController = UIViewController()
        case .eContextNetBanking:
            viewController = UIViewController()
        case .sourceType(.atome):
            viewController = UIViewController()
        case .sourceType(.barcodeAlipay):
            viewController = UIViewController()
        case .sourceType(.duitNowOBW):
            viewController = createDuitNowOBWController(title: paymentMethod.localizedTitle)
        case .sourceType(.fpx):
            viewController = UIViewController()
        case .sourceType(.trueMoneyWallet):
            viewController = UIViewController()
        default:
            viewController = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak listController] in
                listController?.unlockUserInterface()
            }
        }

        if let viewController = viewController {
            viewController.view.backgroundColor = .white
            viewController.title = paymentMethod.localizedTitle
            listController.navigationController?.pushViewController(
                viewController,
                animated: true
            )
        }
        print("doSomething here with payment '\(paymentMethod)'")

    }
}

// protocol NavigationFlow<Route> {
//    associatedtype Route
//    func navigate(to: Route)
// }
//
// extension PaymentFlowCoordinator: NavigationFlow {
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

extension PaymentFlowCoordinator: PaymentMethodDelegate {
    func didSelectPaymentMethod(_ paymentMethod: PaymentMethod) {
        if paymentMethod.requiresAdditionalDetails {
            print("Navigate to the next screen")
        } else if let sourceType = paymentMethod.sourceType {
            processPayment(sourceType: sourceType)
        } else {
            assertionFailure("Unexpected case with selected payment method: \(paymentMethod.localizedTitle)")
        }
    }

    func processPayment(sourceType: SourceType) {
        guard let delegate = choosePaymentMethodDelegate else { return }
        let sourcePayload = CreateSourcePayload(
            amount: amount,
            currency: currency,
            details: .sourceType(sourceType)
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

    func didCancelPayment() {
        choosePaymentMethodDelegate?.choosePaymentMethodDidCancel()
    }
}
