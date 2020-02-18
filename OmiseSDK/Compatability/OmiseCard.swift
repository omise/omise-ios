import Foundation


/**
 Represents saved credit card information.
 - seealso: [Cards API](https://www.omise.co/cards-api)
 */
@objc(OMSCard) public class __OmiseCard: NSObject {
    private let card: Card
    /// Card's ID.
    @objc public var cardId: String? {
        return card.id
    }
    /// Boolean flag indicating wether this card is a live card or a test card.
    @objc public var livemode: Bool {
        return card.isLiveMode
    }
    /// ISO3166 Country code based on the card number.
    /// - note: This is informational only and may not always be 100% accurate.
    @objc public var country: String? {
        return card.countryCode
    }
    /// Issuing city.
    /// - note: This is informational only and may not always be 100% accurate.
    @objc public var city: String? {
        return card.city
    }
    /// Postal code.
    @objc public var postalCode: String? {
        return card.postalCode
    }
    /// Credit card financing type. (debit or credit)
    @objc public var financing: String? {
        return card.financing
    }
    /// Last 4 digits of the card number.
    @objc public var lastDigits: String? {
        return card.lastDigits
    }
    /// Card brand. (e.g. Visa, Mastercard, ...)
    @objc public var brand: String? {
        return card.brand
    }
    /// Card expiration month (1-12)
    @objc public var expirationMonth: Int {
        return card.expirationMonth ?? NSNotFound
    }
    /// Card expiration year (Gregrorian)
    @objc public var expirationYear: Int {
        return card.expirationYear ?? NSNotFound
    }
    /// Unique card-based fingerprint. Allows detection of identical cards without
    /// exposing card numbers directly.
    @objc public var fingerprint: String? {
        return card.fingerprint
    }
    /// Card holder's full name.
    @objc public var name: String? {
        return card.name
    }
    @objc public var securityCodeCheck: Bool {
        return card.securityCodeCheck
    }
    /// Card's creation time.
    @objc public var created: Date? {
        return card.createdDate
    }
    
    init(card: Card) {
        self.card = card
    }
}

