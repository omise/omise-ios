import OmiseSDK
import Foundation

struct PaymentSettings {
    var amount: Int64
    var currency: Currency
    var usesCapabilityData: Bool
    var allowedPaymentMethods: Set<SourceType>
    var publicKey: String
    
    var amountDecimal: Decimal {
        Decimal(currency.convert(fromSubunit: amount))
    }
    
    mutating func applyPreset(_ preset: PaymentPreset) {
        amount = preset.paymentAmount
        currency = preset.paymentCurrency
        allowedPaymentMethods = Set(preset.allowedPaymentMethods)
    }
    
    static func `default`(
        config: LocalConfig = .default,
        locale: Locale = .current
    ) -> PaymentSettings {
        let regionCode: String? = {
            if #available(iOS 16, *) {
                return locale.region?.identifier
            } else {
                return locale.regionCode
            }
        }()
        
        let preset: PaymentPreset
        switch regionCode {
        case "JP":
            preset = .japanPreset
        case "SG":
            preset = .singaporePreset
        case "MY":
            preset = .malaysiaPreset
        default:
            preset = .thailandPreset
        }
        
        return PaymentSettings(
            amount: preset.paymentAmount,
            currency: preset.paymentCurrency,
            usesCapabilityData: true,
            allowedPaymentMethods: Set(preset.allowedPaymentMethods),
            publicKey: config.publicKey
        )
    }
}
