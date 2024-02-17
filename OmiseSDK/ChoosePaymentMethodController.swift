import UIKit
import os

protocol PaymentChooserControllerViewModel {
    var viewContext: [ChoosePaymentMethodController.ViewContext] { get }
    var onViewContextChanged: ([ChoosePaymentMethodController.ViewContext]) -> Void { get }
}

/// swiftlint:disable:next type_body_length
class ChoosePaymentMethodController: UITableViewController {
    struct ViewContext: Equatable {
        let icon: UIImage?
        let title: String
        let accessoryIcon: UIImage?
    }

    let viewModel = ChoosePaymentMethodViewModel()

    func reloadIfViewIsLoaded() {
        if isViewLoaded {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.onViewContextChanged = { [weak self] _ in
            self?.reloadIfViewIsLoaded()
        }
        tableView.separatorColor = UIColor.omiseSecondary
        tableView.rowHeight = 64
        applyNavigationBarStyle()
        setupNavigationItems()
    }

    private func setupViewModel() {
    }

    private func setupNavigationItems() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(omise: "Close"),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )

        navigationItem.title = localized("paymentMethods.title", text: "Payment Methods")
        if #available(iOSApplicationExtension 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfViewContexts
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "UITableViewCell"
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier)

        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }

        let viewContext = viewModel.viewContext(at: indexPath.row)

        cell.textLabel?.text = viewContext?.title
        cell.textLabel?.font = .boldSystemFont(ofSize: 14.0)
        cell.textLabel?.textColor = UIColor.omisePrimary

        cell.imageView?.image = viewContext?.icon
        cell.accessoryView = UIImageView(image: viewContext?.accessoryIcon)

        cell.accessoryView?.tintColor = UIColor.omiseSecondary

        return cell
    }

    // swiftlint:disable:next function_body_length
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)

//        let option = item(at: indexPath)
//        switch option {
//        case .c
//
//        }
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
        loadingIndicator.color = UIColor.omiseSecondary
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

    @IBAction private func closeTapped(_ sender: Any) {
        viewModel.completion(.cancel)
    }
}
