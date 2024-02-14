import Foundation

extension Source.Details {
    /// Information about items included in the order
    /// https://docs.opn.ooo/sources-api
    public struct Item: Equatable {
        /// SKU/product id of the item
        let sku: String
        /// Category of the item
        let category: String?
        /// Name of the item
        let name: String
        /// Quantity of the item
        let quantity: Int
        /// Selling price of the item in smallest unit of currency
        let amount: Int64
        /// URI of the item
        let itemUri: String?
        /// Image URI of the item
        let imageUri: String?
        /// Brand of the item
        let brand: String?

        /// Creates a new item with the given details
        ///
        /// - Parameters:
        ///   - sku: SKU/product id of the item
        ///   - category: Category of the item
        ///   - name: Name of the item
        ///   - quantity: Quantity of the item
        ///   - amount: Selling price of the item in smallest unit of currency
        ///   - itemUri: URI of the item
        ///   - imageUri: Image URI of the item
        ///   - brand: Brand of the item
        init(sku: String, category: String?, name: String, quantity: Int, amount: Int64, itemUri: String?, imageUri: String?, brand: String?) {
            self.sku = sku
            self.category = category
            self.name = name
            self.quantity = quantity
            self.amount = amount
            self.itemUri = itemUri
            self.imageUri = imageUri
            self.brand = brand
        }
    }
}

extension Source.Details.Item: Codable {
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
