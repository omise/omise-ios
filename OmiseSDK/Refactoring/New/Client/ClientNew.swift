import Foundation
import os

// TODO: (REFACTOR) NETWORK SERVICE
// TODO: (COMMENTS) ADD DESCRIPTIONS TO PUBLIC PROPERTIES AND DATA TYPES

// TODO: (UNIT TESTS) DEFINE TEST DATA COLLECTION
// TODO: (UNIT TESTS) ADD REMAINING UNIT TESTS
// TODO: (UNIT TESTS) CLEAN UNIT TESTS




// TODO: Rename to Client
public class ClientNew {
    public typealias RequestResultClosure<T: Decodable, E: Error> = (Result<T, E>) -> Void

    private enum Const {
        static let observingAttemptsCount = 10
        static let observingTimeInterval = 3
    }

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
    public func capability(_ completion: @escaping RequestResultClosure<CapabilityNew, Error>) {
        apiRequest(api: OmiseAPI.capability) { (result: Result<CapabilityNew, Error>) in
            if let capability = try? result.get() {
                OmiseSDK.shared.setCurrentCountry(countryCode: capability.countryCode)
            }
            completion(result)
        }
    }

    // TODO: Add unit tests
    public func observeChargeStatusUntilChange(tokenID: String, _ completion: @escaping RequestResultClosure<TokenNew.ChargeStatus, Error>) {
        observeChargeStatusUntilChange(
            tokenID: tokenID,
            timeInterval: Self.Const.observingTimeInterval,
            attemp: 0,
            maxAttempt: Self.Const.observingAttemptsCount,
            completion
        )
    }

    // TODO: Add unit tests
    public func createToken(cardPayment: CardPayment, _ completion: @escaping RequestResultClosure<TokenNew, Error>) {
        apiRequest(api: OmiseAPI.createToken(cardPayment: cardPayment), completion: completion)
    }
}

extension ClientNew {
    // TODO: Add unit tests
    // TODO: Validate that marchant can't call this directly on Android
    func createSource(sourcePayment: SourcePayment, _ completion: @escaping RequestResultClosure<TokenNew, Error>
    ) {
        apiRequest(api: OmiseAPI.createSource(sourcePayment: sourcePayment), completion: completion)

        // TODO: Add Implementation after PaymentInformation refactoring
    }
}

private extension ClientNew {
    func apiRequest<T: Decodable>(api: APIProtocol, completion: @escaping RequestResultClosure<T, Error>) {
        let urlRequest = urlRequest(publicKey: publicKey, api: api)
        network.send(
            urlRequest: urlRequest,
            dateFormatter: api.dateFormatter,
            completion: completion
        )
    }

    // TODO: Add unit tests
    func observeChargeStatusUntilChange(
        tokenID: String,
        timeInterval: Int,
        attemp: Int,
        maxAttempt: Int,
        _ completion: @escaping RequestResultClosure<TokenNew.ChargeStatus, Error>
    ) {
        guard maxAttempt > attemp else {
            return
        }
        token(tokenID: tokenID) { [weak self] (result: (Result<TokenNew, Error>)) in
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

    // TODO: Add unit tests
    func token(tokenID: String, _ completion: @escaping RequestResultClosure<TokenNew, Error>) {
        apiRequest(api: OmiseAPI.token(tokenID: tokenID), completion: completion)
    }
}
