import Foundation

@objc(OMSCard) public class OmiseCard: NSObject {
    @objc public var cardId: String?
    @objc public var livemode: Bool = false
    @objc public var location: String?
    @objc public var country: String?
    @objc public var city: String?
    @objc public var postalCode: String?
    @objc public var financing: String?
    @objc public var lastDigits: String?
    @objc public var brand: String?
    public var expirationMonth: Int?
    public var expirationYear: Int?
    @objc public var fingerprint: String?
    @objc public var name: String?
    @objc public var securityCodeCheck: Bool = false
    @objc public var created: NSDate?
}

extension NSCalendar {
    class func creditCardInformationCalendar() -> NSCalendar {
        return NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    }
}


extension OmiseCard {
    @objc(expirationMonth) public var __expirationMonth: Int {
        get {
            return expirationMonth ?? NSNotFound
        }
        set {
            let validRange = NSCalendar.creditCardInformationCalendar().maximumRangeOfUnit(NSCalendarUnit.Month)
            let validMonthRange = validRange.location..<validRange.location.advancedBy(validRange.location)
            if validMonthRange ~= newValue {
                expirationMonth = newValue
            } else {
                expirationMonth = nil
            }
            
        }
    }
    @objc(expirationYear) public var __expirationYear: Int {
        get {
            return expirationYear ?? NSNotFound
        }
        set {
            if newValue == NSNotFound {
                expirationYear = nil
            } else {
                expirationYear = newValue
            }
        }
    }
}

