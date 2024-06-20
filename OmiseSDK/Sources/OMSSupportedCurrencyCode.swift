import Foundation

public enum OMSSupportedCurrencyCode {
    case THB
    case JPY
    case IDR
    case SGD
    case USD
    case GBP
    case EUR
    case MYR
    case AUD
    case CAD
    case CHF
    case CNY
    case DKK
    case HKD

    var rawValue: String { countryCodeStringValue(countryCode: self) }
}

func countryCodeStringValue(countryCode: OMSSupportedCurrencyCode) -> String {
    switch countryCode {
    case .THB: return "THB"
    case .JPY: return "JPY"
    case .IDR: return "IDR"
    case .SGD: return "SGD"
    case .USD: return "USD"
    case .GBP: return "GBP"
    case .EUR: return "EUR"
    case .MYR: return "MYR"
    case .AUD: return "AUD"
    case .CAD: return "CAD"
    case .CHF: return "CHF"
    case .CNY: return "CNY"
    case .DKK: return "DKK"
    case .HKD: return "HKD"
    }
}
