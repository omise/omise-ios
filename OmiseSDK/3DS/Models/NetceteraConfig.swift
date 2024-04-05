import Foundation

public struct NetceteraConfig {
    public let id: String
    public let deviceInfoEncryptionAlg: String
    public let deviceInfoEncryptionEnc: String
    public let deviceInfoEncryptionCertPem: String
    public let directoryServerId: String
    public let key: String
    public let messageVersion: String
}

extension NetceteraConfig: Decodable {
    /// Mapping keys to encode/decode JSON string
    private enum CodingKeys: String, CodingKey {
        case id = "identifier"
        case deviceInfoEncryptionAlg = "device_info_encryption_alg"
        case deviceInfoEncryptionEnc = "device_info_encryption_enc"
        case deviceInfoEncryptionCertPem = "device_info_encryption_cert_pem"
        case directoryServerId = "directory_server_id"
        case key
        case messageVersion = "messageVersion"
    }
}
