import UIKit
import OmiseSDK

struct PaymentPreset {
    var paymentAmount: Int64
    var paymentCurrency: Currency
    var allowedPaymentMethods: [OMSSourceTypeValue]
    
    static let thailandPreset = PaymentPreset(
        paymentAmount: 5_000_00,
        paymentCurrency: .thb,
        allowedPaymentMethods: PaymentCreatorController.thailandDefaultAvailableSourceMethods
    )
    
    static let japanPreset = PaymentPreset(
        paymentAmount: 5_000,
        paymentCurrency: .jpy,
        allowedPaymentMethods: PaymentCreatorController.japanDefaultAvailableSourceMethods
    )
    
    static let singaporePreset = PaymentPreset(
        paymentAmount: 5_000_00,
        paymentCurrency: .sgd,
        allowedPaymentMethods: PaymentCreatorController.singaporeDefaultAvailableSourceMethods
    )

    static let malaysiaPreset = PaymentPreset(
        paymentAmount: 5_000_00,
        paymentCurrency: .myr,
        allowedPaymentMethods: PaymentCreatorController.malaysiaDefaultAvailableSourceMethods
    )
}


@objc class Tool: NSObject {
    
    @objc static let thailandPaymentAmount: Int64 = PaymentPreset.thailandPreset.paymentAmount
    @objc static let thailandPaymentCurrency: String = PaymentPreset.thailandPreset.paymentCurrency.code
    static let thailandAllowedPaymentMethods: [OMSSourceTypeValue] = PaymentPreset.thailandPreset.allowedPaymentMethods
    
    @objc static let japanPaymentAmount: Int64 = PaymentPreset.japanPreset.paymentAmount
    @objc static let japanPaymentCurrency: String = PaymentPreset.japanPreset.paymentCurrency.code
    static let japanAllowedPaymentMethods: [OMSSourceTypeValue] = PaymentPreset.japanPreset.allowedPaymentMethods
    
    @objc static let singaporePaymentAmount: Int64 = PaymentPreset.singaporePreset.paymentAmount
    @objc static let singaporePaymentCurrency: String = PaymentPreset.singaporePreset.paymentCurrency.code
    static let singaporeAllowedPaymentMethods: [OMSSourceTypeValue] = PaymentPreset.singaporePreset.allowedPaymentMethods

    @objc static let malaysiaPaymentAmount: Int64 = PaymentPreset.malaysiaPreset.paymentAmount
    @objc static let malaysiaPaymentCurrency: String = PaymentPreset.malaysiaPreset.paymentCurrency.code
    static let malaysiaAllowedPaymentMethods: [OMSSourceTypeValue] = PaymentPreset.malaysiaPreset.allowedPaymentMethods
    
    @objc static func imageWith(size: CGSize, color: UIColor) -> UIImage? {
        return Tool.imageWith(size: size) { (context) in
            context.setFillColor(color.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    @objc static func imageWith(size: CGSize, actions: (CGContext) -> Void) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            actions(context.cgContext)
        }
    }
}

