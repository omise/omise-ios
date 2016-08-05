import Foundation
import UIKit

@objc(OMSOmiseSDKClient) public class OmiseSDKClient: NSObject {
    let session: NSURLSession
    let queue: NSOperationQueue
    let publicKey: String
    
    var version: String {
        let bundle = NSBundle(forClass: OmiseSDKClient.self)
        return bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "(n/a)"
    }
    
    var currentPlatform: String {
        return NSProcessInfo.processInfo().operatingSystemVersionString
    }
    
    var currentDevice: String {
        return UIDevice.currentDevice().model
    }
    
    var userAgent: String {
        return "OmiseIOSSDK/\(version) " +
            "iOS/\(currentPlatform) " +
            "Apple/\(currentDevice)"
    }
    
    @objc public convenience init(publicKey: String) {
        let queue = NSOperationQueue()
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration(),
            delegate: nil,
            delegateQueue: queue)
        
        self.init(publicKey: publicKey, queue: queue, session: session)
    }
    
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
    
    public func send(request: OmiseTokenRequest, callback: OmiseTokenRequest.Callback?) {
        request.startWith(self) { (result) in
            dispatch_async(dispatch_get_main_queue(), { 
                callback?(result)
            })
        }
    }
    
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
    
    @objc(sendRequest:delegate:) public func __send(request: OmiseTokenRequest, delegate: OMSOmiseTokenRequestDelegate?) {
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

