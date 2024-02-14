import Foundation

public class OmiseSDK {
    public let version: String = "5.0.0"
    public static let shared = OmiseSDK()
    
    /// Country received from Capabilities API response
    public private(set) var country: Country?
}

extension OmiseSDK {
    func setCountry(countryCode: String) {
        self.country = Country(code: countryCode)
    }
}
