import Foundation

/// Source type of payment
public enum SourceType: String, Codable, CaseIterable {
    /// Alipay (Online) https://docs.opn.ooo/alipay
    case alipay = "alipay"
    /// Alipay CN   https://docs.opn.ooo/alipay-cn
    case alipayCN = "alipay_cn"
    /// Alipay Hongkong https://docs.opn.ooo/alipay-hk
    case alipayHK = "alipay_hk"
    /// Atome App Redirection   https://docs.opn.ooo/atome
    case atome = "atome"
    /// ApplePay https://docs.opn.ooo/applepay
    case applePay = "applepay"
    /// Alipay In-Store https://docs.opn.ooo/alipay-barcode
    case barcodeAlipay = "barcode_alipay" // Not available to select in UI
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
    /// Krungthai Card (KTC)  https://docs.opn.ooo/installment-white-label-payments
    case installmentWhiteLabelKTC = "installment_wlb_ktc"
    /// Kasikorn Bank  https://docs.opn.ooo/installment-white-label-payments
    case installmentWhiteLabelKBank = "installment_wlb_kbank"
    /// Siam Commercial Bank  https://docs.opn.ooo/installment-white-label-payments
    case installmentWhiteLabelSCB = "installment_wlb_scb"
    /// Bangkok Bank https://docs.opn.ooo/installment-white-label-payments
    case installmentWhiteLabelBBL = "installment_wlb_bbl"
    /// Krungsri https://docs.opn.ooo/installment-white-label-payments
    case installmentWhiteLabelBAY = "installment_wlb_bay"
    /// Krungsri First Choice https://docs.opn.ooo/installment-white-label-payments
    case installmentWhiteLabelFirstChoice = "installment_wlb_first_choice"
    /// United Overseas Bank (UOB)  https://docs.opn.ooo/installment-white-label-payments
    case installmentWhiteLabelUOB = "installment_wlb_uob"
    /// TMBThanachart Bank https://docs.opn.ooo/installment-white-label-payments
    case installmentWhiteLabelTTB = "installment_wlb_ttb"
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
    /// - note: "Most of SG customers recognize it as OCBC PAO, not a part of mobile banking"
    case ocbcDigital = "mobile_banking_ocbc"
    /// SCB (SCB Easy)  https://docs.opn.ooo/mobile-banking-scb
    case mobileBankingSCB = "mobile_banking_scb"
    /// PayNow  https://docs.opn.ooo/paynow
    case payNow = "paynow"
    /// PayPay  https://docs.opn.ooo/paypay
    case payPay = "paypay"
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
