import Foundation

public class OmiseCard: NSObject {
    public var cardId: String?
    public var livemode: Bool?
    public var location: String?
    public var country: String?
    public var city: String?
    public var postalCode: String?
    public var financing: String?
    public var lastDigits: String?
    public var brand: String?
    public var expirationMonth: Int?
    public var expirationYear: Int?
    public var fingerprint: String?
    public var name: String?
    public var securityCodeCheck: Bool?
    public var created: NSDate?
}
