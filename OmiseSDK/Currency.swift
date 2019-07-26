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
            return OMSSupportedCurrencyCode.THB.rawValue
        case .jpy:
            return OMSSupportedCurrencyCode.JPY.rawValue
        case .idr:
            return OMSSupportedCurrencyCode.IDR.rawValue
        case .sgd:
            return OMSSupportedCurrencyCode.SGD.rawValue
        case .usd:
            return OMSSupportedCurrencyCode.USD.rawValue
        case .gbp:
            return OMSSupportedCurrencyCode.GBP.rawValue
        case .eur:
            return OMSSupportedCurrencyCode.EUR.rawValue
        case .myr:
            return OMSSupportedCurrencyCode.MYR.rawValue
        case .aud:
            return OMSSupportedCurrencyCode.AUD.rawValue
        case .cad:
            return OMSSupportedCurrencyCode.CAD.rawValue
        case .chf:
            return OMSSupportedCurrencyCode.CHF.rawValue
        case .cny:
            return OMSSupportedCurrencyCode.CNY.rawValue
        case .dkk:
            return OMSSupportedCurrencyCode.DKK.rawValue
        case .hkd:
            return OMSSupportedCurrencyCode.HKD.rawValue
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
        case OMSSupportedCurrencyCode.THB.rawValue:
            self = .thb
        case OMSSupportedCurrencyCode.JPY.rawValue:
            self = .jpy
        case OMSSupportedCurrencyCode.IDR.rawValue:
            self = .idr
        case OMSSupportedCurrencyCode.SGD.rawValue:
            self = .sgd
        case OMSSupportedCurrencyCode.USD.rawValue:
            self = .usd
        case OMSSupportedCurrencyCode.GBP.rawValue:
            self = .gbp
        case OMSSupportedCurrencyCode.EUR.rawValue:
            self = .eur
        case OMSSupportedCurrencyCode.MYR.rawValue:
            self = .myr
        case OMSSupportedCurrencyCode.AUD.rawValue:
            self = .aud
        case OMSSupportedCurrencyCode.CAD.rawValue:
            self = .cad
        case OMSSupportedCurrencyCode.CHF.rawValue:
            self = .chf
        case OMSSupportedCurrencyCode.CNY.rawValue:
            self = .cny
        case OMSSupportedCurrencyCode.DKK.rawValue:
            self = .dkk
        case OMSSupportedCurrencyCode.HKD.rawValue:
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

