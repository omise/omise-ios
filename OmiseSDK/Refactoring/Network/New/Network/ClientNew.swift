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
}

// MARK: API Requests
extension ClientNew {

    // TODO: Add unit tests
    public func capability(_ completionHandler: @escaping (Result<CapabilityNew, Error>) -> Void) {
        apiRequest(api: OmiseAPI.capability, completionHandler: completionHandler)
    }

    // TODO: Add unit tests
    // TODO: Refactor ChargeStatus
    public func chargeStatus(tokenID: String, _ completionHandler: @escaping (Result<ChargeStatus, Error>) -> Void) {
        apiRequest(api: OmiseAPI.chargeStatusByToken(tokenID: tokenID), completionHandler: completionHandler)
    }

// func chargeStatusByToken(tokenID: String)
// func createToken(cardInfo: String)
// func createSource(paymentInfo: String)
}

// MARK: API Request
private extension ClientNew {
    func apiRequest<T: Codable>(api: APIProtocol, completionHandler: @escaping (Result<T, Error>) -> Void) {
        let urlRequest = urlRequest(publicKey: publicKey, api: api)
        network.get(
            urlRequest: urlRequest,
            dateFormatter: api.dateFormatter,
            completionHandler: completionHandler
        )
    }
}
