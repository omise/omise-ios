import Foundation



@objc(OMSSDKClient) public class Client: NSObject {
    let session: URLSession
    let queue: OperationQueue
    let publicKey: String
    
    var userAgent: String?
    let sessionDelegate = Client.PublicKeyPinningSessionDelegate()
    
    
    /// Initializes a new Client with the given Public Key and Operating OperationQueue
    ///
    /// - Parameters:
    ///   - publicKey: Public Key for this Client used for calling the Omise API. The key must have `pkey` prefix
    ///   - queue: OperationQueue which the client uses for the network related operations
    @objc public init(publicKey: String, queue: OperationQueue) {
        if publicKey.hasPrefix("pkey_") {
            self.publicKey = publicKey
        } else {
            assertionFailure("refusing to initialize sdk client with a non-public key.")
            sdkWarn("refusing to initialize sdk client with a non-public key.")
            self.publicKey = ""
        }
        
        self.queue = queue
        self.session = URLSession(
            configuration: URLSessionConfiguration.ephemeral,
            delegate: sessionDelegate,
            delegateQueue: queue
        )
    }
    
    /// Initializes a new Client with the given Public Key
    ///
    /// - Parameters:
    ///   - publicKey: Public Key for this Client used for calling the Omise API. The key must have `pkey` prefix
    @objc public convenience init(publicKey: String) {
        self.init(publicKey: publicKey, queue: OperationQueue())
    }
    
    /// Create a new Reqeust Task with the given request and compleation handler closure
    ///
    /// - Parameters:
    ///   - request: A Request to create a requrest task
    ///   - completionHandler: Compleation Handler closure that will be called when the request task is finished.
    ///     The completion handler will be called on the main queue
    /// - Returns: A new Request Task
    public func requestTask<T: Object>(with request: Request<T>, completionHandler: Request<T>.Callback?) -> RequestTask<T> {
        let dataTask = session.dataTask(with: buildURLRequest(for: request), completionHandler: { (data, response, error) in
            DispatchQueue.main.async {
                Client.completeRequest(completionHandler)(data, response, error)
            }
        })
        return RequestTask(request: request, dataTask: dataTask)
    }
    
    /// Send the given Request to Omise API
    ///
    /// - Parameters:
    ///   - request: Request with a parameter to create a new Omise API object
    ///   - completionHandler: Compleation Handler closure that will be called when the request task is finished
    /// - Returns: A new Request Task
    @discardableResult
    public func sendRequest<T: Object>(_ request: Request<T>, completionHandler: Request<T>.Callback?) -> RequestTask<T> {
        let task = requestTask(with: request, completionHandler: completionHandler)
        defer {
            task.resume()
        }
        return task
    }
}


// MARK: - URL Request related methods
extension Client {
    
    private func buildURLRequest<T: Object>(for request: Request<T>) -> URLRequest {
        let urlRequest = NSMutableURLRequest(url: T.postURL)
        urlRequest.httpMethod = "POST"
        let encoder = Client.makeJSONEncoder()
        urlRequest.httpBody = try! encoder.encode(request.parameter)
        urlRequest.setValue(Client.encodeAuthorizationHeader(publicKey), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(userAgent ?? Client.defaultUserAgent, forHTTPHeaderField: "User-Agent")
        urlRequest.setValue("application/json; charset=utf8", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("2017-11-02", forHTTPHeaderField: "Omise-Version")
        return urlRequest.copy() as! URLRequest
    }
    
    private static func encodeAuthorizationHeader(_ publicKey: String) -> String {
        let data = publicKey.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        let base64 = data.base64EncodedString()
        return "Basic \(base64)"
    }
    
    static func makeJSONEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(Client.jsonDateFormatter)
        return encoder
    }
    
    static func makeJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Client.jsonDateFormatter)
        return decoder
    }
    
    private static func completeRequest<T: Object>(_ callback: Request<T>.Callback?) -> (Data?, URLResponse?, Error?) -> () {
        return { (data: Data?, response: URLResponse?, error: Error?) -> () in
            guard let callback = callback else { return } // nobody around to hear the leaf falls
            
            if let error = error {
                return callback(.fail(error))
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = OmiseError.unexpected(message: "no error and no response.", underlying: nil)
                return callback(.fail(error))
            }
            
            switch httpResponse.statusCode {
            case 400..<600:
                guard let data = data else {
                    let error = OmiseError.unexpected(message: "error response with no data", underlying: nil)
                    return callback(.fail(error))
                }
                
                do {
                    let decoder = makeJSONDecoder()
                    return callback(.fail(try decoder.decode(OmiseError.self, from: data)))
                } catch let err {
                    let error = OmiseError.unexpected(message: "error response with invalid JSON", underlying: err)
                    return callback(.fail(error))
                }
                
            case 200..<300:
                guard let data = data else {
                    let error = OmiseError.unexpected(message: "HTTP 200 but no data", underlying: nil)
                    return callback(.fail(error))
                }
                
                do {
                    let decoder = makeJSONDecoder()
                    return callback(.success(try decoder.decode(T.self, from: data)))
                } catch let err {
                    let error = OmiseError.unexpected(message: "200 response with invalid JSON", underlying: err)
                    return callback(.fail(error))
                }
                
            default:
                let error = OmiseError.unexpected(message: "unrecognized HTTP status code: \(httpResponse.statusCode)", underlying: nil)
                return callback(.fail(error))
            }
        }
    }

}


// MARK: - Constants
extension Client {
    static let version: String = {
        let bundle = Bundle(identifier: "co.omise.OmiseSDK")
        assert(bundle != nil)
        return bundle?.infoDictionary?["CFBundleShortVersionString"] as? String ?? "(n/a)"
    }()
    
    static let currentPlatform: String = ProcessInfo.processInfo.operatingSystemVersionString
    static let currentDevice: String = UIDevice.current.model
    
    static let jsonDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")!
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter
    }()
    
    static var defaultUserAgent: String {
        return """
        OmiseIOSSDK/\(version) \
        iOS/\(currentPlatform) \
        Apple/\(currentDevice)
        """ // OmiseIOSSDK/3.0.0 iOS/12.0.0 Apple/iPhone
    }
}

