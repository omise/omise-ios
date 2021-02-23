import UIKit
import os


@objc(OMSFPXBankChooserViewController)
class FPXBankChooserViewController: AdaptableDynamicTableViewController<Capability.Backend.Bank>, PaymentSourceChooser, PaymentChooserUI {
    var flowSession: PaymentCreatorFlowSession?
    var defaultImage: String = "FPX/unknown"

    override var showingValues: [Capability.Backend.Bank] {
        didSet {
            os_log("FPX Bank Chooser: Showing options - %{private}@", log: uiLogObject, type: .info, showingValues.map({ $0.name }).joined(separator: ", "))
        }
    }
    
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
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let cell = cell as? PaymentOptionTableViewCell {
            cell.separatorView.backgroundColor = currentSecondaryColor
        }
        let bank = showingValues[indexPath.row]
        cell.accessoryView?.tintColor = currentSecondaryColor
        cell.textLabel?.text = bank.name
        cell.imageView?.image = bankImage(bank: bank.code)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        let selectedBrand = element(forUIIndexPath: indexPath)
        os_log("FPX Bank Chooser: %{private}@ was selected", log: uiLogObject, type: .info, selectedBrand.name)

        performSegue(withIdentifier: "GoToInstallmentTermsChooserSegue", sender: cell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else {
            return
        }
//        let selectedBrand = element(forUIIndexPath: indexPath)
//        if segue.identifier == "GoToInstallmentTermsChooserSegue",
//            let installmentTermsChooserViewController = segue.destination as? InstallmentsNumberOfTermsChooserViewController {
//            installmentTermsChooserViewController.installmentBrand = selectedBrand
//            installmentTermsChooserViewController.flowSession = self.flowSession
//            installmentTermsChooserViewController.preferredPrimaryColor = self.preferredPrimaryColor
//            installmentTermsChooserViewController.preferredSecondaryColor = self.preferredSecondaryColor
//        }
    }
    
    private func applyPrimaryColor() {
        guard isViewLoaded else {
            return
        }
        
//        bankNameLabels.forEach({
//            $0.textColor = currentPrimaryColor
//        })
    }
    
    private func applySecondaryColor() {
    }
    
    private func bankImage(bank: String) -> UIImage {
        if let image = UIImage(named: "FPX/" + bank, in: Bundle.omiseSDKBundle, compatibleWith: nil) {
            return image
        } else {
            return UIImage(named: defaultImage, in: Bundle.omiseSDKBundle, compatibleWith: nil)!
        }
    }
}

