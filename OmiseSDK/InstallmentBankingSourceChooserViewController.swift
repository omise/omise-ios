import UIKit
import os


@objc(OMSInstallmentBankingSourceChooserViewController)
class InstallmentBankingSourceChooserViewController: AdaptableStaticTableViewController<PaymentInformation.Installment.Brand>, PaymentSourceChooser, PaymentChooserUI {
    var flowSession: PaymentCreatorFlowSession?
    
    override var showingValues: [PaymentInformation.Installment.Brand] {
        didSet {
            if #available(iOSApplicationExtension 10.0, *) {
                os_log("Installment Brand Chooser: Showing options - %{private}@", log: uiLogObject, type: .info, showingValues.map({ $0.description }).joined(separator: ", "))
            }
        }
    }
    
    @IBOutlet var bankNameLabels: [UILabel]!
    
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
    }
    
    override func staticIndexPath(forValue value: PaymentInformation.Installment.Brand) -> IndexPath {
        switch value {
        case .bbl:
            return IndexPath(row: 0, section: 0)
        case .kBank:
            return IndexPath(row: 1, section: 0)
        case .bay:
            return IndexPath(row: 2, section: 0)
        case .firstChoice:
            return IndexPath(row: 3, section: 0)
        case .ktc:
            return IndexPath(row: 4, section: 0)
        case .other(_):
            preconditionFailure("This value is not supported for built-in chooser")
        }
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let cell = cell as? PaymentOptionTableViewCell {
            cell.separatorView.backgroundColor = currentSecondaryColor
        }
        cell.accessoryView?.tintColor = currentSecondaryColor
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        let selectedBrand = element(forUIIndexPath: indexPath)
        if #available(iOSApplicationExtension 10.0, *) {
            os_log("Installment Brand Chooser: %{private}@ was selected", log: uiLogObject, type: .info, selectedBrand.description)
        }
        
        performSegue(withIdentifier: "GoToInstallmentTermsChooserSegue", sender: cell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        let selectedBrand = element(forUIIndexPath: indexPath)
        if segue.identifier == "GoToInstallmentTermsChooserSegue",
            let installmentTermsChooserViewController = segue.destination as? InstallmentsNumberOfTermsChooserViewController {
            installmentTermsChooserViewController.installmentBrand = selectedBrand
            installmentTermsChooserViewController.flowSession = self.flowSession
            installmentTermsChooserViewController.preferredPrimaryColor = self.preferredPrimaryColor
            installmentTermsChooserViewController.preferredSecondaryColor = self.preferredSecondaryColor
        }
    }
    
    private func applyPrimaryColor() {
        guard isViewLoaded else {
            return
        }
        
        bankNameLabels.forEach({
            $0.textColor = currentPrimaryColor
        })
    }
    
    private func applySecondaryColor() {
    }
}

