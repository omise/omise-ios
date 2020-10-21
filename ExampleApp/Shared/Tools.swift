import UIKit
import OmiseSDK


struct PaymentPreset {
    var paymentAmount: Int64
    var paymentCurrency: Currency
    var allowedPaymentMethods: [SourceType]
    
    static let thailandPreset = PaymentPreset(
        paymentAmount: 5_000_00, paymentCurrency: .thb,
        allowedPaymentMethods: PaymentCreatorController.thailandDefaultAvailableSourceMethods
    )
    
    static let japanPreset = PaymentPreset(
        paymentAmount: 5_000, paymentCurrency: .jpy,
        allowedPaymentMethods: PaymentCreatorController.japanDefaultAvailableSourceMethods
    )
    
    static let singaporePreset = PaymentPreset(
        paymentAmount: 5_000_00, paymentCurrency: .sgd,
        allowedPaymentMethods: PaymentCreatorController.singaporeDefaultAvailableSourceMethods
    )
}


class Tool : NSObject {
    static let thailandPaymentAmount: Int64 = PaymentPreset.thailandPreset.paymentAmount
    static let thailandPaymentCurrency: String = PaymentPreset.thailandPreset.paymentCurrency.code
    static let thailandAllowedPaymentMethods: [SourceType] = PaymentPreset.thailandPreset.allowedPaymentMethods
    
    static let japanPaymentAmount: Int64 = PaymentPreset.japanPreset.paymentAmount
    static let japanPaymentCurrency: String = PaymentPreset.japanPreset.paymentCurrency.code
    static let japanAllowedPaymentMethods: [SourceType] = PaymentPreset.japanPreset.allowedPaymentMethods
    
    static let singaporePaymentAmount: Int64 = PaymentPreset.singaporePreset.paymentAmount
    static let singaporePaymentCurrency: String = PaymentPreset.singaporePreset.paymentCurrency.code
    static let singaporeAllowedPaymentMethods: [SourceType] = PaymentPreset.singaporePreset.allowedPaymentMethods
    
    static func imageWith(size: CGSize, color: UIColor) -> UIImage? {
        return Tool.imageWith(size: size, actions: { (context) in
            context.setFillColor(color.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
        })
    }
    
    static func imageWith(size: CGSize, actions: (CGContext) -> Void) -> UIImage? {
        if #available(iOS 11.0, *) {
            let renderer = UIGraphicsImageRenderer(size: size)
            return renderer.image(actions: { context in
                actions(context.cgContext)
            })
        } else {
            UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
            let context = UIGraphicsGetCurrentContext()
            if let context = context {
                actions(context)
            }
            return UIGraphicsGetImageFromCurrentImageContext()
        }
    }
}

