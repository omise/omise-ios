import OmiseSDK

struct PaymentPreset {
    var paymentAmount: Int64
    var paymentCurrency: Currency
    var allowedPaymentMethods: [SourceType]
    
    static let allPreset = PaymentPreset(
        paymentAmount: 3_500_00,
        paymentCurrency: .thb,
        allowedPaymentMethods: SourceType.allCases
    )
    
    static let thailandPreset = PaymentPreset(
        paymentAmount: 3_500_00,
        paymentCurrency: .thb,
        allowedPaymentMethods: SourceType.availableByDefaultInThailand
    )
    
    static let japanPreset = PaymentPreset(
        paymentAmount: 3_500,
        paymentCurrency: .jpy,
        allowedPaymentMethods: SourceType.availableByDefaultInJapan
    )
    
    static let singaporePreset = PaymentPreset(
        paymentAmount: 3_500_00,
        paymentCurrency: .sgd,
        allowedPaymentMethods: SourceType.availableByDefaultSingapore
    )
    
    static let malaysiaPreset = PaymentPreset(
        paymentAmount: 3_500_00,
        paymentCurrency: .myr,
        allowedPaymentMethods: SourceType.availableByDefaultMalaysia
    )
}
