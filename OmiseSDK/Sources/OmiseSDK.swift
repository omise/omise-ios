import Foundation

public class OmiseSDK {
    public let version: String = "5.0.0"
    public static let shared = OmiseSDK()
    
    /// CountryInfo received from Capabilities API response
    public private(set) var country: CountryInfo?
}

extension OmiseSDK {
    func setCountry(countryCode: String) {
        self.country = CountryInfo(code: countryCode)
    }
}
