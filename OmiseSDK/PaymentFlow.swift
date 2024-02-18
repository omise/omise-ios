import UIKit

class PaymentFlow {
    private let client: Client
    private let amount: Int64
    private let currency: String

    private var choosePaymentMethodController: ChoosePaymentMethodController?

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
    func createRootViewController(
        allowedPaymentMethods: [SourceType] = [],
        allowedCardPayment: Bool = true,
        usePaymentMethodsFromCapability: Bool,
        delegate: ChoosePaymentMethodDelegate
    ) -> ChoosePaymentMethodController {
        let rootViewController = ChoosePaymentMethodController()
        rootViewController.addChild(PaymentFlowContainerController(self))
        let viewModel = rootViewController.viewModel

        if usePaymentMethodsFromCapability {
            viewModel.setup(amount: amount, currenct: currency, client: client)
        } else {
            viewModel.setupAllowedPaymentMethods(
                allowedPaymentMethods,
                allowedCardPayment: allowedCardPayment,
                amount: amount,
                currenct: currency,
                client: client
            )
        }

        viewModel.completionHandler { [weak self, weak delegate] result in
            guard let self = self, let delegate = delegate else { return }
            self.choosePaymentMethodCompletion(delegate: delegate, result)
        }

        choosePaymentMethodController = rootViewController
        return rootViewController
    }
}

private extension PaymentFlow {
    private func choosePaymentMethodCompletion(delegate: ChoosePaymentMethodDelegate, _ result: ChoosePaymentMethodResult) {
        switch result {
        case .cancelled:
            delegate.choosePaymentMethodDidCancel()
        case .selectedPayment(let paymentOption):
            let viewController: UIViewController?

            switch paymentOption {
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
                viewController = UIViewController()
            case .sourceType(.fpx):
                viewController = UIViewController()
            case .sourceType(.trueMoneyWallet):
                viewController = UIViewController()
            default:
                viewController = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
                    self?.choosePaymentMethodController?.unlockUserInterface()

                }
            }

            if let viewController = viewController {
                viewController.view.backgroundColor = .white
                viewController.title = paymentOption.localizedTitle
                choosePaymentMethodController?.navigationController?.pushViewController(
                    viewController,
                    animated: true
                )
            }
            print("doSomething here with payment '\(paymentOption)'")
        }
    }
}
protocol NavigationFlow<Route> {
    associatedtype Route
    func navigate(to: Route)
}

extension PaymentFlow: NavigationFlow {
    enum Route {
        case creditCard
        case installments
        case mobileBanking
        case internetBanking
        case atome
        case trueMoneyWallet
        case duitNowOBW
        case eContext
        case fpx
    }

    func navigate(to: Route) {
        //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        switch (segue.identifier, segue.destination) {
        //        case ("GoToCreditCardFormSegue"?, let controller as CreditCardFormViewController):
        //            controller.publicKey = viewModel.flowSession?.client?.publicKey
        //            controller.delegate = viewModel.flowSession
        //            controller.navigationItem.rightBarButtonItem = nil
        //        case ("GoToInternetBankingChooserSegue"?, let controller as InternetBankingSourceChooserViewController):
        //            controller.showingValues = allowedPaymentMethods.filter({ $0.isInternetBanking })
        //            controller.flowSession = self.viewModel.flowSession
        //        case ("GoToMobileBankingChooserSegue"?, let controller as MobileBankingSourceChooserViewController):
        //            controller.showingValues = allowedPaymentMethods.filter({ $0.isMobileBanking })
        //            controller.flowSession = self.viewModel.flowSession
        //        case ("GoToInstallmentBrandChooserSegue"?, let controller as InstallmentBankingSourceChooserViewController):
        //            controller.showingValues = allowedPaymentMethods.filter({ $0.isInstallment })
        //            controller.flowSession = self.viewModel.flowSession
        //        case (_, let controller as EContextInformationInputViewController):
        //            controller.flowSession = self.viewModel.flowSession
        //            if let element = (sender as? UITableViewCell).flatMap(tableView.indexPath(for:)).map(item(at:)) {
        //                switch element {
        //                case .conbini:
        //                    controller.navigationItem.title = NSLocalizedString(
        //                        "econtext.convenience-store.navigation-item.title",
        //                        bundle: .omiseSDK,
        //                        value: "Konbini",
        //                        comment: "A navigaiton title for the EContext screen when the `Konbini` is selected"
        //                    )
        //                case .netBanking:
        //                    controller.navigationItem.title = NSLocalizedString(
        //                        "econtext.netbanking.navigation-item.title",
        //                        bundle: .omiseSDK,
        //                        value: "Net Bank",
        //                        comment: "A navigaiton title for the EContext screen when the `Net Bank` is selected"
        //                    )
        //                case .payEasy:
        //                    controller.navigationItem.title = NSLocalizedString(
        //                        "econtext.pay-easy.navigation-item.title",
        //                        bundle: .omiseSDK,
        //                        value: "Pay-easy",
        //                        comment: "A navigaiton title for the EContext screen when the `Pay-easy` is selected"
        //                    )
        //                default: break
        //                }
        //            }
        //        case ("GoToTrueMoneyFormSegue"?, let controller as TrueMoneyFormViewController):
        //            controller.flowSession = self.viewModel.flowSession
        //        case ("GoToFPXFormSegue"?, let controller as FPXFormViewController):
        //            //            controller.showingValues = capability?.paymentMethod(for: .fpx)?.banks
        //            //            capability?[.fpx]?.banks ?? []
        //
        //            controller.flowSession = self.viewModel.flowSession
        //        case ("GoToDuitNowOBWBankChooserSegue"?, let controller as DuitNowOBWBankChooserViewController):
        ////            controller.showingValues = [.duitNowOBWBanks]
        ////            [PaymentInformation.DuitNowOBW.Bank]
        //            controller.flowSession = self.viewModel.flowSession
        //        default:
        //            break
        //        }
        //
        //        if let paymentShourceChooserUI = segue.destination as? PaymentChooserUI {
        //            paymentShourceChooserUI.preferredPrimaryColor = self.preferredPrimaryColor
        //            paymentShourceChooserUI.preferredSecondaryColor = self.preferredSecondaryColor
        //        }
        //    }
    }

    private func viewController(for route: Route) -> UIViewController {
        switch self {
        default:
            return UIViewController()
        }
    }
}

/// This class is used to store PaymentFlow and attach PaymentFlowContainerController to rootViewController
/// It will be deallocated as soon as rootViewController is dismissed
class PaymentFlowContainerController: UIViewController {
    var paymentFlow: PaymentFlow?
    init(_ paymentFlow: PaymentFlow) {
        self.paymentFlow = paymentFlow
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
