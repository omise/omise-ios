import Foundation

extension Source.Details {
    /// Payment for `Alipay In-Store` payment method
    /// https://docs.opn.ooo/alipay-barcode
    public struct BarcodeAlipay: Equatable {
        /// Alipay barcode number
        public let barcode: String
        /// Store identifier.
        /// If store identifier is already configured on your account, this parameter must not be present.
        /// Please consult our support team to check if this parameter is required
        public let storeID: String?
        /// Store name.
        /// If store name is already configured on your account, this parameter must not be present.
        /// Please consult our support team to check if this parameter is required.
        public let storeName: String?
        /// Terminal identifier
        public let terminalID: String?
    }
}

extension Source.Details.BarcodeAlipay: SourceTypeDetailsProtocol {
    /// Payment method identifier
    static let sourceType: SourceType = .barcodeAlipay
    var sourceType: SourceType { Self.sourceType }
}

/// Encoding/decoding JSON string
extension Source.Details.BarcodeAlipay: Codable {
    private enum CodingKeys: String, CodingKey {
        case barcode
        case storeID = "store_id"
        case storeName = "store_name"
        case terminalID = "terminal_id"
    }
}
