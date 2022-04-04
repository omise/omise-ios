// swiftlint:disable file_length
import UIKit
import os

enum PaymentChooserOption: CaseIterable, Equatable, CustomStringConvertible {
    case creditCard
    case installment
    case internetBanking
    case mobileBanking
    case tescoLotus
    case conbini
    case payEasy
    case netBanking
    case alipay
    case alipayCN
    case alipayHK
    case dana
    case gcash
    case kakaoPay
    case touchNGo
    case promptpay
    case paynow
    case truemoney
    case citiPoints
    case fpx
    case rabbitLinepay

    static var allCases: [PaymentChooserOption] {
        return [
            .creditCard,
            .installment,
            .truemoney,
            .promptpay,
            .citiPoints,
            .alipay,
            .alipayCN,
            .alipayHK,
            .dana,
            .gcash,
            .kakaoPay,
            .touchNGo,
            .internetBanking,
            .mobileBanking,
            .tescoLotus,
            .paynow,
            .conbini,
            .payEasy,
            .netBanking,
            .fpx,
            .rabbitLinepay
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
        case .mobileBanking:
            return "MobileBanking"
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
        case .alipayCN:
            return "Alipay CN"
        case .alipayHK:
            return "Alipay HK"
        case .dana:
            return "DANA"
        case .gcash:
            return "GCash"
        case .kakaoPay:
            return "Kakao Pay"
        case .touchNGo:
            return "TNG eWallet"
        case .promptpay:
            return "PromptPay"
        case .paynow:
            return "PayNow"
        case .truemoney:
            return "TrueMoney"
        case .citiPoints:
            return "CitiPoints"
        case .fpx:
            return "FPX"
        case .rabbitLinepay:
            return "Rabbit LINE Pay"
        }
    }
}

extension PaymentChooserOption {
    // swiftlint:disable function_body_length
    fileprivate static func paymentOptions(for sourceType: OMSSourceTypeValue) -> [PaymentChooserOption] {
        switch sourceType {
        case .trueMoney:
            return [.truemoney]
        case .installmentFirstChoice, .installmentEzypay, .installmentKBank, .installmentKTC,
             .installmentBBL, .installmentBAY, .installmentSCB, .installmentCiti, .installmentTTB, .installmentUOB:
            return [.installment]
        case .billPaymentTescoLotus:
            return [.tescoLotus]
        case .eContext:
            return [.conbini, .payEasy, .netBanking]
        case .alipay:
            return [.alipay]
        case .alipayCN:
            return [.alipayCN]
        case .alipayHK:
            return [.alipayHK]
        case .dana:
            return [.dana]
        case .gcash:
            return [.gcash]
        case .kakaoPay:
            return [.kakaoPay]
        case .touchNGo:
            return [.touchNGo]
        case .internetBankingBAY, .internetBankingKTB, .internetBankingBBL, .internetBankingSCB:
            return [.internetBanking]
        case .mobileBankingSCB, .mobileBankingKBank, .mobileBankingOCBCPAO, .mobileBankingBAY, .mobileBankingBBL:
            return [.mobileBanking]
        case .payNow:
            return [.paynow]
        case .promptPay:
            return [.promptpay]
        case .pointsCiti:
            return [.citiPoints]
        case .barcodeAlipay:
            return []
        case .fpx:
            return [.fpx]
        case .rabbitLinepay:
            return [.rabbitLinepay]
        default:
            return []
        }
    }
}

@objc(OMSPaymentChooserViewController)
// swiftlint:disable type_body_length
class PaymentChooserViewController: AdaptableStaticTableViewController<PaymentChooserOption>,
                                    PaymentSourceChooser,
                                    PaymentChooserUI {
    var capability: Capability?
    var flowSession: PaymentCreatorFlowSession?

    @objc var showsCreditCardPayment = true {
        didSet {
            updateShowingValues()
        }
    }
    @objc var allowedPaymentMethods: [OMSSourceTypeValue] = [] {
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

    // swiftlint:disable function_body_length
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier, segue.destination) {
        case ("GoToCreditCardFormSegue"?, let controller as CreditCardFormViewController):
            controller.publicKey = flowSession?.client?.publicKey
            controller.delegate = flowSession
            controller.navigationItem.rightBarButtonItem = nil
        case ("GoToInternetBankingChooserSegue"?, let controller as InternetBankingSourceChooserViewController):
            controller.showingValues = allowedPaymentMethods.compactMap({ $0.internetBankingSource })
            controller.flowSession = self.flowSession
        case ("GoToMobileBankingChooserSegue"?, let controller as MobileBankingSourceChooserViewController):
            controller.showingValues = allowedPaymentMethods.compactMap({ $0.mobileBankingSource })
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
                        bundle: .module,
                        value: "Konbini",
                        comment: "A navigaiton title for the EContext screen when the `Konbini` is selected"
                    )
                case .netBanking:
                    controller.navigationItem.title = NSLocalizedString(
                        "econtext.netbanking.navigation-item.title",
                        bundle: .module,
                        value: "Net Bank",
                        comment: "A navigaiton title for the EContext screen when the `Net Bank` is selected"
                    )
                case .payEasy:
                    controller.navigationItem.title = NSLocalizedString(
                        "econtext.pay-easy.navigation-item.title",
                        bundle: .module,
                        value: "Pay-easy",
                        comment: "A navigaiton title for the EContext screen when the `Pay-easy` is selected"
                    )
                default: break
                }
            }
        case ("GoToTrueMoneyFormSegue"?, let controller as TrueMoneyFormViewController):
            controller.flowSession = self.flowSession
        case ("GoToFPXFormSegue"?, let controller as FPXFormViewController):
            controller.showingValues = capability?[.fpx]?.banks ?? []
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
        tableView.deselectRow(at: indexPath, animated: true)
        let payment: PaymentInformation

        let selectedType = element(forUIIndexPath: indexPath)

        os_log("Payment Chooser: %{private}@ was selected", log: uiLogObject, type: .info, selectedType.description)
        switch selectedType {
        case .alipay:
            payment = .alipay
        case .alipayCN:
            payment = .alipayCN
        case .alipayHK:
            payment = .alipayHK
        case .dana:
            payment = .dana
        case .gcash:
            payment = .gcash
        case .kakaoPay:
            payment = .kakaoPay
        case .touchNGo:
            payment = .touchNGo
        case .tescoLotus:
            payment = .billPayment(.tescoLotus)
        case .promptpay:
            payment = .promptpay
        case .paynow:
            payment = .paynow
        case .citiPoints:
            payment = .points(.citiPoints)
        case .rabbitLinepay:
            payment = .rabbitLinepay
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
        case .mobileBanking:
            return IndexPath(row: 12, section: 0)
        case .fpx:
            return IndexPath(row: 13, section: 0)
        case .alipayCN:
            return IndexPath(row: 14, section: 0)
        case .alipayHK:
            return IndexPath(row: 15, section: 0)
        case .dana:
            return IndexPath(row: 16, section: 0)
        case .gcash:
            return IndexPath(row: 17, section: 0)
        case .kakaoPay:
            return IndexPath(row: 18, section: 0)
        case .touchNGo:
            return IndexPath(row: 19, section: 0)
        case .rabbitLinepay:
            return IndexPath(row: 20, section: 0)

        }
    }

    func applyPaymentMethods(from capability: Capability) {
        self.capability = capability
        showsCreditCardPayment = capability.creditCardBackend != nil

        // swiftlint:disable closure_body_length
        allowedPaymentMethods = capability.supportedBackends.compactMap {
            switch $0.payment {
            case .alipay:
                return OMSSourceTypeValue.alipay
            case .alipayCN:
                return OMSSourceTypeValue.alipayCN
            case .alipayHK:
                return OMSSourceTypeValue.alipayHK
            case .dana:
                return OMSSourceTypeValue.dana
            case .gcash:
                return OMSSourceTypeValue.gcash
            case .kakaoPay:
                return OMSSourceTypeValue.kakaoPay
            case .touchNGo:
                return OMSSourceTypeValue.touchNGo
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
            case .mobileBanking(let bank):
                return OMSSourceTypeValue(bank.type)
            case .fpx:
                return OMSSourceTypeValue.fpx
            case .rabbitLinepay:
                return OMSSourceTypeValue.rabbitLinepay
            case .card, .unknownSource:
                return nil
            }
        }

        updateShowingValues()
    }

    private func loadCapabilityData() {
        flowSession?.client?.capabilityDataWithCompletionHandler { (result) in
            switch result {
            case .success(let capability):
                self.applyPaymentMethods(from: capability)
            case .failure:
                break
            }
        }
    }

    private func applyPrimaryColor() {
        guard isViewLoaded else {
            return
        }

        paymentMethodNameLables.forEach {
            $0.textColor = currentPrimaryColor
        }
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

        os_log("Payment Chooser: Showing options - %{private}@",
               log: uiLogObject,
               type: .info,
               showingValues.map { $0.description }.joined(separator: ", "))
    }

    @IBAction private func requestToClose(_ sender: Any) {
        flowSession?.requestToCancel()
    }
}
