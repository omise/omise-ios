import Foundation

public class OmiseToken: NSObject {
    public var tokenId: String?
    public var livemode: Bool?
    public var location: String?
    public var used: Bool?
    public var card: OmiseCard? = OmiseCard()
    public var created: NSDate?
    
    public override init() {}
}
