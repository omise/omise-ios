import Foundation

public class OmiseRequestObject: NSObject {
    public var card: OmiseCard?
    
    public override init() {
        card = OmiseCard()
    }
}