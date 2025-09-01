import Foundation

extension String {
    static var phoneNumberRegexPattern: String {
        #"^\d{7,15}$"#
    }
    
    static var emailRegexPattern: String {
        "\\A[\\w\\-\\.]+@[\\w\\-\\.]+\\.[a-zA-Z]{2,}\\s?\\z"
    }
    
    func localized(_ defaultValue: String? = nil) -> String {
        NSLocalizedString(
            self,
            tableName: "Localizable",
            bundle: .omiseSDK,
            value: defaultValue ?? self,
            comment: ""
        )
    }
}
