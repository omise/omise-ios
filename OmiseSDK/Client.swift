import Foundation


public class Client {
    let session: URLSession
    let queue: OperationQueue
    let publicKey: String
    
    var userAgent: String?
    
    public convenience init(publicKey: String) {
        let queue = OperationQueue()
        let session = URLSession(
            configuration: URLSessionConfiguration.ephemeral,
            delegate: nil,
            delegateQueue: queue
        )
        
        self.init(publicKey: publicKey, queue: queue, session: session)
    }
    
    public init(publicKey: String, queue: OperationQueue, session: URLSession) {
        self.queue = queue
        self.session = session
        
        if publicKey.hasPrefix("pkey_") {
            self.publicKey = publicKey
        } else {
            assertionFailure("refusing to initialize sdk client with a non-public key.")
            sdkWarn("refusing to initialize sdk client with a non-public key.")
            self.publicKey = ""
        }
    }
    
    private func buildURLRequestFor<T: Object>(_ request: Request<T>) throws -> URLRequest {
        let urlRequest = NSMutableURLRequest(url: T.postURL)
        urlRequest.httpMethod = "POST"
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(Client.jsonDateFormatter)
        urlRequest.httpBody = try encoder.encode(request.parameter)
        urlRequest.setValue(try Client.encodeAuthorizationHeader(publicKey), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(userAgent ?? Client.defaultUserAgent, forHTTPHeaderField: "User-Agent")
        return urlRequest.copy() as! URLRequest
    }
    
    private static func encodeAuthorizationHeader(_ publicKey: String) throws -> String {
        let data = publicKey.data(using: String.Encoding.utf8, allowLossyConversion: false)
        guard let base64 = data?.base64EncodedString() else {
            throw OmiseError.unexpected(message: "public key encoding failure.", underlying: nil)
        }
        
        return "Basic \(base64)"
    }
}

extension Client {
    static let version: String = {
        let bundle = Bundle(for: OmiseSDKClient.self)
        return bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "(n/a)"
    }()
    
    static let currentPlatform: String = ProcessInfo.processInfo.operatingSystemVersionString
    
    static let currentDevice: String = UIDevice.current.model
    
    static let jsonDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")!
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }()
    
    static var defaultUserAgent: String {
        return """
        OmiseIOSSDK/\(version) \
        iOS/\(currentPlatform) \
        Apple/\(currentDevice)
        """
    }
}

