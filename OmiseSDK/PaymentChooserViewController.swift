// swiftlint:disable file_length
import UIKit
import os


/// swiftlint:disable:next type_body_length
class PaymentChooserViewController: UITableViewController, ListViewControllerProtocol,
                                    PaymentChooserUI {
    
    var showingValues: [ViewContext] = [] {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }

    typealias Item = PaymentChooserViewController.ViewContext

    struct ViewContext: Equatable {
        let icon: UIImage?
        let title: String
        let accessoryIcon: String?
        let code: String?
    }

    let viewModel = ViewModel()

    var showsCreditCardPayment = true {
        didSet {
            updateShowingValues()
        }
    }
    var allowedPaymentMethods: [SourceType] = [] {
        didSet {
            updateShowingValues()
        }
    }

    @IBOutlet private var paymentMethodNameLables: [UILabel]!

    @IBInspectable var preferredPrimaryColor: UIColor? {
        didSet {
            applyPrimaryColor()
        }
    }

    @IBInspectable var preferredSecondaryColor: UIColor? {
        didSet {
            applySecondaryColor()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        applyPrimaryColor()
//        applySecondaryColor()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//        applyNavigationBarStyle()
        updateShowingValues()
    }

    func customize(element viewContext: ViewContext, tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        cell.textLabel?.text = viewContext.title
        cell.imageView?.image = viewContext.icon
        cell.accessoryView = UIImageView(image: UIImage(named: "Next"))

        if let cell = cell as? PaymentOptionTableViewCell {
            cell.separatorView.backgroundColor = self.currentSecondaryColor
        }
        cell.accessoryView?.tintColor = self.currentSecondaryColor
    }

    // swiftlint:disable:next function_body_length
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier, segue.destination) {
        case ("GoToCreditCardFormSegue"?, let controller as CreditCardFormViewController):
            controller.publicKey = viewModel.flowSession?.client?.publicKey
            controller.delegate = viewModel.flowSession
            controller.navigationItem.rightBarButtonItem = nil
        case ("GoToInternetBankingChooserSegue"?, let controller as InternetBankingSourceChooserViewController):
            controller.showingValues = allowedPaymentMethods.filter({ $0.isInternetBanking })
            controller.flowSession = self.viewModel.flowSession
        case ("GoToMobileBankingChooserSegue"?, let controller as MobileBankingSourceChooserViewController):
            controller.showingValues = allowedPaymentMethods.filter({ $0.isMobileBanking })
            controller.flowSession = self.viewModel.flowSession
        case ("GoToInstallmentBrandChooserSegue"?, let controller as InstallmentBankingSourceChooserViewController):
            controller.showingValues = allowedPaymentMethods.filter({ $0.isInstallment })
            controller.flowSession = self.viewModel.flowSession
        case (_, let controller as EContextInformationInputViewController):
            controller.flowSession = self.viewModel.flowSession
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
        case ("GoToTrueMoneyFormSegue"?, let controller as TrueMoneyFormViewController):
            controller.flowSession = self.viewModel.flowSession
        case ("GoToFPXFormSegue"?, let controller as FPXFormViewController):
            //            controller.showingValues = capability?.paymentMethod(for: .fpx)?.banks
            //            capability?[.fpx]?.banks ?? []

            controller.flowSession = self.viewModel.flowSession
        case ("GoToDuitNowOBWBankChooserSegue"?, let controller as DuitNowOBWBankChooserViewController):
//            controller.showingValues = [.duitNowOBWBanks]
//            [PaymentInformation.DuitNowOBW.Bank]
            controller.flowSession = self.viewModel.flowSession
        default:
            break
        }

        if let paymentShourceChooserUI = segue.destination as? PaymentChooserUI {
            paymentShourceChooserUI.preferredPrimaryColor = self.preferredPrimaryColor
            paymentShourceChooserUI.preferredSecondaryColor = self.preferredSecondaryColor
        }
    }

    // swiftlint:disable:next function_body_length
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        let payment: PaymentInformation

//        let element: ViewContext = self.item(at: indexPath)
//        let selectedType = SourceType(rawValue: element.name)
/*
        os_log("Payment Chooser: %{private}@ was selected", log: uiLogObject, type: .info, selectedType.description)
        switch selectedType {
        case .alipay:
            payment = .sourceType(.alipay)
        case .alipayCN:
            payment = .sourceType(.alipayCN)
        case .alipayHK:
            payment = .sourceType(.alipayHK)
        case .dana:
            payment = .sourceType(.dana)
        case .gcash:
            payment = .sourceType(.gcash)
        case .kakaoPay:
            payment = .sourceType(.kakaoPay)
        case .touchNGoAlipayPlus, .touchNGo:
            payment = .sourceType(.touchNGo)
        case .tescoLotus:
            payment = .sourceType(.billPaymentTescoLotus)
        case .promptpay:
            payment = .sourceType(.promptPay)
        case .paynow:
            payment = .sourceType(.payNow)
        case .citiPoints:
            payment = .sourceType(.pointsCiti)
        case .rabbitLinepay:
            payment = .sourceType(.rabbitLinepay)
        case .ocbcDigital:
            payment = .sourceType(.ocbcDigital)
        case .grabPay, .grabPayRms:
            payment = .sourceType(.grabPay)
        case .boost:
            payment = .sourceType(.boost)
        case .shopeePay:
            payment = .sourceType(.shopeePay)
        case .shopeePayJumpApp:
            payment = .sourceType(.shopeePayJumpApp)
        case .maybankQRPay:
            payment = .sourceType(.maybankQRPay)
        case .duitNowQR:
            payment = .sourceType(.duitNowQR)
        case .payPay:
            payment = .sourceType(.payPay)
        case .atome:
            goToAtome()
            return
        case .truemoneyJumpApp:
            payment = .sourceType(.trueMoneyJumpApp)
        case .weChat:
            payment = .sourceType(.weChat)
        default:
            return
        }

        let oldAccessoryView = cell?.accessoryView
        let loadingIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        loadingIndicator.color = currentSecondaryColor
        cell?.accessoryView = loadingIndicator
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false

        flowSession?.requestCreateSource(payment) { _ in
            cell?.accessoryView = oldAccessoryView
            self.view.isUserInteractionEnabled = true
        }
 */
    }

    /*
    func goToAtome() {
        let vc = AtomeFormViewController(viewModel: AtomeFormViewModel(flowSession: flowSession))
        vc.preferredPrimaryColor = self.preferredPrimaryColor
        vc.preferredSecondaryColor = self.preferredSecondaryColor

        navigationController?.pushViewController(vc, animated: true)
    }
     */

    func applyPaymentMethods(from capability: Capability) {
//        self.capability = capability
//        showsCreditCardPayment = capability.cardPaymentMethod != nil
//
//        allowedPaymentMethods = capability.paymentMethods.compactMap {
//            SourceType(rawValue: $0.name)
//        }

        updateShowingValues()
    }

    private func applyPrimaryColor() {
        guard isViewLoaded else {
            return
        }

//        paymentMethodNameLables.forEach {
//            $0.textColor = currentPrimaryColor
//        }
    }

    private func applySecondaryColor() {
        // Intentionally empty (SonarCloud warning fix)
    }

    private func updateShowingValues() {
        var paymentMethodsToShow = paymentOptions(from: allowedPaymentMethods)
        paymentMethodsToShow = appendCreditCardPayment(paymentOptions: paymentMethodsToShow)
        paymentMethodsToShow = filterTrueMoney(paymentOptions: paymentMethodsToShow)
        paymentMethodsToShow = filterShopeePay(paymentOptions: paymentMethodsToShow)
        showingValues = paymentMethodsToShow.reorder(by: PaymentChooserOption.sorting).map { option in
            return ViewContext(icon: option.listIcon, title: option.description, accessoryIcon: "Next", code: "")
        }

//        os_log("Payment Chooser: Showing options - %{private}@",
//               log: uiLogObject,
//               type: .info,
//               showingValues.map { $0.description }.joined(separator: ", "))
    }

    @IBAction private func requestToClose(_ sender: Any) {
        viewModel.flowSession?.requestToCancel()
    }
}

private extension PaymentChooserViewController {
    func paymentOptions(from sourceTypes: [SourceType]) -> [PaymentChooserOption] {
        let paymentOptions: [PaymentChooserOption] = sourceTypes.reduce(into: []) { (result, sourceType) in
            let paymentOptions = PaymentChooserOption.paymentOptions(for: sourceType)
            for paymentOption in paymentOptions where !result.contains(paymentOption) {
                result.append(paymentOption)
            }
        }
        return paymentOptions
    }

    func appendCreditCardPayment(paymentOptions: [PaymentChooserOption]) -> [PaymentChooserOption] {
        var filter = paymentOptions
        if showsCreditCardPayment {
            filter.insert(.creditCard, at: 0)
        }
        return filter
    }

    func filterTrueMoney(paymentOptions: [PaymentChooserOption]) -> [PaymentChooserOption] {
        var filter = paymentOptions
        if filter.contains(.truemoney) && filter.contains(.truemoneyJumpApp) {
            filter.removeAll { $0 == .truemoney }
        }
        return filter
    }

    func filterShopeePay(paymentOptions: [PaymentChooserOption]) -> [PaymentChooserOption] {
        var filter = paymentOptions
        if filter.contains(.shopeePay) && filter.contains(.shopeePayJumpApp) {
            filter.removeAll { $0 == .shopeePay }
        }
        return filter
    }
}
