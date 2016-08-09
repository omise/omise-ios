import Foundation


/**
 A class represents `credit card` data when exchanging with Omise
 - seealso: [The Omise Card API documentation](https://www.omise.co/cards-api)
 */
@objc(OMSCard) public class OmiseCard: NSObject {
    /// An id in Omise system of the card.
    @objc public var cardId: String?
    /// A boolean indicates that this card is a live card or a test card.
    @objc public var livemode: Bool = false
    /// A path to retrivie
    @objc public var location: String?
    /// The country code based on the card number in ISO3166 standard.
    /// - note: This information is given for information only and may not always be 100% accurate
    @objc public var country: String?
    /// The city of the card holder
    @objc public var city: String?
    /// The postal code of the card holder
    @objc public var postalCode: String?
    /// A type of credit card financing (debit or credit)
    @objc public var financing: String?
    /// The last 4 digits of the card number
    @objc public var lastDigits: String?
    /// A network brand name of the card (e.g. Visa, Mastercard, ...)
    @objc public var brand: String?
    /// Card expiration month (1-12)
    public var expirationMonth: Int?
    /// Card expiration year (in Gregrorian calendar)
    public var expirationYear: Int?
    /// Unique card-based fingerprint. Allows detection of identical cards
    @objc public var fingerprint: String?
    /// A card holder full name.
    @objc public var name: String?
    @objc public var securityCodeCheck: Bool = false
    /// Creation date of the card in *ISO8601* standard
    @objc public var created: NSDate?
}

extension NSCalendar {
    class func creditCardInformationCalendar() -> NSCalendar {
        return NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    }
}


extension OmiseCard {
    /// Card expiration month (1-12)
    @objc(expirationMonth) public var __expirationMonth: Int {
        get {
            return expirationMonth ?? NSNotFound
        }
        set {
            let validRange = NSCalendar.creditCardInformationCalendar().maximumRangeOfUnit(NSCalendarUnit.Month)
            let validMonthRange = validRange.location..<validRange.location.advancedBy(validRange.length)
            if validMonthRange ~= newValue {
                expirationMonth = newValue
            } else {
                expirationMonth = nil
            }
            
        }
    }
    /// Card expiration year (in Gregrorian calendar)
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

