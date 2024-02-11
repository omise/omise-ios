import Foundation

extension SourceNew {
    public enum PaymentInformation: Codable {
        case atome(PaymentPayload.Atome)
        case barcode(PaymentPayload.Barcode)
        case billPayment(PaymentPayload.BillPayment)
        case duitNowOBW(PaymentPayload.DoitNowOBW)
        case eContext(PaymentPayload.EContext)
        case fpx(PaymentPayload.FPX)
        case installment(PaymentPayload.Installment)
        case mobileBanking(PaymentPayload.MobileBanking)
        case points(PaymentPayload.Points)
        case trueMoney(PaymentPayload.TrueMoney)

        case other(PaymentPayload)
    }
}
