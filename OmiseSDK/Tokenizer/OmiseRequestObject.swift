import Foundation

public class OmiseRequestObject: NSObject {
    public var publicKey: String?
    public var card: OmiseCard?
    
    public override init() {
        card = OmiseCard()
    }
}