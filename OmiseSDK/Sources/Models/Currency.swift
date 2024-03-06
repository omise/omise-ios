import Foundation

public let centBasedCurrencyFactor = 100
public let identicalBasedCurrencyFactor = 1

public enum Currency: String, Codable, Hashable {
    case aud = "AUD"
    case cad = "CAD"
    case chf = "CHF"
    case cny = "CNY"
    case dkk = "DKK"
    case eur = "EUR"
    case gbp = "GBP"
    case hkd = "HKD"
    case idr = "IDR"
    case jpy = "JPY"
    case myr = "MYR"
    case sgd = "SGD"
    case thb = "THB"
    case usd = "USD"

    static let main: Currency = .thb

    public var code: String {
        rawValue
    }

    /// Create a currency with the given `ISO 4217` currency code
    ///
    /// - Parameter code: The ISO 4217 currency code for the creating Currency that will be created
    public init(code: String?) {
        if let code = code {
            self = Currency(rawValue: code) ?? .main
        } else {
            self = .main
        }
    }

    /// A conversion factor represents how much Omise amount equals to 1 unit of this currency. eg. THB's factor is equals to 100.
    public var factor: Int {
        if case .jpy = self {
            return identicalBasedCurrencyFactor
        } else {
            return centBasedCurrencyFactor
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
