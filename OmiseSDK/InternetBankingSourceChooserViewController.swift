import UIKit

@objc(OMSInternetBankingSourceChooserViewController)
class InternetBankingSourceChooserViewController: AdaptableStaticTableViewController<PaymentInformation.InternetBanking>, PaymentSourceChooser, PaymentCreatorUI, ErrorDisplayableUI {
    var flowSession: PaymentSourceCreatorFlowSession?
    var client: Client?
    var paymentAmount: Int64?
    var paymentCurrency: Currency?
    
    @IBOutlet var internetBankingNameLabels: [UILabel]!
    @IBOutlet var redirectIconImageView: [UIImageView]!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyPrimaryColor()
        applySecondaryColor()
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
        loadingIndicator.color = currentSecondaryColor
        cell?.accessoryView = loadingIndicator
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        flowSession?.requestCreateSource(.internetBanking(bank), completionHandler: { _ in
            cell?.accessoryView = oldAccessoryView
            self.view.isUserInteractionEnabled = true
        })
    }
    
    private func applyPrimaryColor() {
        guard isViewLoaded else {
            return
        }
        
        internetBankingNameLabels.forEach({
            $0.textColor = currentPrimaryColor
        })
    }
    
    private func applySecondaryColor() {
        guard isViewLoaded else {
            return
        }
        
        redirectIconImageView.forEach({
            $0.tintColor = currentSecondaryColor
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
