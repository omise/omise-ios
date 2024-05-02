import Foundation

extension String {
    var pemCertificate: String {
        self
            .replacingOccurrences(of: "-----BEGIN CERTIFICATE-----", with: "")
            .replacingOccurrences(of: "-----END CERTIFICATE-----", with: "")
            .replacingOccurrences(of: "\r\n", with: "")
    }
}
