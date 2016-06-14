import Foundation
import UIKit

public class OmiseSDKClient: NSObject {
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
    
    public convenience init(publicKey: String) {
        let queue = NSOperationQueue()
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration(),
            delegate: nil,
            delegateQueue: queue)
        
        self.init(publicKey: publicKey, queue: queue, session: session)
    }
    
    public init(publicKey: String, queue: NSOperationQueue, session: NSURLSession) {
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
        request.startWith(self, callback: callback)
    }
    
    public func send(request: OmiseTokenRequest, delegate: OmiseTokenRequestDelegate?) {
        send(request) { (token, error) in
            guard token != nil || error != nil else {
                return sdkWarn("token request has neither token nor error data, delegate ignored.")
            }
            
            if let token = token {
                delegate?.tokenRequest(request, didSucceedWithToken: token)
            } else if let error = error {
                delegate?.tokenRequest(request, didFailWithError: error)
            }
        }
    }
    
}