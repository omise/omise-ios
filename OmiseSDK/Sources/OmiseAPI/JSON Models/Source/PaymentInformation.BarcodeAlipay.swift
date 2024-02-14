import Foundation

extension PaymentInformation {
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

        public init(barcode: String, storeID: String?, storeName: String?, terminalID: String?) {
            self.barcode = barcode
            self.storeID = storeID
            self.storeName = storeName
            self.terminalID = terminalID
        }
    }
}

extension PaymentInformation.BarcodeAlipay: SourceTypeContainerProtocol {
    /// Payment method identifier
    public static let sourceType: SourceTypeValue = .barcodeAlipay
    public var sourceType: SourceTypeValue { Self.sourceType }
}

/// Encoding/decoding JSON string
extension PaymentInformation.BarcodeAlipay: Codable {
    private enum CodingKeys: String, CodingKey {
        case barcode
        case storeID = "store_id"
        case storeName = "store_name"
        case terminalID = "terminal_id"
    }
}
