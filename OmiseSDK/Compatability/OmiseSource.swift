import Foundation


/**
 Represents Omise card sources.
 - seealso: [Sources API](https://www.omise.co/sources-api)
 */
@objc(OMSSource) public class __OmiseSource: NSObject {
    private let source: Source
    
    @objc lazy public var object: String = source.object
    
    @objc lazy public var id: String = source.id
    
    
    @objc lazy public var type: String = source.paymentInformation.sourceType
    
    @objc lazy public var flow: String = source.flow.rawValue
    
    
    @objc lazy public var amount: Int64 = source.amount

    @objc lazy public var currencyCode: String = source.currency.code
    
    
    init(source: Source) {
        self.source = source
    }
}


