import Foundation

public let centBasedCurrencyFactor = 100
public let identicalBasedCurrencyFactor = 1


public enum Currency: Codable, Hashable {
    case thb
    case jpy
    case idr
    case sgd
    case usd
    case gbp
    case eur
    case myr
    
    case aud
    case cad
    case chf
    case cny
    case dkk
    case hkd
    
    case custom(code: String, factor: Int)
    
    public var code: String {
        switch self {
        case .thb:
            return "THB"
        case .jpy:
            return "JPY"
        case .idr:
            return "IDR"
        case .sgd:
            return "SGD"
        case .usd:
            return "USD"
        case .gbp:
            return "GBP"
        case .eur:
            return "EUR"
        case .myr:
            return "MYR"
        case .aud:
            return "AUD"
        case .cad:
            return "CAD"
        case .chf:
            return "CHF"
        case .cny:
            return "CNY"
        case .dkk:
            return "DKK"
        case .hkd:
            return "HKD"
        case.custom(code: let code, factor: _):
            return code
        }
    }
    
    /// A convertion factor represents how much Omise amount equals to 1 unit of this currency. eg. THB's factor is equals to 100.
    public var factor: Int {
        switch self {
        case .thb, .idr, .sgd, .usd, .gbp, .eur, .myr, .aud, .cad, .chf, .cny, .dkk, .hkd:
            return centBasedCurrencyFactor
        case .jpy:
            return identicalBasedCurrencyFactor
        case .custom(code: _, factor: let factor):
            return factor
        }
    }
    
    
    /// Create a currency with the given `ISO 4217` currency code
    ///
    /// - Parameter code: The ISO 4217 currency code for the creating Currency that will be created
    public init(code: String) {
        switch code.uppercased() {
        case Currency.thb.code:
            self = .thb
        case Currency.jpy.code:
            self = .jpy
        case Currency.idr.code:
            self = .idr
        case Currency.sgd.code:
            self = .sgd
        case Currency.usd.code:
            self = .usd
        case Currency.gbp.code:
            self = .gbp
        case Currency.eur.code:
            self = .eur
        case Currency.myr.code:
            self = .myr
        case Currency.aud.code:
            self = .aud
        case Currency.cad.code:
            self = .cad
        case Currency.chf.code:
            self = .chf
        case Currency.cny.code:
            self = .cny
        case Currency.dkk.code:
            self = .dkk
        case Currency.hkd.code:
            self = .hkd
        case let currencyCode:
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .currency
            numberFormatter.currencyCode = currencyCode
            let factor = Int(pow(10, Double(numberFormatter.maximumFractionDigits)))
            self = .custom(code: currencyCode, factor: factor)
        }
    }
    
    
    /// Convert the given subunit amount to the unit amount
    ///
    /// - Parameter value: Value in subunit (Satang in THB for example)
    /// - Returns: Value in unit (Baht in THB for example)
    public func convert(fromSubunit value: Int64) -> Double {
        return Double(value) / Double(factor)
    }
    
    /// Convert the given unit amount to the subunit amount
    ///
    /// - Parameter value: Value in unit (Baht in THB for example)
    /// - Returns: Value in subunit (Satang in THB for example)
    public func convert(toSubunit value: Double) -> Int64 {
        return Int64(value * Double(factor))
    }
}

extension Currency {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(code.uppercased())
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let code = try container.decode(String.self)
        self.init(code: code)
    }
}

