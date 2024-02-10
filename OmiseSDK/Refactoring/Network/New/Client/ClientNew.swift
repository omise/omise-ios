import Foundation
import os

// TODO: Rename to Client
public class ClientNew {
    private let publicKey: String
    private let network: NetworkService

    public convenience init(publicKey: String) {
        self.init(publicKey: publicKey, network: NetworkService())
    }

    init(publicKey: String, network: NetworkService) {
        self.publicKey = publicKey
        self.network = network
    }

    // TODO: Add unit tests
    public func capability(_ completionHandler: @escaping (Result<CapabilityNew, Error>) -> Void) {
        apiRequest(api: OmiseAPI.capability) { (result: (Result<CapabilityNew, Error>)) in
            if let capability = try? result.get() {
                OmiseSDK.shared.setCurrentCountry(countryCode: capability.countryCode)
            }
            completionHandler(result)
        }
    }

    // TODO: Add unit tests
    public func observeChargeStatusUntilChange(tokenID: String, _ completionHandler: @escaping (Result<TokenNew.ChargeStatus, Error>) -> Void) {
        observeChargeStatusUntilChange(
            tokenID: tokenID,
            timeInterval: 3,
            attemp: 0,
            maxAttempt: 3,
            completionHandler
        )
    }

    // TODO: Add unit tests
    public func createToken(cardInfo: String) {
        // TODO: Add Implementation after PaymentInformation refactoring
    }

    // TODO: Add unit tests
    public func createSource(paymentInfo: String) {
        // TODO: Add Implementation after PaymentInformation refactoring
    }
}

private extension ClientNew {
    private func observeChargeStatusUntilChange(
        tokenID: String,
        timeInterval: Int,
        attemp: Int,
        maxAttempt: Int,
        _ completionHandler: @escaping (Result<TokenNew.ChargeStatus, Error>) -> Void
    ) {
        guard maxAttempt > attemp else {
            return
        }
        token(tokenID: tokenID) { [weak self] (result: (Result<TokenNew, Error>)) in
            switch result {
            case .success(let token) where token.chargeStatus.isFinal:
                completionHandler(.success(token.chargeStatus))
            case .success(let token):
                guard attemp + 1 < maxAttempt else {
                    completionHandler(.success(token.chargeStatus))
                    return
                }

                let queue = DispatchQueue.global(qos: .background)
                queue.asyncAfter(deadline: .now() + .seconds(timeInterval)) {
                    self?.observeChargeStatusUntilChange(
                        tokenID: tokenID,
                        timeInterval: timeInterval,
                        attemp: attemp + 1,
                        maxAttempt: maxAttempt,
                        completionHandler
                    )
                }

            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }

    func token(tokenID: String, _ completionHandler: @escaping (Result<TokenNew, Error>) -> Void) {
        apiRequest(api: OmiseAPI.token(tokenID: tokenID), completionHandler: completionHandler)
    }

    func apiRequest<T: Codable>(api: APIProtocol, completionHandler: @escaping (Result<T, Error>) -> Void) {
        let urlRequest = urlRequest(publicKey: publicKey, api: api)
        network.get(
            urlRequest: urlRequest,
            dateFormatter: api.dateFormatter,
            completionHandler: completionHandler
        )
    }
}
