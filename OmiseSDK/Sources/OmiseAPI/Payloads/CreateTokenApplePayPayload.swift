import Foundation
import PassKit

/// Payload to create a token using Apple Pay data.
/// This structure is used as the request body in Omise's createToken API.
/// See: https://docs.omise.co/tokens
public struct CreateTokenApplePayPayload: Codable, Equatable {
    public static func == (lhs: CreateTokenApplePayPayload, rhs: CreateTokenApplePayPayload) -> Bool {
        lhs.tokenization.merchantId == rhs.tokenization.merchantId &&
        lhs.tokenization.method == rhs.tokenization.method &&
        lhs.tokenization.data == rhs.tokenization.data
    }
    
    /// The tokenization information required to create a token.
    var tokenization: Tokenization
    
    /// The tokenization data for Apple Pay.
    /// This nested structure includes the payment method, payment data, merchant details,
    /// and optionally billing address information.
    public struct Tokenization: Codable {
        /// The method used for tokenization (e.g., "applepay").
        let method: String
        /// The payment token data as a string.
        let data: String
        /// The merchant identifier registered for Apple Pay.
        let merchantId: String
        /// The card brand (e.g., "Visa", "AmEx").
        let brand: String
        
        /// Optional billing name.
        var billingName: String?
        /// Optional billing city.
        var billingCity: String?
        /// Optional billing country.
        var billingCountry: String?
        /// Optional billing postal code.
        var billingPostalCode: String?
        /// Optional billing state.
        var billingState: String?
        /// Optional billing street line 1.
        var billingStreet1: String?
        /// Optional billing street line 2.
        var billingStreet2: String?
        /// Optional billing phone number.
        var billingPhoneNumber: String?
        
        /// Initializes a new tokenization object with required and optional billing parameters.
        ///
        /// - Parameters:
        ///   - method: The tokenization method (e.g., "applepay").
        ///   - data: The payment token data as a string.
        ///   - merchantId: The merchant identifier.
        ///   - brand: The card brand.
        ///   - billingName: The billing name (optional).
        ///   - billingCity: The billing city (optional).
        ///   - billingCountry: The billing country (optional).
        ///   - billingPostalCode: The billing postal code (optional).
        ///   - billingState: The billing state (optional).
        ///   - billingStreet1: The first line of the billing street (optional).
        ///   - billingStreet2: The second line of the billing street (optional).
        ///   - billingPhoneNumber: The billing phone number (optional).
        public init(
            method: String,
            data: String,
            merchantId: String,
            brand: String,
            billingName: String? = nil,
            billingCity: String? = nil,
            billingCountry: String? = nil,
            billingPostalCode: String? = nil,
            billingState: String? = nil,
            billingStreet1: String? = nil,
            billingStreet2: String? = nil,
            billingPhoneNumber: String? = nil
        ) {
            self.method = method
            self.data = data
            self.merchantId = merchantId
            self.brand = brand
            self.billingName = billingName
            self.billingCity = billingCity
            self.billingCountry = billingCountry
            self.billingPostalCode = billingPostalCode
            self.billingState = billingState
            self.billingStreet1 = billingStreet1
            self.billingStreet2 = billingStreet2
            self.billingPhoneNumber = billingPhoneNumber
        }
        
        // swiftlint:disable:next function_parameter_count
        mutating func addAddressDetails(
            billingName: String?,
            billingCity: String?,
            billingCountry: String?,
            billingPostalCode: String?,
            billingState: String?,
            billingStreet1: String?,
            billingStreet2: String? = nil,
            billingPhoneNumber: String?
        ) {
            self.billingName = billingName
            self.billingCity = billingCity
            self.billingCountry = billingCountry
            self.billingPostalCode = billingPostalCode
            self.billingState = billingState
            self.billingStreet1 = billingStreet1
            self.billingStreet2 = billingStreet2
            self.billingPhoneNumber = billingPhoneNumber
        }
        
        /// Maps the Swift property names to JSON keys.
        enum CodingKeys: String, CodingKey {
            case method
            case data
            case merchantId = "merchant_id"
            case brand
            case billingName = "billing_name"
            case billingCity = "billing_city"
            case billingCountry = "billing_country"
            case billingPostalCode = "billing_postal_code"
            case billingState = "billing_state"
            case billingStreet1 = "billing_street1"
            case billingStreet2 = "billing_street2"
            case billingPhoneNumber = "billing_phone_number"
        }
    }
}
