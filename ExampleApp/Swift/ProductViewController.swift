import UIKit
import OmiseSDK


@objc(OMSExampleProductViewController)
class ProductViewController: UIViewController {
    private let publicKey = "<#Omise Public Key#>"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PresentPaymentCreator",
            let paymentCreatorController = segue.destination as? PaymentCreatorController {
            paymentCreatorController.publicKey = self.publicKey
            paymentCreatorController.paymentAmount = 5_000_00
            paymentCreatorController.paymentCurrency = .thb
            paymentCreatorController.paymentDelegate = self
        }
    }
}


extension ProductViewController: PaymentCreatorControllerDelegate {
    
    func paymentCreatorController(_ paymentCreatorController: PaymentCreatorController, didCreatePayment payment: Payment) {
        dismiss(animated: true, completion: nil)
    }
    
    func paymentCreatorController(_ paymentCreatorController: PaymentCreatorController, didFailWithError error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        #if swift(>=4.2)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
        #else
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        #endif
        alertController.addAction(okAction)
        paymentCreatorController.present(alertController, animated: true, completion: nil)
    }
    
    func paymentCreatorControllerDidCancel(_ paymentCreatorController: PaymentCreatorController) {
        dismiss(animated: true, completion: nil)
    }
    
}

