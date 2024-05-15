import Foundation

/// Omise Payment delegate protocol is required to process 3DS authorization
public protocol AuthorizingPaymentDelegate: AnyObject {
    func authorizingPaymentDidComplete(with redirectedURL: URL?)
    func authorizingPaymentDidCancel()
}
