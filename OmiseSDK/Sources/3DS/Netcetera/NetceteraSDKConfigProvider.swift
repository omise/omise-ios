import ThreeDS_SDK
import CommonCrypto

public protocol NetceteraSDKConfigProviding {
    var logLevel: LogLevel { get } // NOSONAR: simple accessor required by protocol
    var locale: Locale? { get } // NOSONAR: simple accessor required by protocol
    func apiKey(for config: NetceteraSDKConfig) throws -> String
    func makeScheme(for config: NetceteraSDKConfig) -> Scheme?
}

public final class NetceteraSDKConfigProvider: NetceteraSDKConfigProviding {
    public let logLevel: LogLevel
    public let locale: Locale?
    
    public init(logLevel: LogLevel = .info, locale: Locale? = nil) {
        self.logLevel = logLevel
        self.locale = locale
    }
    
    public func apiKey(for config: NetceteraSDKConfig) throws -> String {
        let decryptionKey = config.directoryServerId.sha512.subdata(in: 0..<32)
        
        guard let ciphertext = Data(base64Encoded: config.key) else {
            throw NetceteraSDKConfigError.invalidKeyEncoding
        }

        guard ciphertext.count > 16 else {
            throw NetceteraSDKConfigError.invalidKeyEncoding
        }
        
        let iv = ciphertext.subdata(in: 0..<16)
        let ciphertextWithoutIV = ciphertext.subdata(in: 16..<ciphertext.count)
        
        let decrypted: Data
        do {
            decrypted = try cryptData(
                ciphertextWithoutIV,
                operation: CCOperation(kCCDecrypt),
                mode: CCMode(kCCModeCTR),
                algorithm: CCAlgorithm(kCCAlgorithmAES),
                padding: CCPadding(ccNoPadding),
                keyLength: kCCKeySizeAES256,
                iv: iv,
                key: decryptionKey
            )
        } catch {
            throw NetceteraSDKConfigError.cryptoError(error)
        }
        
        guard let apiKey = String(data: decrypted, encoding: .utf8) else {
            throw NetceteraSDKConfigError.apiKeyInvalid
        }
        
        return apiKey
    }
    
    public func makeScheme(for config: NetceteraSDKConfig) -> Scheme? {
        NetceteraSDKBridge.newScheme(config: config)
    }
}
