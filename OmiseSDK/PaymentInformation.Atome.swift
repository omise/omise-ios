public extension PaymentInformation {
    /// The Atome customer information
    struct Atome: PaymentMethod {

        public static var paymentMethodTypePrefix: String = OMSSourceTypeValue.atome.rawValue

        public var type: String = OMSSourceTypeValue.atome.rawValue

        /// The customers phone number. Contains only digits and has 10 or 11 characters
        public let phoneNumber: String
        public let name: String?
        public let email: String?
//        public let shipping: ShippingAddress

        private enum CodingKeys: String, CodingKey {
            case name
            case email
            case phoneNumber = "phone_number"
//            case shipping
        }

        /// Creates a new Atome source with the given customer information
        ///
        public init(phoneNumber: String, shipping: ShippingAddress, name: String? = nil, email: String? = nil) {
            self.name = name
            self.email = email
            self.phoneNumber = phoneNumber
//            self.shipping = shipping
        }
    }
}

public extension PaymentInformation.Atome {
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
