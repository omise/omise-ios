import UIKit

class InternetBankingSourceChooserViewController: AdaptableStaticTableViewController<PaymentInformation.InternetBanking>, PaymentCreator {
    var coordinator: PaymentCreatorTrampoline?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        case .other(_):
            preconditionFailure("This value is not supported for built-in chooser")
        }
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
