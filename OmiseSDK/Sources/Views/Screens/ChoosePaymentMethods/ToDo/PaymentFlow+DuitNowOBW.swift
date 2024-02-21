import UIKit

// extension ChoosePaymentCoordinator {
//    func createDuitNowOBWController(title: String) -> SelectPaymentController {
//        let listController = SelectPaymentController()
//        if #available(iOSApplicationExtension 11.0, *) {
//            listController.navigationItem.largeTitleDisplayMode = .never
//        }
//        listController.navigationItem.title = title
//        listController.navigationItem.backBarButtonItem = .empty
//
//        let banks = Source.Payment.DuitNowOBW.Bank.allCases.sorted {
//            $0.localizedTitle.localizedCaseInsensitiveCompare($1.localizedTitle) == .orderedAscending
//        }
//
//        listController.items = banks.map {
//            TableCellContext(
//                title: $0.localizedTitle,
//                icon: UIImage(omise: $0.iconName),
//                accessoryIcon: UIImage(omise: "Redirect")
//            )
//        }
//
//        listController.didSelectCellHandler = { [banks, weak listController] cell, indexPath in
//            guard let listController = listController else { return }
//
////            cell.startAccessoryActivityIndicator()
//            listController.lockUserInferface()
//
//            if let bank = banks.at(indexPath.row) {
//                print("Bank selected: \(bank)")
//            }
//
//            //            if let paymentMethod = viewModel.paymentMethod(at: indexPath.row) {
//            //                self.didSelectPaymentMethod(
//            //                    paymentMethod,
//            //                    listController: listController,
//            //                    delegate: delegate
//            //                )
//            //            }
//        }
//
//        return listController
//    }
// }
