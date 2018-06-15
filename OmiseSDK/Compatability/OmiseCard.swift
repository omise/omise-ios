import Foundation


/**
 Represents saved credit card information.
 - seealso: [Cards API](https://www.omise.co/cards-api)
 */
@objc(OMSCard) public class OmiseCard: NSObject {
    /// Card's ID.
    @objc public var cardId: String?
    /// Boolean flag indicating wether this card is a live card or a test card.
    @objc public var livemode: Bool = false
    /// Resource URL that can be used to re-load card information.
    @objc public var location: String?
    /// ISO3166 Country code based on the card number.
    /// - note: This is informational only and may not always be 100% accurate.
    @objc public var country: String?
    /// Issuing city.
    /// - note: This is informational only and may not always be 100% accurate.
    @objc public var city: String?
    /// Postal code.
    @objc public var postalCode: String?
    /// Credit card financing type. (debit or credit)
    @objc public var financing: String?
    /// Last 4 digits of the card number.
    @objc public var lastDigits: String?
    /// Card brand. (e.g. Visa, Mastercard, ...)
    @objc public var brand: String?
    /// Card expiration month (1-12)
    public var expirationMonth: Int?
    /// Card expiration year (Gregrorian)
    public var expirationYear: Int?
    /// Unique card-based fingerprint. Allows detection of identical cards without
    /// exposing card numbers directly.
    @objc public var fingerprint: String?
    /// Card holder's full name.
    @objc public var name: String?
    @objc public var securityCodeCheck: Bool = false
    /// Card's creation time.
    @objc public var created: Date?
}

extension Calendar {
    static let creditCardInformationCalendar: Calendar = {
        return Calendar(identifier: .gregorian)
    }()
}


extension OmiseCard {
    /// Card expiration month (1-12)
    @objc(expirationMonth) public var __expirationMonth: Int {
        get {
            return expirationMonth ?? NSNotFound
        }
        set {
            if let validRange = Calendar.creditCardInformationCalendar.maximumRange(of: .month), validRange ~= newValue {
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

