import Foundation

/// Source type of payment
public enum SourceTypeValue: String, Codable, CaseIterable {
    /// Alipay (Online) https://docs.opn.ooo/alipay
    case alipay = "alipay"
    /// Alipay CN   https://docs.opn.ooo/alipay-cn
    case alipayCN = "alipay_cn"
    /// Alipay Hongkong https://docs.opn.ooo/alipay-hk
    case alipayHK = "alipay_hk"
    /// Atome App Redirection   https://docs.opn.ooo/atome
    case atome = "atome"
    /// Alipay In-Store https://docs.opn.ooo/alipay-barcode
    case barcodeAlipay = "barcode_alipay"
    /// Lotus's Bill Payment    https://docs.opn.ooo/bill-payment
    case billPaymentTescoLotus = "bill_payment_tesco_lotus"
    /// Boost   https://docs.opn.ooo/boost
    case boost = "boost"
    /// DANA    https://docs.opn.ooo/dana
    case dana = "dana"
    /// DuitNow Online Banking/Wallets  https://docs.opn.ooo/duitnow-obw
    case duitNowOBW = "duitnow_obw"
    /// DuitNow QR  https://docs.opn.ooo/duitnow-qr
    case duitNowQR = "duitnow_qr"
    /// Konbini, Pay-easy, and Online Banking   https://docs.opn.ooo/konbini-pay-easy-online-banking
    case eContext = "econtext"
    /// Malaysia FPX    https://docs.opn.ooo/fpx
    case fpx = "fpx"
    /// GCash   https://docs.opn.ooo/gcash
    case gcash = "gcash"
    /// GrabPay https://docs.opn.ooo/grabpay
    case grabPay = "grabpay"
    /// - warning   Information not found
    case grabPayRms = "grabpay_rms"
    /// Bank of Ayudhya (Krungsri)    https://docs.opn.ooo/installment-payments
    case installmentBAY = "installment_bay"
    /// Bangkok Bank    https://docs.opn.ooo/installment-payments
    case installmentBBL = "installment_bbl"
    /// Krungsri First Choice   https://docs.opn.ooo/installment-payments
    case installmentFirstChoice = "installment_first_choice"
    /// Kasikorn Bank   https://docs.opn.ooo/installment-payments
    case installmentKBank = "installment_kbank"
    /// Krungthai Card (KTC)  https://docs.opn.ooo/installment-payments
    case installmentKTC = "installment_ktc"
    /// Maybank   https://docs.opn.ooo/installment-payments
    case installmentMBB = "installment_mbb"
    /// Siam Commercial Bank   https://docs.opn.ooo/installment-payments
    case installmentSCB = "installment_scb"
    /// TMBThanachart Bank (TTB)   https://docs.opn.ooo/installment-payments
    case installmentTTB = "installment_ttb"
    /// United Overseas Bank (UOB)   https://docs.opn.ooo/installment-payments
    case installmentUOB = "installment_uob"
    /// Bank of Ayudhya (Krungsri)   https://docs.opn.ooo/internet-banking
    case internetBankingBAY = "internet_banking_bay"
    /// Bangkok Bank   https://docs.opn.ooo/internet-banking
    case internetBankingBBL = "internet_banking_bbl"
    /// KakaoPay    https://docs.opn.ooo/kakaopay
    case kakaoPay = "kakaopay"
    /// Maybank QR  https://docs.opn.ooo/maybank-qr
    case maybankQRPay = "maybank_qr"
    /// Krungsri (KMA)  https://docs.opn.ooo/mobile-banking-bay
    case mobileBankingBAY = "mobile_banking_bay"
    /// Bangkok Bank (Bualuang mBanking) https://docs.opn.ooo/mobile-banking-bbl
    case mobileBankingBBL = "mobile_banking_bbl"
    /// KBank (K PLUS)  https://docs.opn.ooo/mobile-banking-kbank
    case mobileBankingKBank = "mobile_banking_kbank"
    /// Krung Thai (KTB NEXT)   https://docs.opn.ooo/mobile-banking-ktb
    case mobileBankingKTB = "mobile_banking_ktb"
    /// OCBC Digital    https://docs.opn.ooo/mobile-banking-ocbc
    case mobileBankingOCBC = "mobile_banking_ocbc"
    /// SCB (SCB Easy)  https://docs.opn.ooo/mobile-banking-scb
    case mobileBankingSCB = "mobile_banking_scb"
    /// PayNow  https://docs.opn.ooo/paynow
    case payNow = "paynow"
    /// PayPay  https://docs.opn.ooo/paypay
    case payPay = "paypay"
    /// Pay with Points https://docs.opn.ooo/pay-with-points
    case pointsCiti = "points_citi"
    /// PromptPay   https://docs.opn.ooo/promptpay
    case promptPay = "promptpay"
    /// Rabbit LINE Pay https://docs.opn.ooo/rabbit-linepay
    case rabbitLinepay = "rabbit_linepay"
    /// ShopeePay QR    https://docs.opn.ooo/shopeepay-qr
    case shopeePay = "shopeepay"
    /// ShopeePay App Redirection   https://docs.opn.ooo/shopeepay-jumpapp
    case shopeePayJumpApp = "shopeepay_jumpapp"
    /// Touch 'n Go https://docs.opn.ooo/rms-touch-n-go
    case touchNGo = "touch_n_go"
    /// - warning   Information not found
    case touchNGoAlipayPlus = "touch_n_go_alipay_plus"
    /// TrueMoney Wallet    https://docs.opn.ooo/truemoney-wallet
    case trueMoneyWallet = "truemoney"
    /// TrueMoney App Redirection   https://docs.opn.ooo/truemoney-jumpapp
    case trueMoneyJumpApp = "truemoney_jumpapp"
    /// WeChat Pay App Redirection  https://docs.opn.ooo/wechat-pay-online
    case weChat = "wechat_pay"
}

extension SourceTypeValue {
    public static var installments: [SourceTypeValue] {
        [
            .installmentBAY,
            .installmentBBL,
            .installmentFirstChoice,
            .installmentKBank,
            .installmentKTC,
            .installmentMBB,
            .installmentSCB,
            .installmentTTB,
            .installmentUOB
        ]
    }

    // Add Unit Test
    var isInstallment: Bool {
        Self.installments.contains(self)
    }
}

extension SourceTypeValue {
    public static var internetBanking: [SourceTypeValue] {
        [
            .internetBankingBAY,
            .internetBankingBAY
        ]
    }

    var isInternetBanking: Bool {
        Self.internetBanking.contains(self)
    }
}

extension SourceTypeValue {
    public static var mobileBanking: [SourceTypeValue] {
        [
            .mobileBankingSCB,
            .mobileBankingKBank,
            .mobileBankingBAY,
            .mobileBankingBBL,
            .mobileBankingKTB
        ]
    }

    var isMobileBanking: Bool {
        Self.mobileBanking.contains(self)
    }
}
