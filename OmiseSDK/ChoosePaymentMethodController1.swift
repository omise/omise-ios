import UIKit

//class ChoosePaymentMethodController: TableListController {
//    
//    var closeDidTapClosure: (() -> Void)?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupNavigationBar()
//    }
//}
//
//private extension ChoosePaymentMethodController {
//    private func setupNavigationBar() {
//        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            image: UIImage(omise: "Close"),
//            style: .plain,
//            target: self,
//            action: #selector(closeDidTap)
//        )
//
//        navigationItem.title = localized("paymentMethods.title", text: "Payment Methods")
//        prefersLargeTitles = true
//    }
//
//    @objc func closeDidTap(_ sender: Any) {
//        closeDidTapClosure?()
//    }
//}
