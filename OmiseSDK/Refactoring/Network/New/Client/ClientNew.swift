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
        let localHandler = { (result: (Result<CapabilityNew, Error>)) in
            if let capability = try? result.get() {
                OmiseSDK.shared.setCurrentCountry(countryCode: capability.countryCode)
            }
            completionHandler(result)
        }
        apiRequest(api: OmiseAPI.capability, completionHandler: localHandler)
    }

    // TODO: Add implementation
    // TODO: Add unit tests
    public func observeChargeStatusChange(tokenID: String, _ completionHandler: @escaping (Result<ChargeStatus, Error>) -> Void) {
    }

    // TODO: Sync naming with Android
    // TODO: Add Implementation
    // TODO: Add unit tests
    public func createToken(cardInfo: String) {

    }

    // TODO: Sync naming with Android
    // TODO: Add Implementation
    // TODO: Add unit tests
    public func createSource(paymentInfo: String) {

    }
}

private extension ClientNew {
    // TODO: Add unit tests
    func token(tokenID: String, _ completionHandler: @escaping (Result<ChargeStatus, Error>) -> Void) {
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
