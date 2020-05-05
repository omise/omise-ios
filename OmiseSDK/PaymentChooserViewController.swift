import UIKit
import os


enum PaymentChooserOption: StaticElementIterable, Equatable, CustomStringConvertible {
    case creditCard
    case installment
    case internetBanking
    case tescoLotus
    case conbini
    case payEasy
    case netBanking
    case alipay
    case promptpay
    case paynow
    case truemoney
    case citiPoints
    
    static var allCases: [PaymentChooserOption] {
        return [
            .creditCard,
            .installment,
            .truemoney,
            .promptpay,
            .citiPoints,
            .alipay,
            .internetBanking,
            .tescoLotus,
            .paynow,
            .conbini,
            .payEasy,
            .netBanking
        ]
    }
    
    var description: String {
        switch self {
        case .creditCard:
            return "Credit Card"
        case .installment:
            return "Installment"
        case .internetBanking:
            return "InternetBanking"
        case .tescoLotus:
            return "Tesco Lotus"
        case .conbini:
            return "Conbini"
        case .payEasy:
            return "PayEasy"
        case .netBanking:
            return "NetBanking"
        case .alipay:
            return "Alipay"
        case .promptpay:
            return "PromptPay"
        case .paynow:
            return "PayNow"
        case .truemoney:
            return "TrueMoney"
        case .citiPoints:
            return "CitiPoints"
        }
    }
}

extension PaymentChooserOption {
    fileprivate static func paymentOptions(for sourceType: OMSSourceTypeValue) -> [PaymentChooserOption] {
        switch sourceType {
        case .trueMoney:
            return [.truemoney]
        case .installmentFirstChoice, .installmentKBank, .installmentKTC, .installmentBBL, .installmentBAY:
            return [.installment]
        case .billPaymentTescoLotus:
            return [.tescoLotus]
        case .eContext:
            return [.conbini, .payEasy, .netBanking]
        case .alipay:
            return [.alipay]
        case .internetBankingBAY, .internetBankingKTB, .internetBankingBBL, .internetBankingSCB:
            return [.internetBanking]
        case .payNow:
            return [.paynow]
        case .promptPay:
            return [.promptpay]
        case .pointsCiti:
            return [.citiPoints]
        case .barcodeAlipay:
            return []
        default:
            return []
        }
    }
}


@objc(OMSPaymentChooserViewController)
class PaymentChooserViewController: AdaptableStaticTableViewController<PaymentChooserOption>, PaymentSourceChooser, PaymentChooserUI {
    
    var flowSession: PaymentCreatorFlowSession?
    
    @objc var showsCreditCardPayment: Bool = true {
        didSet {
            updateShowingValues()
        }
    }
    @objc var allowedPaymentMethods: [OMSSourceTypeValue] = [] {
        didSet {
            updateShowingValues()
        }
    }
    
    @IBOutlet var paymentMethodNameLables: [UILabel]!
    
    @IBInspectable @objc var preferredPrimaryColor: UIColor? {
        didSet {
            applyPrimaryColor()
        }
    }
    
    @IBInspectable @objc var preferredSecondaryColor: UIColor? {
        didSet {
            applySecondaryColor()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        applyPrimaryColor()
        applySecondaryColor()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        #if compiler(>=5.1)
        if #available(iOS 13, *) {
            let appearance = navigationItem.scrollEdgeAppearance ?? UINavigationBarAppearance(idiom: .phone)
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.headings
            ]
            appearance.largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.headings
            ]
            appearance.shadowColor = nil
            navigationItem.scrollEdgeAppearance = appearance
        }
        #endif
        
        updateShowingValues()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier, segue.destination) {
        case ("GoToCreditCardFormSegue"?, let controller as CreditCardFormViewController):
            controller.publicKey = flowSession?.client?.publicKey
            controller.delegate = flowSession
            controller.navigationItem.rightBarButtonItem = nil
        case ("GoToInternetBankingChooserSegue"?, let controller as InternetBankingSourceChooserViewController):
            controller.showingValues = allowedPaymentMethods.compactMap({ $0.internetBankingSource })
            controller.flowSession = self.flowSession
        case ("GoToInstallmentBrandChooserSegue"?, let controller as InstallmentBankingSourceChooserViewController):
            controller.showingValues = allowedPaymentMethods.compactMap({ $0.installmentBrand })
            controller.flowSession = self.flowSession
        case (_, let controller as EContextInformationInputViewController):
            controller.flowSession = self.flowSession
            if let element = (sender as? UITableViewCell).flatMap(tableView.indexPath(for:)).map(element(forUIIndexPath:)) {
                switch element {
                case .conbini:
                    controller.navigationItem.title = NSLocalizedString(
                        "econtext.convenience-store.navigation-item.title",
                        bundle: Bundle.omiseSDKBundle, value: "Konbini",
                        comment: "A navigaiton title for the EContext screen when the `Konbini` is selected"
                    )
                case .netBanking:
                    controller.navigationItem.title = NSLocalizedString(
                        "econtext.netbanking.navigation-item.title",
                        bundle: Bundle.omiseSDKBundle, value: "Net Bank",
                        comment: "A navigaiton title for the EContext screen when the `Net Bank` is selected"
                    )
                case .payEasy:
                    controller.navigationItem.title = NSLocalizedString(
                        "econtext.pay-easy.navigation-item.title",
                        bundle: Bundle.omiseSDKBundle, value: "Pay-easy",
                        comment: "A navigaiton title for the EContext screen when the `Pay-easy` is selected"
                    )
                default: break
                }
            }
        case ("GoToTrueMoneyFormSegue"?, let controller as TrueMoneyFormViewController):
            controller.flowSession = self.flowSession
        default: break
        }
        
        if let paymentShourceChooserUI = segue.destination as? PaymentChooserUI {
            paymentShourceChooserUI.preferredPrimaryColor = self.preferredPrimaryColor
            paymentShourceChooserUI.preferredSecondaryColor = self.preferredSecondaryColor
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let cell = cell as? PaymentOptionTableViewCell {
            cell.separatorView.backgroundColor = currentSecondaryColor
        }
        cell.accessoryView?.tintColor = currentSecondaryColor
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        dismissErrorMessage(animated: true, sender: cell)
        tableView.deselectRow(at: indexPath, animated: true)
        let payment: PaymentInformation
        
        let selectedType = element(forUIIndexPath: indexPath)
        
        if #available(iOS 10, *) {
            os_log("Payment Chooser: %{private}@ was selected", log: uiLogObject, type: .info, selectedType.description)
        }
        switch selectedType {
        case .alipay:
            payment = .alipay
        case .tescoLotus:
            payment = .billPayment(.tescoLotus)
        case .promptpay:
            payment = .promptpay
        case .paynow:
            payment = .paynow
        case .citiPoints:
            payment = .points(.citiPoints)
        default:
            return
        }
        
        let oldAccessoryView = cell?.accessoryView
        #if swift(>=4.2)
        let loadingIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        #else
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        #endif
        loadingIndicator.color = currentSecondaryColor
        cell?.accessoryView = loadingIndicator
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        flowSession?.requestCreateSource(payment, completionHandler: { _ in
            cell?.accessoryView = oldAccessoryView
            self.view.isUserInteractionEnabled = true
        })
    }
    
    override func staticIndexPath(forValue value: PaymentChooserOption) -> IndexPath {
        switch value {
        case .creditCard:
            return IndexPath(row: 0, section: 0)
        case .installment:
            return IndexPath(row: 1, section: 0)
        case .truemoney:
            return IndexPath(row: 2, section: 0)
        case .promptpay:
            return IndexPath(row: 3, section: 0)
        case .citiPoints:
            return IndexPath(row: 4, section: 0)
        case .alipay:
            return IndexPath(row: 5, section: 0)
        case .internetBanking:
            return IndexPath(row: 6, section: 0)
        case .tescoLotus:
            return IndexPath(row: 7, section: 0)
        case .paynow:
            return IndexPath(row: 8, section: 0)
        case .conbini:
            return IndexPath(row: 9, section: 0)
        case .payEasy:
            return IndexPath(row: 10, section: 0)
        case .netBanking:
            return IndexPath(row: 11, section: 0)
        }
    }
    
    public func applyPaymentMethods(from capability: Capability) {
        showsCreditCardPayment = capability.creditCardBackend != nil
        allowedPaymentMethods = capability.supportedBackends.compactMap({
            switch $0.payment {
            case .alipay:
                return OMSSourceTypeValue.alipay
            case .promptpay:
                return OMSSourceTypeValue.promptPay
            case .paynow:
                return OMSSourceTypeValue.payNow
            case .truemoney:
                return OMSSourceTypeValue.trueMoney
            case .points(let points):
                return OMSSourceTypeValue(points.type)
            case .installment(let brand, availableNumberOfTerms: _):
                return OMSSourceTypeValue(brand.type)
            case .internetBanking(let bank):
                return OMSSourceTypeValue(bank.type)
            case .billPayment(let billPayment):
                return OMSSourceTypeValue(billPayment.type)
            case .eContext:
                return OMSSourceTypeValue.eContext
            case .card, .unknownSource:
                return nil
            }
        })
        
        updateShowingValues()
    }
    
    private func loadCapabilityData() {
        flowSession?.client?.capabilityDataWithCompletionHandler({ (result) in
            switch result {
            case .success(let capability):
                self.applyPaymentMethods(from: capability)
            case .failure:
                break
            }
        })
    }
    
    private func applyPrimaryColor() {
        guard isViewLoaded else {
            return
        }
        
        paymentMethodNameLables.forEach({
            $0.textColor = currentPrimaryColor
        })
    }
    
    private func applySecondaryColor() {}
    
    private func updateShowingValues() {
        var paymentMethodsToShow: [PaymentChooserOption] = allowedPaymentMethods.reduce(into: []) { (result, sourceType) in
            let paymentOptions = PaymentChooserOption.paymentOptions(for: sourceType)
            for paymentOption in paymentOptions where !result.contains(paymentOption) {
                result.append(paymentOption)
            }
        }
        
        if showsCreditCardPayment {
            paymentMethodsToShow.insert(.creditCard, at: 0)
        }
        
        showingValues = paymentMethodsToShow
        
        if #available(iOS 10, *) {
            os_log(
                "Payment Chooser: Showing options - %{private}@",
                log: uiLogObject, type: .info,
                showingValues.map({ $0.description }).joined(separator: ", ")
            )
        }
    }
    
    @IBAction func requestToClose(_ sender: Any) {
        flowSession?.requestToCancel()
    }
}
