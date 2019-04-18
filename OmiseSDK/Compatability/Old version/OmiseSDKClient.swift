import Foundation


/// Client object as the main entry point for performing Omise API calls.
@available(*, deprecated, message: "Use the new `Client` type. This class will be removed in the future released", renamed: "Client")
public class OmiseSDKClient: NSObject {
    var client: Client
    
    var session: URLSession {
        return client.session
    }
    var queue: OperationQueue {
        return client.queue
    }
    
    @objc public var publicKey: String {
        return client.publicKey
    }
    
    @objc public var userAgent: String {
        return client.userAgent ?? Client.defaultUserAgent
    }
    
    /**
     Initializes OmiseSDKClient with default settings.
     - parameter publicKey: Omise public key.
     - note: Default settings use the default `NSOperationQueue` initializer and ephemeral
         `NSURLSessionConfiguration`.
     - seealso: init(publicKey:queue:session:)
     */
    public convenience init(publicKey: String) {
        let queue = OperationQueue()
        let session = URLSession(
            configuration: URLSessionConfiguration.ephemeral,
            delegate: nil,
            delegateQueue: queue
        )
        
        self.init(publicKey: publicKey, queue: queue, session: session)
    }
    
    /**
     Initializes OmiseSDKClient with custom `NSOperationQueue` and `NSURLSession`.
     - parameter publicKey: Omise public key.
     - parameter queue: `NSOperationQueue` for performing API calls. Callbacks will always
         be done on the main queue.
     - parameter session: `NSURLSession` for performing API calls.
     - seealso: init(publicKey:)
     */
    public init(publicKey: String, queue: OperationQueue, session: URLSession) {
        self.client = Client(publicKey: publicKey, queue: queue)
    }
    
    /**
     Send a tokenization request to the Omise API.
     - parameter request: `OmiseTokenRequest` instance.
     - parameter callback: Completion callback that will be called when request is finished.
     - seealso: OmiseTokenRequest
     - seealso: [Tokens API](https://www.omise.co/tokens-api)
     */
    public func send(_ request: OmiseTokenRequest, callback: OmiseTokenRequest.Callback?) {
        _ = client.send(request.request, completionHandler: { (result) in
            DispatchQueue.main.async {
                let tokenRequestResult: OmiseTokenRequestResult
                switch result {
                case .success(let token):
                    tokenRequestResult = .succeed(token: __OmiseToken(token: token))
                case .failure(let error):
                    tokenRequestResult = .fail(error: error)
                }
                callback?(tokenRequestResult)
            }
        })
    }
    
    /**
     Send a tokenization request to the Omise API
     - parameter request: Token Request
     - parameter delegate: An object that implements `OmiseTokenRequestDelegate` where
         request events delegate methods will be called on.
     - seealso: OmiseTokenRequest
     - seealso: [Tokens API](https://www.omise.co/tokens-api)
     */
    public func send(_ request: OmiseTokenRequest, delegate: OmiseTokenRequestDelegate?) {
        send(request) { (result) in
            switch result {
            case let .succeed(token):
                delegate?.tokenRequest(request, didSucceedWithToken: token)
            case let .fail(err):
                delegate?.tokenRequest(request, didFailWithError: err)
            }
        }
    }
}

