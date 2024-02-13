import Foundation

extension Client {
    /// Creates urlRequest and performs API request with currenly used Network Service
    /// - returns Generic Decodable from JSON string
    func apiRequest<T: Decodable>(api: APIProtocol, completion: @escaping RequestResultClosure<T, Error>) {
        let urlRequest = urlRequest(publicKey: publicKey, api: api)
        network.send(
            urlRequest: urlRequest,
            dateFormatter: api.dateFormatter,
            completion: completion
        )
    }

    /// Observe Token Charge Status until it changes
    /// Sends API request every `timeInterval` with number of`maxAttempt`attempts.
    /// - Parameters:
    ///   - tokenId: Token ID
    ///   - timeInterval: TimeInterval between polling requests
    ///   - attemp: Current attemp
    ///   - maxAttempt: Maximum number of attemps
    func observeChargeStatusUntilChange(
        tokenID: String,
        timeInterval: Int,
        attemp: Int,
        maxAttempt: Int,
        _ completion: @escaping RequestResultClosure<Token.ChargeStatus, Error>
    ) {
        guard maxAttempt > attemp else {
            return
        }
        token(tokenID: tokenID) { [weak self] (result: (Result<Token, Error>)) in
            switch result {
            case .success(let token) where token.chargeStatus.isFinal:
                completion(.success(token.chargeStatus))
            case .success(let token):
                guard attemp + 1 < maxAttempt else {
                    completion(.success(token.chargeStatus))
                    return
                }

                let queue = DispatchQueue.global(qos: .background)
                queue.asyncAfter(deadline: .now() + .seconds(timeInterval)) {
                    self?.observeChargeStatusUntilChange(
                        tokenID: tokenID,
                        timeInterval: timeInterval,
                        attemp: attemp + 1,
                        maxAttempt: maxAttempt,
                        completion
                    )
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Perform Token API request with given Token ID
    /// - returns Token
    func token(tokenID: String, _ completion: @escaping RequestResultClosure<Token, Error>) {
        apiRequest(api: OmiseAPI.token(tokenID: tokenID), completion: completion)
    }
}
