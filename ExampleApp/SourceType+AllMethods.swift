import OmiseSDK

extension SourceType {
    /// Comprehensive collection of all available payment methods across all regions.
    /// Includes non-credit card methods for the Example app's mock selection screen.
    static let allAvailablePaymentMethods: [SourceType] = [
        // Alipay variants
        .alipay,
        .alipayCN,
        .alipayHK,
        .barcodeAlipay,
        
        // Apple Pay
        .applePay,
        
        // Bill Payments
        .billPaymentTescoLotus,
        
        // E-Wallets
        .dana,
        .gcash,
        .grabPay,
        .grabPayRms,
        .kakaoPay,
        .payPay,
        .shopeePay,
        .shopeePayJumpApp,
        .touchNGo,
        .touchNGoAlipayPlus,
        .trueMoneyWallet,
        .trueMoneyJumpApp,
        .weChat,
        
        // Installments - Standard
        .installmentBAY,
        .installmentBBL,
        .installmentFirstChoice,
        .installmentKBank,
        .installmentKTC,
        .installmentMBB,
        .installmentSCB,
        .installmentTTB,
        .installmentUOB,
        
        // Installments - White Label
        .installmentWhiteLabelKTC,
        .installmentWhiteLabelKBank,
        .installmentWhiteLabelSCB,
        .installmentWhiteLabelBBL,
        .installmentWhiteLabelBAY,
        .installmentWhiteLabelFirstChoice,
        .installmentWhiteLabelUOB,
        .installmentWhiteLabelTTB,
        
        // Mobile Banking
        .mobileBankingBAY,
        .mobileBankingBBL,
        .mobileBankingKBank,
        .mobileBankingKTB,
        .ocbcDigital,
        .mobileBankingSCB,
        
        // Online Banking
        .duitNowOBW,
        .eContext,
        .fpx,
        
        // QR Payments
        .duitNowQR,
        .maybankQRPay,
        .promptPay,
        .rabbitLinepay,
        
        // Specialized Payment Methods
        .atome,
        .boost,
        .payNow
    ]
}
