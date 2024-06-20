import Foundation

/**
 Represents Omise card tokens.
 - seealso: [Tokens API](https://www.omise.co/tokens-api)
 */
@objc(OMSToken) public class __OmiseToken: NSObject { // swiftlint:disable:this type_name
    /// Token's ID.
    @objc public lazy var tokenID: String? = token.id
    
    @available(*, deprecated, message: "Use the `__OmiseToken.tokenID` property instead")
    @objc public lazy var tokenId: String? = token.id
    
    /// Boolean flag indicating wether this card is a live card or a test card.
    @objc public lazy var livemode: Bool = token.isLiveMode
    
    /// Resource URL that can be used to re-load token information.
    @objc public lazy var location: String? = token.location
    
    /// Boolean flag indicating whether the token has been used or not.
    /// Tokens can only be used once to make create a Charge or to create a saved Card record.
    @objc public lazy var used: Bool = token.isUsed
    
    /// Card information used to generate this token.
    @objc public lazy var card: __OmiseCard? = __OmiseCard(card: token.card)
    
    /// Token's creation time.
    @objc public lazy var created: Date? = token.createdDate
    
    private let token: Token
    
    init(token: Token) {
        self.token = token
    }
}
