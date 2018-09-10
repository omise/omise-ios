import UIKit

class InstallmentsNumberOfTermsChooserViewController: UITableViewController, PaymentSourceCreator, PaymentCreatorUI {
    var coordinator: PaymentCreatorTrampoline?
    var client: Client?
    var paymentAmount: Int64?
    var paymentCurrency: Currency?
    
    @IBOutlet var errorBannerView: UIView!
    @IBOutlet var errorMessageLabel: UILabel!
    
    @IBInspectable @objc public var preferredPrimaryColor: UIColor? {
        didSet {
            applyPrimaryColor()
        }
    }
    
    @IBInspectable @objc public var preferredSecondaryColor: UIColor? {
        didSet {
            applySecondaryColor()
        }
    }
    
    var installmentBrand: PaymentInformation.Installment.Brand? {
        didSet {
            numberOfTerms = installmentBrand.map(PaymentInformation.Installment.availableTerms(for:)).map(Array.init) ?? []
            
            let title: String
            switch installmentBrand {
            case .bay?:
                title = NSLocalizedString(
                    "installment-number-of-terms-choosers.bbl.navigation-item.title",
                    bundle: Bundle.omiseSDKBundle, value: "Krungsri",
                    comment:"A navigation title for the choosing installment terms screen with the `Krungsri` selected"
                )
            case .firstChoice?:
                title = NSLocalizedString(
                    "installment-number-of-terms-choosers.ktc.navigation-item.title",
                    bundle: Bundle.omiseSDKBundle, value: "Krungsri First Choice",
                    comment:"A navigation title for the choosing installment terms screen with the `Krungsri First Choice` selected"
                )
            case .bbl?:
                title = NSLocalizedString(
                    "installment-number-of-terms-choosers.bay.navigation-item.title",
                    bundle: Bundle.omiseSDKBundle, value: "Bangkok Bank",
                    comment:"A navigation title for the choosing installment terms screen with the `Bangkok Bank` selected"
                )
            case .ktc?:
                title = NSLocalizedString(
                    "installment-number-of-terms-choosers.k-bank.navigation-item.title",
                    bundle: Bundle.omiseSDKBundle, value: "KTC",
                    comment:"A navigation title for the choosing installment terms screen with the `KTC` selected"
                )
            case .kBank?:
                title = NSLocalizedString(
                    "installment-number-of-terms-choosers.first-choice.navigation-item.title",
                    bundle: Bundle.omiseSDKBundle, value: "Kasikorn",
                    comment:"A navigation title for the choosing installment terms screen with the `Kasikorn` selected"
                )
            case .other?, nil:
                title = NSLocalizedString(
                    "installment-number-of-terms-choosers.default.navigation-item.title",
                    bundle: Bundle.omiseSDKBundle, value: "Installments Terms",
                    comment:"A navigation title for the choosing installment terms screen with the `Installments Terms` selected"
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
            bundle: Bundle.omiseSDKBundle, value: "%d months",
            comment: "Number of terms option text displayed as a title of the number of terms option cell in number of terms chooser scene"
        )
        cell.textLabel?.text = String.localizedStringWithFormat(numberOfTermsTitleFormat, numberOfTerms[indexPath.row])
        cell.textLabel?.textColor = currentPrimaryColor
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
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        loadingIndicator.color = currentSecondaryColor
        cell?.accessoryView = loadingIndicator
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        let numberOfTerms = self.numberOfTerms[indexPath.row]
        requestCreateSource(
            .installment(PaymentInformation.Installment(brand: brand, numberOfTerms: numberOfTerms)),
            completionHandler: { _ in
                cell?.accessoryView = oldAccessoryView
                self.view.isUserInteractionEnabled = true
        })
    }
    
    func displayErrorMessage(_ errorMessage: String, animated: Bool) {
        
    }
    
    func dismissErrorBanner(animated: Bool) {
        
    }
    
    private func applyPrimaryColor() {}
    
    private func applySecondaryColor() {}
}

