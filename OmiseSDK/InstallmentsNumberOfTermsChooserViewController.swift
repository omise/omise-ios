import UIKit

@objc(OMSInstallmentsNumberOfTermsChooserViewController)
// swiftlint:disable:next type_name
class InstallmentsNumberOfTermsChooserViewController: UITableViewController, PaymentSourceChooser, PaymentChooserUI {
    var flowSession: PaymentCreatorFlowSession?
    
    var installmentBrand: PaymentInformation.Installment.Brand? {
        didSet {
            numberOfTerms = installmentBrand.map(PaymentInformation.Installment.availableTerms(for:)).map(Array.init) ?? []
            
            let title: String
            switch installmentBrand {
            case .bay?:
                title = NSLocalizedString(
                    "installment-number-of-terms-choosers.bbl.navigation-item.title",
                    bundle: .module,
                    value: "Krungsri",
                    comment: "A navigation title for the choosing installment terms screen with the `Krungsri` selected"
                )
            case .firstChoice?:
                title = NSLocalizedString(
                    "installment-number-of-terms-choosers.ktc.navigation-item.title",
                    bundle: .module,
                    value: "Krungsri First Choice",
                    comment: "A navigation title for the choosing installment terms screen with the `Krungsri First Choice` selected"
                )
            case .bbl?:
                title = NSLocalizedString(
                    "installment-number-of-terms-choosers.bay.navigation-item.title",
                    bundle: .module,
                    value: "Bangkok Bank",
                    comment: "A navigation title for the choosing installment terms screen with the `Bangkok Bank` selected"
                )
            case .ezypay?:
                title = NSLocalizedString(
                    "installment-number-of-terms-choosers.ezypay.navigation-item.title",
                    bundle: .module,
                    value: "Ezypay",
                    comment: "A navigation title for the choosing installment terms screen with the `Ezypay` selected"
                )
            case .ktc?:
                title = NSLocalizedString(
                    "installment-number-of-terms-choosers.k-bank.navigation-item.title",
                    bundle: .module,
                    value: "KTC",
                    comment: "A navigation title for the choosing installment terms screen with the `KTC` selected"
                )
            case .kBank?:
                title = NSLocalizedString(
                    "installment-number-of-terms-choosers.first-choice.navigation-item.title",
                    bundle: .module,
                    value: "Kasikorn",
                    comment: "A navigation title for the choosing installment terms screen with the `Kasikorn` selected"
                )
            case .scb?:
                title = NSLocalizedString(
                    "installment-number-of-terms-choosers.scb.navigation-item.title",
                    bundle: .module,
                    value: "SCB",
                    comment: "A navigation title for the choosing installment terms screen with the `SCB` selected"
                )
            case .citi?:
                title = NSLocalizedString(
                    "installment-number-of-terms-choosers.citi.navigation-item.title",
                    bundle: .module,
                    value: "Citi",
                    comment: "A navigation title for the choosing installment terms screen with the `Citi` selected"
                )
            case .ttb?:
                title = NSLocalizedString(
                    "installment-number-of-terms-choosers.ttb.navigation-item.title",
                    bundle: .module,
                    value: "TTB",
                    comment: "A navigation title for the choosing installment terms screen with the `TTB` selected"
                )
            case .uob?:
                title = NSLocalizedString(
                    "installment-number-of-terms-choosers.uob.navigation-item.title",
                    bundle: .module,
                    value: "UOB",
                    comment: "A navigation title for the choosing installment terms screen with the `UOB` selected"
                )
            case .other?, nil:
                title = NSLocalizedString(
                    "installment-number-of-terms-choosers.default.navigation-item.title",
                    bundle: .module,
                    value: "Installments Terms",
                    comment: "A navigation title for the choosing installment terms screen with the `Installments Terms` selected"
                )
            }
            
            navigationItem.title = title
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
            bundle: .module,
            value: "%d months",
            comment: "Number of terms option text displayed as a title of the number of terms option cell in number of terms chooser scene"
        )
        cell.textLabel?.text = String.localizedStringWithFormat(numberOfTermsTitleFormat, numberOfTerms[indexPath.row])
        cell.textLabel?.textColor = currentPrimaryColor
        
        if let cell = cell as? PaymentOptionTableViewCell {
            cell.separatorView.backgroundColor = currentSecondaryColor
        }
        cell.accessoryView?.tintColor = currentSecondaryColor
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        guard let brand = installmentBrand else {
            return
        }
        
        let oldAccessoryView = cell?.accessoryView
        let loadingIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        loadingIndicator.color = currentSecondaryColor
        cell?.accessoryView = loadingIndicator
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        let numberOfTerms = self.numberOfTerms[indexPath.row]
        flowSession?.requestCreateSource(.installment(PaymentInformation.Installment(brand: brand, numberOfTerms: numberOfTerms))) { _ in
            cell?.accessoryView = oldAccessoryView
            self.view.isUserInteractionEnabled = true
        }
    }
    
    private func applyPrimaryColor() {}
    
    private func applySecondaryColor() {}
}
