import UIKit
import os

// swiftlint:disable:next type_name
class InstallmentsNumberOfTermsChooserViewController: UITableViewController, PaymentSourceChooser {
    var flowSession: PaymentCreatorFlowSession?

    var sourceType: SourceType? {
        didSet {
            os_log("Installment Chooser: Showing options - %{private}@",
                   log: uiLogObject,
                   type: .info,
                   numberOfTerms.map { String($0) }.joined(separator: ", "))
            if let sourceType = sourceType {
                numberOfTerms = Source.Payment.Installment.availableTerms(for: sourceType)
                navigationItem.title = headerTitle(for: sourceType)
            } else {
                numberOfTerms = []
                navigationItem.title = ""
            }
        }
    }

    // swiftlint:disable:next function_body_length
    func headerTitle(for sourceType: SourceType) -> String {
        switch sourceType {
        case .installmentBAY:
            return NSLocalizedString(
                "installment-number-of-terms-choosers.bbl.navigation-item.title",
                bundle: .omiseSDK,
                value: "Krungsri",
                comment: "A navigation title for the choosing installment terms screen with the `Krungsri` selected"
            )
        case .installmentBBL:
            return NSLocalizedString(
                "installment-number-of-terms-choosers.bay.navigation-item.title",
                bundle: .omiseSDK,
                value: "Bangkok Bank",
                comment: "A navigation title for the choosing installment terms screen with the `Bangkok Bank` selected"
            )
        case .installmentFirstChoice:
            return NSLocalizedString(
                "installment-number-of-terms-choosers.ktc.navigation-item.title",
                bundle: .omiseSDK,
                value: "Krungsri First Choice",
                comment: "A navigation title for the choosing installment terms screen with the `Krungsri First Choice` selected"
            )
        case .installmentKBank:
            return NSLocalizedString(
                "installment-number-of-terms-choosers.first-choice.navigation-item.title",
                bundle: .omiseSDK,
                value: "Kasikorn",
                comment: "A navigation title for the choosing installment terms screen with the `Kasikorn` selected"
            )
        case .installmentKTC:
            return NSLocalizedString(
                "installment-number-of-terms-choosers.k-bank.navigation-item.title",
                bundle: .omiseSDK,
                value: "KTC",
                comment: "A navigation title for the choosing installment terms screen with the `KTC` selected"
            )
        case .installmentMBB:
            return NSLocalizedString(
                "installment-number-of-terms-choosers.mbb.navigation-item.title",
                bundle: .omiseSDK,
                value: "MBB",
                comment: "A navigation title for the choosing installment terms screen with the `MBB` selected"
            )
        case .installmentSCB:
            return NSLocalizedString(
                "installment-number-of-terms-choosers.scb.navigation-item.title",
                bundle: .omiseSDK,
                value: "SCB",
                comment: "A navigation title for the choosing installment terms screen with the `SCB` selected"
            )
        case .installmentTTB:
            return NSLocalizedString(
                "installment-number-of-terms-choosers.ttb.navigation-item.title",
                bundle: .omiseSDK,
                value: "TTB",
                comment: "A navigation title for the choosing installment terms screen with the `TTB` selected"
            )
        case .installmentUOB:
            return NSLocalizedString(
                "installment-number-of-terms-choosers.default.navigation-item.title",
                bundle: .omiseSDK,
                value: "Installments Terms",
                comment: "A navigation title for the choosing installment terms screen with the `Installments Terms` selected"
            )
        default:
            return ""
        }
    }

    var numberOfTerms: [Int] = [] {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    
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
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfTerms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NumberOfTermCell", for: indexPath)
        let numberOfTermsTitleFormat = NSLocalizedString(
            "installments.number-of-terms-chooser.number-of-terms-cell.label.text",
            bundle: .omiseSDK,
            value: "%d months",
            comment: "Number of terms option text displayed as a title of the number of terms option cell in number of terms chooser scene"
        )
        cell.textLabel?.text = String.localizedStringWithFormat(numberOfTermsTitleFormat, numberOfTerms[indexPath.row])
        cell.textLabel?.textColor = UIColor.omisePrimary
        
        if let cell = cell as? PaymentOptionTableViewCell {
            cell.separatorView.backgroundColor = UIColor.omiseSecondary
        }
        cell.accessoryView?.tintColor = UIColor.omiseSecondary
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sourceType = sourceType else { return }
        
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)

        let oldAccessoryView = cell?.accessoryView
        let loadingIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        loadingIndicator.color = UIColor.omiseSecondary
        cell?.accessoryView = loadingIndicator
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        let paymentInformation = Source.Payment.Installment(
            installmentTerm: self.numberOfTerms[indexPath.row],
            zeroInterestInstallments: false,
            sourceType: sourceType
        )

        flowSession?.requestCreateSource(.installment(paymentInformation)) { _ in
            cell?.accessoryView = oldAccessoryView
            self.view.isUserInteractionEnabled = true
        }
    }
    
    private func applyPrimaryColor() {
        // Intentionally empty (SonarCloud warning fix)
    }
    
    private func applySecondaryColor() {
        // Intentionally empty (SonarCloud warning fix)
    }
}
