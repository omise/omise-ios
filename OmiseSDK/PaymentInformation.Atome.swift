import Foundation

public extension PaymentInformation {
    var isAtome: Bool {
        switch self {
        case .atome: return true
        default: return false
        }
    }

    var atomeData: Atome? {
        switch self {
        case .atome(let data): return data
        default: return nil
        }

    }

    struct Atome: PaymentMethod {

        public static var paymentMethodTypePrefix: String = OMSSourceTypeValue.atome.rawValue

        public var type: String = OMSSourceTypeValue.atome.rawValue

        /// The customers phone number. Contains only digits and has 10 or 11 characters
        public let phoneNumber: String
        public let name: String?
        public let email: String?
        public let items: [Item]
        public let shippingAddress: ShippingAddress

        private enum CodingKeys: String, CodingKey {
            case name
            case email
            case phoneNumber = "phone_number"
            case items = "items"
            case shippingAddress = "shipping"
        }

        /// Creates a new Atome source with the given customer information
        ///
        /// - Parameters:
        ///   - phoneNumber:  The customers phone number
        public init(phoneNumber: String, name: String? = nil, email: String? = nil, shippingAddress: ShippingAddress, items: [Item]) {
            self.name = name
            self.email = email
            self.phoneNumber = phoneNumber
            self.shippingAddress = shippingAddress
            self.items = items
        }
    }
}

public extension PaymentInformation.Atome {
    struct Item: Codable, Equatable {
        //        public let sku: String
        //        public let amount: Int64
        //        public let name: String
        //        public let quantity: Int64
        
        public let sku: String
        public let category: String?
        public let name: String
        public let quantity: Int
        public let amount: Int64
        public let itemUri: String?
        public let imageUri: String?
        public let brand: String?

        private enum CodingKeys: String, CodingKey {
            case sku
            case amount
            case name
            case quantity
            case category
            case brand
            case imageUri = "image_uri"
            case itemUri = "item_uri"
        }
    }
    
    struct ShippingAddress: Codable, Equatable {
        public let country: String
        public let city: String
        public let postalCode: String
        public let state: String
        public let street1: String
        public let street2: String

        private enum CodingKeys: String, CodingKey {
            case country
            case city
            case postalCode = "postal_code"
            case state
            case street1
            case street2
        }

        init(country: String, city: String, postalCode: String, state: String, street1: String, street2: String) {
            self.country = country
            self.city = city
            self.postalCode = postalCode
            self.state = state
            self.street1 = street1
            self.street2 = street2
        }
    }
}
