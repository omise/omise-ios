import Foundation
import UIKit


/// Client object as the main entry point for performing Omise API calls.
@objc(OMSSDKClient) public class OmiseSDKClient: NSObject {
    let session: NSURLSession
    let queue: NSOperationQueue
    let publicKey: String
    
    let version: String = {
        let bundle = NSBundle(forClass: OmiseSDKClient.self)
        return bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "(n/a)"
    }()
    
    let currentPlatform: String = NSProcessInfo.processInfo().operatingSystemVersionString
    let currentDevice: String = UIDevice.currentDevice().model
    
    var userAgent: String {
        return "OmiseIOSSDK/\(version) " +
            "iOS/\(currentPlatform) " +
            "Apple/\(currentDevice)"
    }
    
    /**
     Initializes OmiseSDKClient with default settings.
     - parameter publicKey: Omise public key.
     - note: Default settings use the default `NSOperationQueue` initializer and ephemeral
         `NSURLSessionConfiguration`.
     - seealso: init(publicKey:queue:session:)
     */
    @objc public convenience init(publicKey: String) {
        let queue = NSOperationQueue()
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration(),
            delegate: nil,
            delegateQueue: queue)
        
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
    @objc public init(publicKey: String, queue: NSOperationQueue, session: NSURLSession) {
        self.queue = queue
        self.session = session
        
        if !publicKey.hasPrefix("pkey_") {
            sdkWarn("refusing to initialize sdk client with a non-public key.")
            self.publicKey = ""
        } else {
            self.publicKey = publicKey
        }
    }
    
    /**
     Send a tokenization request to the Omise API.
     - parameter request: `OmiseTokenRequest` instance.
     - parameter callback: Completion callback that will be called when request is finished.
     - seealso: OmiseTokenRequest
     - seealso: [Tokens API](https://www.omise.co/tokens-api)
     */
    public func send(request: OmiseTokenRequest, callback: OmiseTokenRequest.Callback?) {
        request.startWith(self) { (result) in
            dispatch_async(dispatch_get_main_queue(), { 
                callback?(result)
            })
        }
    }
    
    /**
     Send a tokenization request to the Omise API.
     - parameter request: `OmiseTokenRequest` instance.
     - parameter callback: Completion callback that will be called when the request is finished.
     - seealso: OmiseTokenRequest
     - seealso: [Tokens API](https://www.omise.co/tokens-api)
     */
    @objc(sendRequest:callback:) public func __send(request: OmiseTokenRequest, callback: ((OmiseToken?, NSError?) -> ())?) {
        request.startWith(self) { (result) in
            dispatch_async(dispatch_get_main_queue(), {
                let token: OmiseToken?
                let error: NSError?
                switch result {
                case .Succeed(token: let resultToken):
                    token = resultToken
                    error = nil
                case .Fail(error: let requestError):
                    if let requestError = requestError as? OmiseError {
                        error = requestError.nsError
                    } else {
                        error = requestError as NSError
                    }
                    token = nil
                }
                
                callback?(token, error)
            })
        }
    }
    
    /**
     Send a tokenization request to the Omise API
     - parameter request: Token Request
     - parameter delegate: An object that implements `OmiseTokenRequestDelegate` where
         request events delegate methods will be called on.
     - seealso: OmiseTokenRequest
     - seealso: [Tokens API](https://www.omise.co/tokens-api)
     */
    public func send(request: OmiseTokenRequest, delegate: OmiseTokenRequestDelegate?) {
        send(request) { (result) in
            switch result {
            case let .Succeed(token):
                delegate?.tokenRequest(request, didSucceedWithToken: token)
            case let .Fail(err):
                delegate?.tokenRequest(request, didFailWithError: err)
            }
        }
    }
    
    /**
     Send a tokenization request to the Omise API
     - parameter request: `OmiseTokenRequest` instance.
     - parameter delegate: An object that implements `OmiseTokenRequestDelegate` where
         request events delegate methods will be called on.
     - seealso: OmiseTokenRequest
     - seealso: [Tokens API](https://www.omise.co/tokens-api)
     */
    @objc(sendRequest:delegate:) public func __send(request: OmiseTokenRequest, delegate: OMSTokenRequestDelegate?) {
        send(request) { (result) in
            switch result {
            case let .Succeed(token):
                delegate?.tokenRequest(request, didSucceedWithToken: token)
            case let .Fail(err):
                let error = err as NSError
                delegate?.tokenRequest(request, didFailWithError: error)
            }
        }
    }
}

