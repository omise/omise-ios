import UIKit
import OmiseSDK

class Tool: NSObject {
    
    static let allPaymentAmount: Int64 = PaymentPreset.allPreset.paymentAmount
    static let allPaymentCurrency: String = PaymentPreset.allPreset.paymentCurrency.code
    static let allAllowedPaymentMethods: [SourceType] = PaymentPreset.allPreset.allowedPaymentMethods
    
    static let thailandPaymentAmount: Int64 = PaymentPreset.thailandPreset.paymentAmount
    static let thailandPaymentCurrency: String = PaymentPreset.thailandPreset.paymentCurrency.code
    static let thailandAllowedPaymentMethods: [SourceType] = PaymentPreset.thailandPreset.allowedPaymentMethods
    
    static let japanPaymentAmount: Int64 = PaymentPreset.japanPreset.paymentAmount
    static let japanPaymentCurrency: String = PaymentPreset.japanPreset.paymentCurrency.code
    static let japanAllowedPaymentMethods: [SourceType] = PaymentPreset.japanPreset.allowedPaymentMethods
    
    static let singaporePaymentAmount: Int64 = PaymentPreset.singaporePreset.paymentAmount
    static let singaporePaymentCurrency: String = PaymentPreset.singaporePreset.paymentCurrency.code
    static let singaporeAllowedPaymentMethods: [SourceType] = PaymentPreset.singaporePreset.allowedPaymentMethods
    
    static let malaysiaPaymentAmount: Int64 = PaymentPreset.malaysiaPreset.paymentAmount
    static let malaysiaPaymentCurrency: String = PaymentPreset.malaysiaPreset.paymentCurrency.code
    static let malaysiaAllowedPaymentMethods: [SourceType] = PaymentPreset.malaysiaPreset.allowedPaymentMethods
    
    static func imageWith(size: CGSize, color: UIColor) -> UIImage? {
        return Tool.imageWith(size: size) { (context) in
            context.setFillColor(color.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    static func imageWith(size: CGSize, actions: (CGContext) -> Void) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            actions(context.cgContext)
        }
    }
}

extension String {
    var maskedPublicKey: String {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "Not set" }
        
        let prefixCount = min(6, trimmed.count)
        let suffixCount = min(4, max(0, trimmed.count - prefixCount))
        let prefix = trimmed.prefix(prefixCount)
        let suffix = trimmed.suffix(suffixCount)
        let maskedCount = max(0, trimmed.count - prefixCount - suffixCount)
        let mask = String(repeating: "•", count: maskedCount)
        return "\(prefix)\(mask)\(suffix)"
    }
}
