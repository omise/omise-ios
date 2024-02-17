import Foundation

func localized(_ code: String, text: String = "", _ comment: String = "") -> String {
    NSLocalizedString(code, bundle: .omiseSDK, value: text, comment: comment)
}
