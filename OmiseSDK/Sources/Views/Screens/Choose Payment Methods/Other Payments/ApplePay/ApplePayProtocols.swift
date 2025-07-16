import Foundation

struct ApplePayInfo: Equatable {
    /// The merchant identifier used for Apple Pay transactions.
    let merchantIdentifier: String
    
    /// Indicates whether the billing address should be requested from the user.
    let requestBillingAddress: Bool
}
