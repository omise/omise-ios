import UIKit
import OmiseSDK

struct PaymentPreset {
    var paymentAmount: Int64
    var paymentCurrency: Currency
    var allowedPaymentMethods: [SourceType]
    
    static let allPreset = PaymentPreset(
        paymentAmount: 5_000_00,
        paymentCurrency: .thb,
        allowedPaymentMethods: SourceType.allCases
    )

    static let thailandPreset = PaymentPreset(
        paymentAmount: 5_000_00,
        paymentCurrency: .thb,
        allowedPaymentMethods: SourceType.availableByDefaultInThailand
    )

    static let japanPreset = PaymentPreset(
        paymentAmount: 5_000,
        paymentCurrency: .jpy,
        allowedPaymentMethods: SourceType.availableByDefaultInJapan
    )
    
    static let singaporePreset = PaymentPreset(
        paymentAmount: 5_000_00,
        paymentCurrency: .sgd,
        allowedPaymentMethods: SourceType.availableByDefaultSingapore
    )

    static let malaysiaPreset = PaymentPreset(
        paymentAmount: 5_000_00,
        paymentCurrency: .myr,
        allowedPaymentMethods: SourceType.availableByDefaultMalaysia
    )
}

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
