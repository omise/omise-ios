import Foundation

public let centBasedCurrencyFactor = 100
public let identicalBasedCurrencyFactor = 1

public enum Currency: Codable, Hashable {

    enum CurrencyCode: String {
        case thb = "THB"
        case jpy = "JPY"
        case idr = "IDR"
        case sgd = "SGD"
        case usd = "USD"
        case gbp = "GBP"
        case eur = "EUR"
        case myr = "MYR"
        case aud = "AUD"
        case cad = "CAD"
        case chf = "CHF"
        case cny = "CNY"
        case dkk = "DKK"
        case hkd = "HKD"
    }

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
    
    static let main: Currency = .thb

    public var code: String {
        switch self {
        case .thb: return CurrencyCode.thb.rawValue
        case .jpy: return CurrencyCode.jpy.rawValue
        case .idr: return CurrencyCode.idr.rawValue
        case .sgd: return CurrencyCode.sgd.rawValue
        case .usd: return CurrencyCode.usd.rawValue
        case .gbp: return CurrencyCode.gbp.rawValue
        case .eur: return CurrencyCode.eur.rawValue
        case .myr: return CurrencyCode.myr.rawValue
        case .aud: return CurrencyCode.aud.rawValue
        case .cad: return CurrencyCode.cad.rawValue
        case .chf: return CurrencyCode.chf.rawValue
        case .cny: return CurrencyCode.cny.rawValue
        case .dkk: return CurrencyCode.dkk.rawValue
        case .hkd: return CurrencyCode.hkd.rawValue
        case.custom(code: let code, factor: _): return code
        }
    }

    /// Create a currency with the given `ISO 4217` currency code
    ///
    /// - Parameter code: The ISO 4217 currency code for the creating Currency that will be created
    public init(code: String?) {
        guard let code = code else {
            self = Currency.main
            return
        }

        switch code.uppercased() {
        case CurrencyCode.thb.rawValue: self = .thb
        case CurrencyCode.jpy.rawValue: self = .jpy
        case CurrencyCode.idr.rawValue: self = .idr
        case CurrencyCode.sgd.rawValue: self = .sgd
        case CurrencyCode.usd.rawValue: self = .usd
        case CurrencyCode.gbp.rawValue: self = .gbp
        case CurrencyCode.eur.rawValue: self = .eur
        case CurrencyCode.myr.rawValue: self = .myr
        case CurrencyCode.aud.rawValue: self = .aud
        case CurrencyCode.cad.rawValue: self = .cad
        case CurrencyCode.chf.rawValue: self = .chf
        case CurrencyCode.cny.rawValue: self = .cny
        case CurrencyCode.dkk.rawValue: self = .dkk
        case CurrencyCode.hkd.rawValue: self = .hkd
        case let currencyCode:
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .currency
            numberFormatter.currencyCode = currencyCode
            let factor = Int(pow(10, Double(numberFormatter.maximumFractionDigits)))
            self = .custom(code: currencyCode, factor: factor)
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
