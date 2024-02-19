import UIKit

extension PaymentFlow {
    struct ChoosePaymentMethodFactory {
        // MARK: ViewController
        func createViewController(onCloseHandler: @escaping () -> Void) -> TableListController {
            let listController = TableListController()

            listController.navigationItem.backBarButtonItem = .empty
            listController.navigationItem.rightBarButtonItem = ClosureBarButtonItem(
                image: UIImage(omise: "Close"),
                style: .plain) { _ in
                    onCloseHandler()
            }

            listController.navigationItem.title = localized("paymentMethods.title", text: "Payment Methods")
            listController.prefersLargeTitles = true
            return listController
        }

        // MARK: ViewModel
        func createViewModel(
            client: Client,
            allowedPaymentMethods: [SourceType] = [],
            allowedCardPayment: Bool = true,
            usePaymentMethodsFromCapability: Bool
        ) -> ChoosePaymentMethodViewModel {
            let viewModel = ChoosePaymentMethodViewModel()

            if usePaymentMethodsFromCapability {
                viewModel.setupCapabilityPaymentMethods(client: client)
            } else {
                viewModel.setupAllowedPaymentMethods(
                    allowedPaymentMethods,
                    allowedCardPayment: allowedCardPayment,
                    client: client
                )
            }
            return viewModel
        }

        // MARK: Data Source
        func createTableDataSource(
            for viewModel: ChoosePaymentMethodViewModel,
            listController: TableListController
        ) -> TableDataSource<TableCellContext> {
            let dataSource = TableDataSource<TableCellContext>(tableView: listController.tableView)
            dataSource.cellSetupClosure = dataSource.createDefaultCellSetupClosure()

            viewModel.onPaymentMethodChanged = { [weak dataSource] viewContexts in
                dataSource?.values = viewContexts
            }
            return dataSource
        }

        // MARK: Table Delegate
        func createTableDelegate(
            viewModel: ChoosePaymentMethodViewModel,
            listController: TableListController,
            completion: @escaping (PaymentFlow.ResultState) -> Void
        ) -> TableDelegate {
            let listDelegate = TableDelegate()
            listDelegate.didSelectCellClosure = { [weak viewModel, weak listController] (_, cell, indexPath) in
                guard let viewModel = viewModel,
                      let listController = listController else {
                    return
                }

                if viewModel.showsActivityForSelectedPaymentMethod(at: indexPath.row) {
                    cell.startAccessoryActivityIndicator()
                    listController.lockUserInferface()
                }

                if let payment = viewModel.paymentMethod(at: indexPath.row) {
                    completion(.selectedPaymentMethod(payment))
                }
            }
            return listDelegate
        }
    }
}
