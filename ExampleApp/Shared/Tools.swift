import UIKit
import OmiseSDK


struct PaymentPreset {
    var paymentAmount: Int64
    var paymentCurrency: Currency
    var allowedPaymentMethods: [OMSSourceTypeValue]
    
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


@objc class Tool : NSObject {
    
    @objc static let thailandPaymentAmount: Int64 = PaymentPreset.thailandPreset.paymentAmount
    @objc static let thailandPaymentCurrency: String = PaymentPreset.thailandPreset.paymentCurrency.code
    @objc static let thailandAllowedPaymentMethods: [OMSSourceTypeValue] = PaymentPreset.thailandPreset.allowedPaymentMethods
    
    @objc static let japanPaymentAmount: Int64 = PaymentPreset.japanPreset.paymentAmount
    @objc static let japanPaymentCurrency: String = PaymentPreset.japanPreset.paymentCurrency.code
    @objc static let japanAllowedPaymentMethods: [OMSSourceTypeValue] = PaymentPreset.japanPreset.allowedPaymentMethods
    
    @objc static let singaporePaymentAmount: Int64 = PaymentPreset.singaporePreset.paymentAmount
    @objc static let singaporePaymentCurrency: String = PaymentPreset.singaporePreset.paymentCurrency.code
    @objc static let singaporeAllowedPaymentMethods: [OMSSourceTypeValue] = PaymentPreset.singaporePreset.allowedPaymentMethods
    
    @objc static func imageWith(size: CGSize, color: UIColor) -> UIImage? {
        return Tool.imageWith(size: size, actions: { (context) in
            context.setFillColor(color.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
        })
    }
    
    @objc static func imageWith(size: CGSize, actions: (CGContext) -> Void) -> UIImage? {
        if #available(iOS 10.0, *) {
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

