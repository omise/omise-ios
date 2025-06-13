import Foundation

extension OmiseError {
    func getLocalizedError(_ key: String, defaultValue: String = "", comment: String = "") -> String {
        NSLocalizedString(
            key,
            tableName: "Error",
            bundle: .omiseSDK,
            value: defaultValue,
            comment: comment
        )
    }
}

extension OmiseError.APIErrorCode.BadRequestReason {
    func getLocalizedError(_ key: String, defaultValue: String = "", comment: String = "") -> String {
        NSLocalizedString(
            key,
            tableName: "Error",
            bundle: .omiseSDK,
            value: defaultValue,
            comment: comment
        )
    }
}
