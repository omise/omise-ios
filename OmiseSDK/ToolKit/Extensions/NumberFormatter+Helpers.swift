import Foundation

extension NumberFormatter {
    static func makeAmountFormatter(for currency: Currency?) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency?.code
        if currency == .thb {
            formatter.currencySymbol = "฿"
        }
        return formatter
    }
}
