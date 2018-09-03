import UIKit

@objc(OMSInstallmentBankingSourceChooserViewController)
class InstallmentBankingSourceChooserViewController: AdaptableStaticTableViewController<PaymentInformation.Installment.Brand>, PaymentSourceCreator {
    var coordinator: PaymentCreatorTrampoline?
    var client: Client?
    var paymentAmount: Int64?
    var paymentCurrency: Currency?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
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
            installmentTermsChooserViewController.coordinator = self.coordinator
            installmentTermsChooserViewController.client = self.client
            installmentTermsChooserViewController.paymentAmount = self.paymentAmount
            installmentTermsChooserViewController.paymentCurrency = self.paymentCurrency
        }
    }
    
}

#if swift(>=4.2)
#else
extension PaymentInformation.Installment.Brand: StaticElementIterable {
    public static let allCases: [PaymentInformation.Installment.Brand] = [
        .bbl,
        .kBank,
        .bay,
        .firstChoice,
        .ktc,
        ]
}
#endif