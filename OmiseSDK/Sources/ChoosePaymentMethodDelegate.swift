import Foundation

/// Omise Payment delegate protocol is required to process payment results
public protocol ChoosePaymentMethodDelegate: AnyObject {
    func choosePaymentMethodDidComplete(with source: Source)
    func choosePaymentMethodDidComplete(with token: Token)
    func choosePaymentMethodDidComplete(with whiteLabelInstallmentSource: Source, token: Token)
    func choosePaymentMethodDidComplete(with error: Error)
    func choosePaymentMethodDidCancel()
}
