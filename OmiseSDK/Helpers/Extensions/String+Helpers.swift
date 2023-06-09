import Foundation

extension String {
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
