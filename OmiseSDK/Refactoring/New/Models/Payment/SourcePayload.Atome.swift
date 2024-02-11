import Foundation

extension SourcePayload {
    public struct Atome: Codable, Equatable {
        /// The customers phone number. Contains only digits and has 10 or 11 characters
        let phoneNumber: String
        let name: String?
        let email: String?
        let items: [Item]
        let shippingAddress: ShippingAddress

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
        init(phoneNumber: String, name: String? = nil, email: String? = nil, shippingAddress: ShippingAddress, items: [Item]) {
            self.name = name
            self.email = email
            self.phoneNumber = phoneNumber
            self.shippingAddress = shippingAddress
            self.items = items
        }
    }
}

extension SourcePayload.Atome {
    struct Item: Codable, Equatable {
        let sku: String
        let category: String?
        let name: String
        let quantity: Int
        let amount: Int64
        let itemUri: String?
        let imageUri: String?
        let brand: String?

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
}

extension SourcePayload.Atome {
    struct ShippingAddress: Codable, Equatable {
        let country: String
        let city: String
        let postalCode: String
        let state: String
        let street1: String
        let street2: String

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
