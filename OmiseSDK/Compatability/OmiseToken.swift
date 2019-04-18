import Foundation


/**
 Represents Omise card tokens.
 - seealso: [Tokens API](https://www.omise.co/tokens-api)
 */
@objc(OMSToken) public class __OmiseToken: NSObject {
    /// Token's ID.
    @objc lazy public var tokenID: String? = token.id
    
    @available(*, deprecated, message: "Use the `__OmiseToken.tokenID` property instead")
    @objc lazy public var tokenId: String? = token.id
    
    /// Boolean flag indicating wether this card is a live card or a test card.
    @objc lazy public var livemode: Bool = token.isLiveMode
    
    /// Resource URL that can be used to re-load token information.
    @objc lazy public var location: String? = token.location
    
    /// Boolean flag indicating whether the token has been used or not.
    /// Tokens can only be used once to make create a Charge or to create a saved Card record.
    @objc lazy public var used: Bool = token.isUsed
    
    /// Card information used to generate this token.
    @objc lazy public var card: __OmiseCard? = __OmiseCard(card: token.card)
    
    /// Token's creation time.
    @objc lazy public var created: Date? = token.createdDate
    
    private let token: Token
    
    init(token: Token) {
        self.token = token
    }
}

