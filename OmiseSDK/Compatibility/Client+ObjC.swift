import Foundation

extension Client {
    
    @available(*, deprecated, renamed: "init(publicKey:queue:)")
    @objc public convenience init(publicKey: String, queue: OperationQueue, session: URLSession) {
        self.init(publicKey: publicKey, queue: OperationQueue())
    }

    /**
     Send a tokenization request to the Omise API.
     - parameter request: `OmiseTokenRequest` instance.
     - parameter callback: Completion callback that will be called when the request is finished.
     - seealso: OmiseTokenRequest
     - seealso: [Tokens API](https://www.omise.co/tokens-api)
     */
    @objc(sendTokenRequest:callback:)
    // swiftlint:disable:next attributes identifier_name
    public func __sendRequest(_ request: __OMSTokenRequest, callback: ((__OmiseToken?, NSError?) -> Void)?) {
        self.send(request.request) { result in
            let token: __OmiseToken?
            let error: NSError?
            
            switch result {
            case .success(let resultToken):
                token = __OmiseToken(token: resultToken)
                error = nil
            case .failure(let requestError):
                error = requestError as NSError
                token = nil
            }
            
            callback?(token, error)
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
    @objc(sendTokenRequest:delegate:)
    // swiftlint:disable:next attributes identifier_name
    public func __sendRequest(_ request: __OMSTokenRequest, delegate: OMSTokenRequestDelegate?) {
        self.send(request.request) { result in
            switch result {
            case let .success(token):
                delegate?.tokenRequest(request, didSucceedWithToken: __OmiseToken(token: token))
            case let .failure(err):
                let error = err as NSError
                delegate?.tokenRequest(request, didFailWithError: error)
            }
        }
    }
    
    @available(*, deprecated, message: "Please use the new -[OMSClient sendTokenRequest:callback:] method",
    renamed: "sendTokenRequest(_:completionHandler:)")
    @objc(sendRequest:callback:)
    // swiftlint:disable:next attributes identifier_name
    public func ___sendRequest(_ request: __OMSTokenRequest, callback: ((__OmiseToken?, NSError?) -> Void)?) {
        self.__sendRequest(request, callback: callback)
    }
    
    @available(*, deprecated, message: "Please use the new -[OMSClient sendTokenRequest:callback:] method",
    renamed: "sendTokenRequest(_:completionHandler:)")
    @objc(sendRequest:delegate:)
    // swiftlint:disable:next attributes identifier_name
    public func ___sendRequest(_ request: __OMSTokenRequest, delegate: OMSTokenRequestDelegate?) {
        self.__sendRequest(request, delegate: delegate)
    }
    
    /**
     Send a tokenization request to the Omise API.
     - parameter request: `OmiseTokenRequest` instance.
     - parameter callback: Completion callback that will be called when the request is finished.
     - seealso: OmiseTokenRequest
     - seealso: [Tokens API](https://www.omise.co/tokens-api)
     */
    @objc(sendSourceRequest:callback:)
    // swiftlint:disable:next attributes identifier_name
    public func __sendRequest(_ request: __OMSSourceRequest, callback: ((__OmiseSource?, NSError?) -> Void)?) {
        self.send(request.request) { result in
            let token: __OmiseSource?
            let error: NSError?
            
            switch result {
            case .success(let resultToken):
                token = __OmiseSource(source: resultToken)
                error = nil
            case .failure(let requestError):
                error = requestError as NSError
                token = nil
            }
            
            callback?(token, error)
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
    @objc(sendSourceRequest:delegate:)
    // swiftlint:disable:next attributes identifier_name
    public func __sendRequest(_ request: __OMSSourceRequest, delegate: OMSSourceRequestDelegate?) {
        self.send(request.request) { result in
            switch result {
            case let .success(token):
                delegate?.sourceRequest(request, didSucceedWithSource: __OmiseSource(source: token))
            case let .failure(err):
                let error = err as NSError
                delegate?.sourceRequest(request, didFailWithError: error)
            }
        }
    }
    
    @objc(capabilityDataWithCompletionHandler:)
    // swiftlint:disable:next attributes identifier_name
    public func __capabilityDataWithCompletionHandler(_ completionHandler: ((__OmiseCapability?, NSError?) -> Void)?) {
        self.capabilityDataWithCompletionHandler { (result) in
            switch result {
            case .success(let capability):
                completionHandler?(__OmiseCapability(capability: capability), nil)
            case .failure(let error):
                completionHandler?(nil, error as NSError)
            }
        }
    }
}
