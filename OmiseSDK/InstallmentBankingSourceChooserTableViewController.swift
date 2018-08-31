import UIKit


class InstallmentBankingSourceChooserTableViewController: AdaptableStaticTableViewController<PaymentInformation.Installment.Brand> {
    
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
