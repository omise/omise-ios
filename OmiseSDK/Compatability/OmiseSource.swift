import Foundation


/**
 Represents Omise card sources.
 - seealso: [Sources API](https://www.omise.co/sources-api)
 */
@objc(OMSSource) public class __OmiseSource: NSObject {
    private let source: Source
    
    @objc public var object: String {
        return source.object
    }
    @objc public var id: String {
        return source.id
    }
    
    @objc public var type: String {
        return source.type.rawValue
    }
    @objc public var flow: String {
        return source.flow.rawValue
    }
    
    @objc public var amount: Int64 {
        return source.amount
    }
    @objc public var currencyCode: String {
        return source.currency.code
    }
    
    init(source: Source) {
        self.source = source
    }
}


