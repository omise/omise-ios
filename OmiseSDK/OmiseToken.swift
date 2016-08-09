import Foundation


/**
 A class represents the card token tokenized by Omise.
 - seealso: [The Omise Token API documentation](https://www.omise.co/tokens-api)
 */
@objc(OMSToken) public class OmiseToken: NSObject {
    /// ID of this token
    @objc public var tokenId: String?
    /// Whether this is a live (true) or test (false) token.
    @objc public var livemode: Bool = false
    /// Path to retrieve the token.
    @objc public var location: String?
    /// Whether the token has been used or not. Tokens can be used only once to make a charge on their card or to associate the card to a customer/
    @objc public var used: Bool = false
    /// The card used to generate this token.
    @objc public var card: OmiseCard?
    /// Creation date of the token in ISO 8601 standard.
    @objc public var created: NSDate?
}

