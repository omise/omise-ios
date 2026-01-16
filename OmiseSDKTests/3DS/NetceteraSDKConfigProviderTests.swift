import XCTest
@testable import OmiseSDK

final class NetceteraSDKConfigProviderTests: XCTestCase {
    func test_apiKeyThrowsWhenCiphertextTooShort() {
        let provider = NetceteraSDKConfigProvider()
        let config = NetceteraSDKConfig(
            id: "id",
            deviceInfoEncryptionAlg: "alg",
            deviceInfoEncryptionEnc: "enc",
            deviceInfoEncryptionCertPem: "",
            directoryServerId: "dir",
            key: "AAA=", // decodes to fewer than 16 bytes
            messageVersion: "2.1.0"
        )

        XCTAssertThrowsError(try provider.apiKey(for: config)) { error in
            let typed = error as? NetceteraSDKConfigError
            XCTAssertEqual(typed, .invalidKeyEncoding)
        }
    }
}
