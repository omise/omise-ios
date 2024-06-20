import Foundation

/// Delegate to receive source request events.
@objc public protocol OMSSourceRequestDelegate {
    func sourceRequest(_ request: __OMSSourceRequest, didSucceedWithSource source: __OmiseSource)
    func sourceRequest(_ request: __OMSSourceRequest, didFailWithError error: NSError)
}

/// Request object for describing a request to create a new source with the creating parameters
@objc(OMSSourceRequest) public class __OMSSourceRequest: NSObject { // swiftlint:disable:this type_name
    
    let request: Request<Source>
    
    /// The source type that is used to create a new Source
    @objc public var type: String {
        return request.parameter.paymentInformation.sourceType
    }
    
    /// The amount of the creating Source
    @objc public var amount: Int64 {
        return request.parameter.amount
    }
    
    /// The currench of the creating Source
    @objc public var currency: String {
        return request.parameter.currency.code
    }
    
    /// Initializes new source request.
    @objc public init(paymentInformation: __SourcePaymentInformation, amount: Int64, currencyCode: String) {
        self.request = Request<Source>(
            paymentInformation: PaymentInformation(from: paymentInformation),
            amount: amount,
            currency: Currency(code: currencyCode)
        )
    }
}
