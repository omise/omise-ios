import Foundation

extension SourcePayload {
    /// Barcode payment methods payload
    public enum Barcode: Codable, Equatable {
        /// Alipay In-Store payment method
        case alipay(_ payload: Alipay)
    }
}

public extension SourcePayload.Barcode {
    var sourceType: SourceType {
        switch self {
        case .alipay: return .barcodeAlipay
        }
    }
}
