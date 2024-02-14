import Foundation

public class OmiseSDK {
    public let version: String = "5.0.0"
    public static let shared = OmiseSDK()
    
    /// Shared current country, allows to use it for pre-selected values on UI forms
    public private(set) var currentCountry: Country?
}

extension OmiseSDK {
    func setCurrentCountry(countryCode: String) {
        self.currentCountry = Country(code: countryCode)
    }
}
