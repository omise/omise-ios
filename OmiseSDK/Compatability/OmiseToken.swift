import Foundation


/**
 Represents Omise card tokens.
 - seealso: [Tokens API](https://www.omise.co/tokens-api)
 */
@objc(OMSToken) public class __OmiseToken: NSObject {
    private let token: Token
    /// Token's ID.
    @objc public var tokenId: String? {
        return token.id
    }
    /// Boolean flag indicating wether this card is a live card or a test card.
    @objc public var livemode: Bool {
        return token.isLiveMode
    }
    /// Resource URL that can be used to re-load token information.
    @objc public var location: String? {
        return token.location
    }
    /// Boolean flag indicating whether the token has been used or not.
    /// Tokens can only be used once to make create a Charge or to create a saved Card record.
    @objc public var used: Bool {
        return token.isUsed
    }
    /// Card information used to generate this token.
    @objc public var card: __OmiseCard? {
        return __OmiseCard(card: token.card)
    }
    /// Token's creation time.
    @objc public var created: Date? {
        return token.createdDate
    }
    
    init(token: Token) {
        self.token = token
    }
}

