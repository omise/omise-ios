import Foundation

public class OmiseRequestObject: NSObject {
    public var name: String
    public var number: String
    public var expirationMonth: Int
    public var expirationYear: Int
    public var securityCode: String
    public var city: String?
    public var postalCode: String?
    
    public init(name: String, number: String, expirationMonth: Int, expirationYear: Int, securityCode: String, city: String?, postalCode: String?) {
        self.name = name
        self.number = number
        self.expirationMonth = expirationMonth
        self.expirationYear = expirationYear
        self.securityCode = securityCode
        self.city = (city ?? "")
        self.postalCode = (postalCode ?? "")
    }
    
}