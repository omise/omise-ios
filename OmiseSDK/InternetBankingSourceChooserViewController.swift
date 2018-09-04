import UIKit

@objc(OMSInternetBankingSourceChooserViewController)
class InternetBankingSourceChooserViewController: AdaptableStaticTableViewController<PaymentInformation.InternetBanking>, PaymentSourceCreator {
    var coordinator: PaymentCreatorTrampoline?
    var client: Client?
    var paymentAmount: Int64?
    var paymentCurrency: Currency?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    public override func staticIndexPath(forValue value: PaymentInformation.InternetBanking) -> IndexPath {
        switch value {
        case .bbl:
            return IndexPath(row: 0, section: 0)
        case .scb:
            return IndexPath(row: 1, section: 0)
        case .bay:
            return IndexPath(row: 2, section: 0)
        case .ktb:
            return IndexPath(row: 3, section: 0)
        case .other:
            preconditionFailure("This value is not supported for the built-in chooser")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        let bank = element(forUIIndexPath: indexPath)
        
        let oldAccessoryView = cell?.accessoryView
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        loadingIndicator.color = #colorLiteral(red: 0.3065422177, green: 0.3197538555, blue: 0.3728331327, alpha: 1)
        cell?.accessoryView = loadingIndicator
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        requestCreateSource(.internetBanking(bank), completionHandler: { _ in
            cell?.accessoryView = oldAccessoryView
            self.view.isUserInteractionEnabled = true
        })
    }
}


#if swift(>=4.2)
#else
extension PaymentInformation.InternetBanking: StaticElementIterable {
    public static let allCases: [PaymentInformation.InternetBanking] = [
        .bay,
        .ktb,
        .scb,
        .bbl,
        ]
}
#endif
