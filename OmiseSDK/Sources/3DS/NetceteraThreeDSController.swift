import Foundation
import ThreeDS_SDK
import CommonCrypto

struct AuthResponse: Codable {
    var serverStatus: String
    var ares: ARes?

    private enum CodingKeys: String, CodingKey {
        case serverStatus = "status"
        case ares
    }

    enum Status {
        case challenge
        case failed
        case success
        case unknown
    }

    struct ARes: Codable {
        var threeDSServerTransID: String
        var acsTransID: String
        var acsSignedContent: String?
        var acsUIType: String?
        var acsReferenceNumber: String?
    }

    var status: Status {
        switch serverStatus {
        case "success": return .success
        case "challenge": return .challenge
        case "failed": return .failed
        default: return .unknown
        }
    }
}

protocol NetceteraThreeDSControllerProtocol: AnyObject {
    typealias NetceteraThreeDSControllerResult = Result<Void, Error>
    func appOpen3DSDeeplinkURL(_ url: URL) -> Bool
    func processAuthorizedURL(
        _ authorizeUrl: URL,
        threeDSRequestorAppURL: String?,
        uiCustomization: ThreeDSUICustomization?,
        in viewController: UIViewController,
        onComplete: @escaping (NetceteraThreeDSControllerResult) -> Void
    )
}

class NetceteraThreeDSController {

    enum Errors: Error {
        case configInvalid
        case apiKeyInvalid
        case cancelled
        case timedout
        case presentChallenge(error: Error)
        case protocolError(event: ThreeDS_SDK.ProtocolErrorEvent?)
        case runtimeError(event: ThreeDS_SDK.RuntimeErrorEvent?)
        case incomplete(event: ThreeDS_SDK.CompletionEvent?)

        case authResInvalid
        case authResStatusFailed
        case authResStatusUnknown(_ status: String)
    }

    static var sharedController: NetceteraThreeDSControllerProtocol = NetceteraThreeDSController()
    private static var uiCustomization: ThreeDSUICustomization?

    private var network = NetworkService()
    private var challengeParameters: ChallengeParameters?
    private var receiver: OmiseChallengeStatusReceiver?
    private var transaction: Transaction?

    private func newScheme(config: NetceteraConfig) -> Scheme? {
        let formattedCert = config.deviceInfoEncryptionCertPem.pemCertificate

        let scheme = Scheme(name: config.id)
        scheme.ids = [config.directoryServerId]
        scheme.encryptionKeyValue = formattedCert
        scheme.rootCertificateValues = [formattedCert]
        return scheme
    }

func apiKey(config: NetceteraConfig) throws -> String {
        let decryptionKey = config.directoryServerId.sha512.subdata(in: 0..<32)

        guard let ciphertext = Data(base64Encoded: config.key) else {
            throw Errors.configInvalid
        }

        let iv = ciphertext.subdata(in: 0..<16)
        let ciphertextWithoutIV = ciphertext.subdata(in: 16..<ciphertext.count)

        let encrypted = try cryptData(
            ciphertextWithoutIV,
            operation: CCOperation(kCCDecrypt),
            mode: CCMode(kCCModeCTR),
            algorithm: CCAlgorithm(kCCAlgorithmAES),
            padding: CCPadding(ccNoPadding),
            keyLength: kCCKeySizeAES256,
            iv: iv,
            key: decryptionKey
        )

        if let apiKey = String(data: encrypted, encoding: .utf8) {
            return apiKey
        } else {
            throw Errors.apiKeyInvalid
        }
    }

    func newService(config: NetceteraConfig) -> ThreeDS2ServiceSDK {
        let threeDS2Service = ThreeDS2ServiceSDK()

        let configBuilder = ConfigurationBuilder()
        do {
            if let scheme = self.newScheme(config: config) {
                try configBuilder.add(scheme)
            } else {
                print("Scheme wasn't created")
            }
            let apiKey = try apiKey(config: config)
            try configBuilder.api(key: apiKey)
            try configBuilder.log(to: .info)
            let configParameters = configBuilder.configParameters()

            var netceteraUICustomization: UiCustomization?
            if let uiCustomization = Self.uiCustomization {
                netceteraUICustomization = try UiCustomization(uiCustomization)
            }

            try threeDS2Service.initialize(configParameters,
                                           locale: nil,
                                           uiCustomization: netceteraUICustomization)

        } catch {
            print(error)
        }

        return threeDS2Service
    }
}

extension NetceteraThreeDSController: NetceteraThreeDSControllerProtocol {
    public func appOpen3DSDeeplinkURL(_ url: URL) -> Bool {
        ThreeDSSDKAppDelegate.shared.appOpened(url: url)
    }

    // swiftlint:disable:next function_body_length
    func processAuthorizedURL(
        _ authorizeUrl: URL,
        threeDSRequestorAppURL: String?,
        uiCustomization: ThreeDSUICustomization?,
        in viewController: UIViewController,
        onComplete: @escaping ((Result<Void, Error>) -> Void)
    ) {
        if let uiCustomization = uiCustomization {
            Self.uiCustomization = uiCustomization
        }

        // swiftlint:disable:next closure_body_length
        netceteraConfig(authUrl: authorizeUrl) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                onComplete(.failure(error))
            case .success(let config):
                do {
                    let threeDS2Service = self.newService(config: config)
                    let transaction = try threeDS2Service.createTransaction(
                        directoryServerId: config.directoryServerId,
                        messageVersion: config.messageVersion
                    )
                    
                    let deviceInfo = try transaction.getAuthenticationRequestParameters().getDeviceData()

                    try self.sendAuthenticationRequest(
                        deviceInfo: deviceInfo,
                        transaction: transaction,
                        authorizeUrl: authorizeUrl) { response in
                            guard let response = response else {
                                onComplete(.failure(NetceteraThreeDSController.Errors.authResInvalid))
                                return
                            }

                            switch response.status {
                            case .success:
                                onComplete(.success(()))
                                return
                            case .failed:
                                onComplete(.failure(NetceteraThreeDSController.Errors.authResStatusFailed))
                                return
                            case .unknown:
                                onComplete(.failure(NetceteraThreeDSController.Errors.authResStatusUnknown(response.serverStatus)))
                                return
                            case .challenge:
                                break
                            }

                            DispatchQueue.main.async {
                                do {
                                    try self.presentChallenge(
                                        authResponse: response,
                                        threeDSRequestorAppURL: threeDSRequestorAppURL,
                                        transaction: transaction,
                                        from: viewController,
                                        onComplete: onComplete
                                    )
                                } catch {
                                    onComplete(.failure(error))
                                }
                            }
                    }
                } catch {
                    onComplete(.failure(error))
                }
            }
        }
    }

    func prepareChallengeParameters(
        aRes: AuthResponse.ARes,
        threeDSRequestorAppURL: String?
    ) -> ChallengeParameters {
        let serverTransactionID = aRes.threeDSServerTransID
        let acsTransactionID = aRes.acsTransID
        let acsSignedContent = aRes.acsSignedContent
        let acsRefNumber = aRes.acsReferenceNumber

        let challengeParameters = ChallengeParameters(
            threeDSServerTransactionID: serverTransactionID,
            acsTransactionID: acsTransactionID,
            acsRefNumber: acsRefNumber,
            acsSignedContent: acsSignedContent)

        if let appUrl = updateAppURLString(threeDSRequestorAppURL, transactionID: serverTransactionID) {
            challengeParameters.setThreeDSRequestorAppURL(threeDSRequestorAppURL: appUrl)
        }

        return challengeParameters
    }
}

private extension NetceteraThreeDSController {
    func sendAuthenticationRequest(deviceInfo: String, transaction: Transaction, authorizeUrl: URL, onAuthResponse: @escaping (AuthResponse?) -> Void ) throws {
        let authParams = try transaction.getAuthenticationRequestParameters()
        let body =
"""
            {
              "areq": {
                "sdkAppID": "\(authParams.getSDKAppID())",
                "sdkEphemPubKey": \(authParams.getSDKEphemeralPublicKey()),
                "sdkMaxTimeout": 5,
                "sdkTransID": "\(authParams.getSDKTransactionId())"
              },
              "encrypted_device_info": "\(deviceInfo)",
              "device_type": "iOS"
            }
"""
        let bodyData = body.trimmingCharacters(in: .whitespacesAndNewlines).data(using: .utf8)

        var request = URLRequest(url: authorizeUrl)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = bodyData

        let task = URLSession.shared.dataTask(with: request) {(data, _, error) in
            guard let data = data else {
                onAuthResponse(nil)
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(AuthResponse.self, from: data)
                print(response)
                onAuthResponse(response)

            } catch {
                onAuthResponse(nil)
                print(error)
            }

        }

        task.resume()
    }

    func presentChallenge(
        authResponse: AuthResponse,
        threeDSRequestorAppURL: String?,
        transaction: Transaction,
        from viewController: UIViewController,
        onComplete: @escaping ((Result<Void, Error>) -> Void)
    ) throws {
        guard let aRes = authResponse.ares else { return }

        let receiver = OmiseChallengeStatusReceiver()
        receiver.onComplete = onComplete

        let challengeParameters = prepareChallengeParameters(
            aRes: aRes,
            threeDSRequestorAppURL: threeDSRequestorAppURL
        )

        self.receiver = receiver
        self.transaction = transaction
        self.challengeParameters = challengeParameters

        do {
            try transaction.doChallenge(
                challengeParameters: challengeParameters,
                challengeStatusReceiver: receiver,
                timeOut: 5,
                inViewController: viewController
            )
        } catch {
            onComplete(.failure(NetceteraThreeDSController.Errors.presentChallenge(error: error)))
        }
    }

    func updateAppURLString(_ urlString: String?, transactionID: String) -> String? {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return nil
        }

        return url.appendQueryItem(name: "transID", value: transactionID)?.absoluteString
    }
}

class OmiseChallengeStatusReceiver: ChallengeStatusReceiver {
    var onComplete: ((Result<Void, Error>) -> Void)?

    func completed(completionEvent: ThreeDS_SDK.CompletionEvent) {
        if completionEvent.getTransactionStatus() == "Y" {
            onComplete?(.success(()))
        } else {
            onComplete?(.failure(NetceteraThreeDSController.Errors.incomplete(event: completionEvent)))
        }
    }

    func cancelled() {
        onComplete?(.failure(NetceteraThreeDSController.Errors.cancelled))
    }

    func timedout() {
        onComplete?(.failure(NetceteraThreeDSController.Errors.timedout))
    }

    func protocolError(protocolErrorEvent: ThreeDS_SDK.ProtocolErrorEvent) {
        onComplete?(.failure(NetceteraThreeDSController.Errors.protocolError(event: protocolErrorEvent)))
    }

    func runtimeError(runtimeErrorEvent: ThreeDS_SDK.RuntimeErrorEvent) {
        onComplete?(.failure(NetceteraThreeDSController.Errors.runtimeError(event: runtimeErrorEvent)))
    }
}

extension NetceteraThreeDSController {
    func netceteraConfig(authUrl: URL, completion: @escaping (Result<NetceteraConfig, Error>) -> Void) {
        let api = OmiseAPI.netceteraConfig(baseUrl: authUrl.removeLastPathComponent)
        var urlRequest = URLRequest(url: api.url)
        urlRequest.httpMethod = api.method.rawValue
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaders.contentType.rawValue)
        
        network.send(
            urlRequest: urlRequest,
            dateFormatter: api.dateFormatter,
            completion: completion
        )

    }
}
