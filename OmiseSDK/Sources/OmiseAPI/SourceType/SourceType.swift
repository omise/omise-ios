import Foundation

/// Source type of payment
public enum SourceType: String, Codable, CaseIterable {
    /// Alipay (Online) https://docs.omise.co/alipay
    case alipay = "alipay"
    /// Alipay CN   https://docs.omise.co/alipay-cn
    case alipayCN = "alipay_cn"
    /// Alipay Hongkong https://docs.omise.co/alipay-hk
    case alipayHK = "alipay_hk"
    /// Atome App Redirection   https://docs.omise.co/atome
    case atome = "atome"
    /// ApplePay https://docs.omise.co/applepay
    case applePay = "applepay"
    /// Alipay In-Store https://docs.omise.co/alipay-barcode
    case barcodeAlipay = "barcode_alipay" // Not available to select in UI
    /// Lotus's Bill Payment    https://docs.omise.co/bill-payment
    case billPaymentTescoLotus = "bill_payment_tesco_lotus"
    /// Boost   https://docs.omise.co/boost
    case boost = "boost"
    /// DANA    https://docs.omise.co/dana
    case dana = "dana"
    /// DuitNow Online Banking/Wallets  https://docs.omise.co/duitnow-obw
    case duitNowOBW = "duitnow_obw"
    /// DuitNow QR  https://docs.omise.co/duitnow-qr
    case duitNowQR = "duitnow_qr"
    /// Konbini, Pay-easy, and Online Banking   https://docs.omise.co/konbini-pay-easy-online-banking
    case eContext = "econtext"
    /// Malaysia FPX    https://docs.omise.co/fpx
    case fpx = "fpx"
    /// GCash   https://docs.omise.co/gcash
    case gcash = "gcash"
    /// GrabPay https://docs.omise.co/grabpay
    case grabPay = "grabpay"
    /// - warning   Information not found
    case grabPayRms = "grabpay_rms"
    /// Bank of Ayudhya (Krungsri)    https://docs.omise.co/installment-payments
    case installmentBAY = "installment_bay"
    /// Bangkok Bank    https://docs.omise.co/installment-payments
    case installmentBBL = "installment_bbl"
    /// Krungsri First Choice   https://docs.omise.co/installment-payments
    case installmentFirstChoice = "installment_first_choice"
    /// Kasikorn Bank   https://docs.omise.co/installment-payments
    case installmentKBank = "installment_kbank"
    /// Krungthai Card (KTC)  https://docs.omise.co/installment-payments
    case installmentKTC = "installment_ktc"
    /// Maybank   https://docs.omise.co/installment-payments
    case installmentMBB = "installment_mbb"
    /// Siam Commercial Bank   https://docs.omise.co/installment-payments
    case installmentSCB = "installment_scb"
    /// TMBThanachart Bank (TTB)   https://docs.omise.co/installment-payments
    case installmentTTB = "installment_ttb"
    /// United Overseas Bank (UOB)   https://docs.omise.co/installment-payments
    case installmentUOB = "installment_uob"
    /// Krungthai Card (KTC)  https://docs.omise.co/installment-white-label-payments
    case installmentWhiteLabelKTC = "installment_wlb_ktc"
    /// Kasikorn Bank  https://docs.omise.co/installment-white-label-payments
    case installmentWhiteLabelKBank = "installment_wlb_kbank"
    /// Siam Commercial Bank  https://docs.omise.co/installment-white-label-payments
    case installmentWhiteLabelSCB = "installment_wlb_scb"
    /// Bangkok Bank https://docs.omise.co/installment-white-label-payments
    case installmentWhiteLabelBBL = "installment_wlb_bbl"
    /// Krungsri https://docs.omise.co/installment-white-label-payments
    case installmentWhiteLabelBAY = "installment_wlb_bay"
    /// Krungsri First Choice https://docs.omise.co/installment-white-label-payments
    case installmentWhiteLabelFirstChoice = "installment_wlb_first_choice"
    /// United Overseas Bank (UOB)  https://docs.omise.co/installment-white-label-payments
    case installmentWhiteLabelUOB = "installment_wlb_uob"
    /// TMBThanachart Bank https://docs.omise.co/installment-white-label-payments
    case installmentWhiteLabelTTB = "installment_wlb_ttb"
    /// KakaoPay    https://docs.omise.co/kakaopay
    case kakaoPay = "kakaopay"
    /// Maybank QR  https://docs.omise.co/maybank-qr
    case maybankQRPay = "maybank_qr"
    /// Krungsri (KMA)  https://docs.omise.co/mobile-banking-bay
    case mobileBankingBAY = "mobile_banking_bay"
    /// Bangkok Bank (Bualuang mBanking) https://docs.omise.co/mobile-banking-bbl
    case mobileBankingBBL = "mobile_banking_bbl"
    /// KBank (K PLUS)  https://docs.omise.co/mobile-banking-kbank
    case mobileBankingKBank = "mobile_banking_kbank"
    /// Krung Thai (KTB NEXT)   https://docs.omise.co/mobile-banking-ktb
    case mobileBankingKTB = "mobile_banking_ktb"
    /// OCBC Digital    https://docs.omise.co/mobile-banking-ocbc
    /// - note: "Most of SG customers recognize it as OCBC PAO, not a part of mobile banking"
    case ocbcDigital = "mobile_banking_ocbc"
    /// SCB (SCB Easy)  https://docs.omise.co/mobile-banking-scb
    case mobileBankingSCB = "mobile_banking_scb"
    /// PayNow  https://docs.omise.co/paynow
    case payNow = "paynow"
    /// PayPay  https://docs.omise.co/paypay
    case payPay = "paypay"
    /// PromptPay   https://docs.omise.co/promptpay
    case promptPay = "promptpay"
    /// LINE Pay https://docs.omise.co/rabbit-linepay
    case rabbitLinepay = "rabbit_linepay"
    /// ShopeePay QR    https://docs.omise.co/shopeepay-qr
    case shopeePay = "shopeepay"
    /// ShopeePay App Redirection   https://docs.omise.co/shopeepay-jumpapp
    case shopeePayJumpApp = "shopeepay_jumpapp"
    /// Touch 'n Go https://docs.omise.co/rms-touch-n-go
    case touchNGo = "touch_n_go"
    /// - warning   Information not found
    case touchNGoAlipayPlus = "touch_n_go_alipay_plus"
    /// TrueMoney Wallet    https://docs.omise.co/truemoney-wallet
    case trueMoneyWallet = "truemoney"
    /// TrueMoney App Redirection   https://docs.omise.co/truemoney-jumpapp
    case trueMoneyJumpApp = "truemoney_jumpapp"
    /// WeChat Pay App Redirection  https://docs.omise.co/wechat-pay-online
    case weChat = "wechat_pay"
}
