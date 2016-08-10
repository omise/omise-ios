import Foundation

@objc(OMSToken) public class OmiseToken: NSObject {
    @objc public var tokenId: String?
    @objc public var livemode: Bool = false
    @objc public var location: String?
    @objc public var used: Bool = false
    @objc public var card: OmiseCard?
    @objc public var created: NSDate?
}

