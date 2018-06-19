import Foundation


/// Delegate to receive source request events.
@objc public protocol OMSSourceRequestDelegate {
    func sourceRequest(_ request: __OMSSourceRequest, didSucceedWithSource source: __OmiseSource)
    func sourceRequest(_ request: __OMSSourceRequest, didFailWithError error: NSError)
}


@objc(OMSSourceRequest) public class __OMSSourceRequest: NSObject {
    
    let request: Request<Source>
    
    @objc public var type: String {
        return request.parameter.type.rawValue
    }
    
    @objc public var amount: Int64 {
        return request.parameter.amount
    }
    
    @objc public var currency: String {
        return request.parameter.currency.code
    }
    
    /// Initializes new source request.
    @objc public init(sourceType: String, amount: Int64, currencyCode: String) {
        self.request = Request<Source>.init(sourceType: SourceType(rawValue: sourceType)!, amount: amount, currency: Currency.init(code: currencyCode))
    }
}


