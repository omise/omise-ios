import Foundation


public class Client {
    let session: URLSession
    let queue: OperationQueue
    let publicKey: String
    
    var userAgent: String?
    
    public typealias Callback<T: Object> = (RequestResult<T>) -> ()

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
    
    public func requestTask<T: Object>(with request: Request<T>, completionHandler: Callback<T>?) -> RequestTask<T> {
        let dataTask = session.dataTask(with: try! buildURLRequestFor(request), completionHandler: Client.completeRequest(completionHandler))
        return RequestTask(request: request, dataTask: dataTask)
    }
    
}


// MARK: - URL Request related methods
extension Client {
    
    private func buildURLRequestFor<T: Object>(_ request: Request<T>) throws -> URLRequest {
        let urlRequest = NSMutableURLRequest(url: T.postURL)
        urlRequest.httpMethod = "POST"
        let encoder = Client.makeJSONEncoder()
        urlRequest.httpBody = try encoder.encode(request.parameter)
        urlRequest.setValue(try Client.encodeAuthorizationHeader(publicKey), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(userAgent ?? Client.defaultUserAgent, forHTTPHeaderField: "User-Agent")
        urlRequest.setValue("application/json; charset=utf8", forHTTPHeaderField: "Content-Type")
        return urlRequest.copy() as! URLRequest
    }
    
    private static func encodeAuthorizationHeader(_ publicKey: String) throws -> String {
        let data = publicKey.data(using: String.Encoding.utf8, allowLossyConversion: false)
        guard let base64 = data?.base64EncodedString() else {
            throw OmiseError.unexpected(message: "public key encoding failure.", underlying: nil)
        }
        
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
    
    private static func completeRequest<T: Object>(_ callback: Callback<T>?) -> (Data?, URLResponse?, Error?) -> () {
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
                    return callback(.fail(try OmiseJsonParser.parseError(from: data)))
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
        let bundle = Bundle(for: OmiseSDKClient.self)
        return bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "(n/a)"
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
        """
    }
}

