import Foundation
import UIKit

let OMISE_SDK_VERSION = "2.1.0"
let SWIFT_VERSION = "2.2"
let IOS_VERSION = NSProcessInfo.processInfo().operatingSystemVersionString
let DEVICE = UIDevice.currentDevice().model

public protocol OmiseTokenizerDelegate {
    func tokenRequestDidSucceed(request: OmiseTokenRequest, token: OmiseToken)
    func tokenRequestDidFail(request: OmiseTokenRequest, error: ErrorType)
}

public class Omise: NSObject {
    public typealias Callback = OmiseTokenRequest.Callback
    private var delegate: OmiseTokenizerDelegate?
    public let publicKey: String
    
    let session: NSURLSession
    private var queue: NSOperationQueue
    
    // MARK: - Initial
    public init(publicKey: String) {
        self.publicKey = publicKey
        self.queue = NSOperationQueue()
        self.session = NSURLSession(
            configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration(),
            delegate: nil,
            delegateQueue: queue)
    }
    
    public func send(request: OmiseTokenRequest, callback: Callback?) {
        request.startWith(self, callback: callback)
    }
    
    public func send(request: OmiseTokenRequest, delegate: OmiseTokenizerDelegate?) {
        self.send(request) { (token, error) in
            
            if let token = token {
                delegate?.tokenRequestDidSucceed(request, token: token)
            } else if let error = error {
                delegate?.tokenRequestDidFail(request, error: error)
            }
        }
    }
    
}