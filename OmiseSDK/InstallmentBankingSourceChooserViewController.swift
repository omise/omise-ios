import UIKit
import os

// swiftlint:disable:next type_name
class InstallmentBankingSourceChooserViewController: AdaptableStaticTableViewController<SourceType>,
                                                     PaymentSourceChooser,
                                                     PaymentChooserUI {
    var flowSession: PaymentCreatorFlowSession?
    
    override var showingValues: [SourceType] {
        didSet {
            os_log("Installment Brand Chooser: Showing options - %{private}@",
                   log: uiLogObject,
                   type: .info,
                   showingValues.map { $0.rawValue }.joined(separator: ", "))
        }
    }
    
    @IBOutlet var bankNameLabels: [UILabel]!
    
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
    
    override func staticIndexPath(forValue value: SourceType) -> IndexPath {
        switch value {
        case .installmentBBL:
            return IndexPath(row: 0, section: 0)
        case .installmentKBank:
            return IndexPath(row: 1, section: 0)
        case .installmentBAY:
            return IndexPath(row: 2, section: 0)
        case .installmentFirstChoice:
            return IndexPath(row: 3, section: 0)
        case .installmentKTC:
            return IndexPath(row: 4, section: 0)
        case .installmentMBB:
            return IndexPath(row: 5, section: 0)
        case .installmentSCB:
            return IndexPath(row: 6, section: 0)
        case .installmentTTB:
            return IndexPath(row: 7, section: 0)
        case .installmentUOB:
            return IndexPath(row: 8, section: 0)
        default:
            preconditionFailure("This value is not supported for built-in chooser")
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
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        let selectedBrand = element(forUIIndexPath: indexPath)
//        os_log("Installment Brand Chooser: %{private}@ was selected", log: uiLogObject, type: .info, selectedBrand.description)

        performSegue(withIdentifier: "GoToInstallmentTermsChooserSegue", sender: cell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        let sourceType = element(forUIIndexPath: indexPath)
        if segue.identifier == "GoToInstallmentTermsChooserSegue",
           let installmentTermsChooserViewController = segue.destination as? InstallmentsNumberOfTermsChooserViewController {
            installmentTermsChooserViewController.sourceType = sourceType
            installmentTermsChooserViewController.flowSession = self.flowSession
            installmentTermsChooserViewController.preferredPrimaryColor = self.preferredPrimaryColor
            installmentTermsChooserViewController.preferredSecondaryColor = self.preferredSecondaryColor
        }
    }
    
    private func applyPrimaryColor() {
        guard isViewLoaded else {
            return
        }
        
        bankNameLabels.forEach {
            $0.textColor = currentPrimaryColor
        }
    }
    
    private func applySecondaryColor() {
        // Intentionally empty (SonarCloud warning fix)
    }
}
