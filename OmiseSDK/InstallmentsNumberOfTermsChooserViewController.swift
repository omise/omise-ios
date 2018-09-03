import UIKit

class InstallmentsNumberOfTermsChooserViewController: UITableViewController, PaymentSourceCreator {
    var coordinator: PaymentCreatorTrampoline?
    var client: Client?
    var paymentAmount: Int64?
    var paymentCurrency: Currency?
    
    var installmentBrand: PaymentInformation.Installment.Brand? {
        didSet {
            numberOfTerms = installmentBrand.map(PaymentInformation.Installment.availableTerms(for:)).map(Array.init) ?? []
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

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfTerms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NumberOfTermCell", for: indexPath)
        cell.textLabel?.text = "\(numberOfTerms[indexPath.row])"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let brand = installmentBrand else {
            return
        }
        
        let numberOfTerms = self.numberOfTerms[indexPath.row]
        requestCreateSource(PaymentInformation.installment(PaymentInformation.Installment(brand: brand, numberOfTerms: numberOfTerms)))
    }
}

