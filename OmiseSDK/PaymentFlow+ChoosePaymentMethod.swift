import UIKit

extension PaymentFlow {

    /// Creates RootViewController and attach current flow object inside created controller to be deallocated together
    ///
    /// - Parameters:
    ///   - allowedPaymentMethods: List of Payment Methods to be presented in the list if `usePaymentMethodsFromCapability` is `false`
    ///   - allowedCardPayment: Shows credit card payment option if `true` and `usePaymentMethodsFromCapability` is `false`
    ///   - usePaymentMethodsFromCapability: If `true`then it loads list of Payment Methods from Capability API and ignores previous parameters
    func createChoosePaymentMethodController(
        allowedPaymentMethods: [SourceType] = [],
        allowedCardPayment: Bool = true,
        usePaymentMethodsFromCapability: Bool,
        delegate: ChoosePaymentMethodDelegate
    ) -> TableListController {
        // Setup ViewController
        let listController = TableListController()
        if #available(iOSApplicationExtension 11.0, *) {
            listController.navigationItem.largeTitleDisplayMode = .always
        }
        listController.navigationItem.title = localized("paymentMethods.title", text: "Payment Methods")
        listController.navigationItem.backBarButtonItem = .empty
        listController.navigationItem.rightBarButtonItem = ClosureBarButtonItem(
            image: UIImage(omise: "Close"),
            style: .plain) { [weak delegate] _ in
                delegate?.choosePaymentMethodDidCancel()
        }

        // Setup ViewModel
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
        viewModel.reloadPaymentMethods()

        // Connect ViewController and ViewModel

        viewModel.onPaymentMethodsUpdated = { [weak listController] viewContexts in
            listController?.items = viewContexts
        }

        listController.didSelectCellHandler = { [weak viewModel, weak listController, weak delegate] cell, indexPath in
            guard let delegate = delegate,
                  let viewModel = viewModel,
                  let listController = listController else {
                return
            }

            if viewModel.showsActivityForSelectedPaymentMethod(at: indexPath.row) {
                cell.startAccessoryActivityIndicator()
                listController.lockUserInferface()
            }

            if let paymentMethod = viewModel.paymentMethod(at: indexPath.row) {
                self.didSelectPaymentMethod(
                    paymentMethod,
                    listController: listController,
                    delegate: delegate
                )
            }
        }

        // Finalize setup
        listController.attach(viewModel)
        listController.attach(self)
        return listController
    }
}
