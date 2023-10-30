//
//  NetceteraThreeDSController.swift
//  OmiseSDK
//
//  Created by Andrei Solovev on 12/9/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation
import ThreeDS_SDK
import OmiseThreeDSSDK

struct AuthResponse: Codable {
    var status: String
    var ares: ARes?

    struct ARes: Codable {
        var threeDSServerTransID: String
        var acsTransID: String
        var acsSignedContent: String?
        var acsUIType: String?
    }

    var isChallenge: Bool {
        return status == "challenge"
    }
}

// swiftlint:disable file_length
public class NetceteraThreeDSController {

    let licenceKey =
    "eyJhbGciOiJSUzI1NiJ9.eyJ2ZXJzaW9uIjoyLCJ2YWxpZC11bnRpbCI6IjIwMjMtMDktMzAiLCJuYW1lIjoiT21pc2UiLCJtb2R1bGUiOiIzRFMifQ.XrTHC8r-7wLXwmBXpWj4Ln3evQoTrGThvuHlowICIWRiB3T7eZbDZUiO1ZR6zWbcIaM9RYi9j99tncK2FmWz9tbTcLJALwjZ3K5MGTEe5BgnSqrSH3Wo_OOFqB_6StWMjK_RkS41yV0RfppOAc2bLAneYUqyYM2ll35KvY3I9eG9_bMirerqWE3zot7B2ptsMvAVmNnLxdUDEJhkja_pPbkJgPXZuTOtFBFY0ZtVDSp8an-bGN5oyOeUrKkfFAAAefS0thmZhE-iBLj1pDkPJuPbOq3sDxYt55UMa7Jl4dzi-pzrxqbF_H43KVBtBmrQRAc2kTDdU24UxfwX1mjNrg"
    // swiftlint:disable:previous line_length

    let directoryServerId = "A000000001"
    let messageVersion = "2.2.0"

    // swiftlint:disable line_length
    let certificate = """
MIIDbzCCAlegAwIBAgIJANp1aztdBEjBMA0GCSqGSIb3DQEBCwUAME4xCzAJBgNVBAMMAmNhMQ4wDAYDVQQKDAVPbWlzZTEQMA4GA1UEBwwHQmFuZ2tvazEQMA4GA1UECAwHQmFuZ2tvazELMAkGA1UEBhMCVEgwHhcNMTkwMzEzMDkxNzM4WhcNMzkwMzA4MDkxNzM4WjBOMQswCQYDVQQDDAJjYTEOMAwGA1UECgwFT21pc2UxEDAOBgNVBAcMB0Jhbmdrb2sxEDAOBgNVBAgMB0Jhbmdrb2sxCzAJBgNVBAYTAlRIMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAziN94YnR2/cihsFVa/CRpu3YfZMy6uQxwG3wc2nYOYFHAeB0mRsk8GpNKmjDdldpF1pIq6ALXznijXBI7qF0bEc0GlGNwmt1rl5rLUtlxVtWV+hzXDyICIXa1rsvxMEQEjalF+pZpLMPdsuIFJTvK8YE7j8uywahRpcsR7xVwtSG/GvT8mA2o5UmdmFa1UoUVNsA8FDsSqpTWPAcw+wEe2YO0Ct0A91txeo8x2GBW6qBWtHf0PmY6Aq9ZqOW3akoYxgoiOq+FwQX+OeQuYvyKvbKelU6WlDZO7jifebZG2wEm5+SoNEBBgyYAUGllWHeu2CQW6DAg4GnBIUZx8FE5wIDAQABo1AwTjAdBgNVHQ4EFgQUg9xOjam9pOesWFIieUY21dV2PGYwHwYDVR0jBBgwFoAUg9xOjam9pOesWFIieUY21dV2PGYwDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEAiaR2IUmLKDEn3ixHQJX2CzqVvtqdO0DrxIcnWp8Cmd2DIKjlX3Jw/v5ADKaAiO+7TIFpHfxZCB/oDFdji4YEXK6KUa+5pfOawuL3HXpQ48cLougmJjtwEAOdEZnCLNpYfMeqct7tNQxcm/qme1ewHOXZ9zz7+XfS5N4ExvdTV676/kcnAB1+Juc2Mo+t3kpLvTCpYUmWCANISRR8vTXX2pvqoiJq8lFujoqE41BbPVSVqV8pFZmrp4NKbZP6OmYbxjtVrTeMb1r2/J3jdXGg6LsNE0ouOU/XbEEA+Xpyrs2sUwUZMmiLN49Wz1YYZ2Xkh78gzaRiKCXfJYplDm/mDA==
"""

    private static let sharedController = NetceteraThreeDSController()

    var challengeParameters: ChallengeParameters?
    var receiver: OmiseChallengeStatusReceiver?
    var transaction: Transaction?

    public static func processAuthorizedURL(
        _ authorizeUrl: URL,
        threeDSRequestorAppURL: String? = nil,
        uiCustomization: ThreeDSUICustomization? = nil,
        in viewController: UIViewController
    ) {
        if let uiCustomization = uiCustomization {
            Self.uiCustomization = uiCustomization
        }

        let netceteraThreeDSController = Self.sharedController
        do {
            let transaction = try netceteraThreeDSController.newTransaction()
            let authParams = try transaction.getAuthenticationRequestParameters()

            if let deviceInfo = FimeProxy.deviceInformation(sdkAppId: authParams.getSDKAppID(), sdkVersion: "1.0") {
                try netceteraThreeDSController.sendAuthenticationRequest(
                    deviceInfo: deviceInfo,
                    transaction: transaction,
                    authorizeUrl: authorizeUrl) { response in
                        if let response = response, response.isChallenge == true {
                            DispatchQueue.main.async {
                                do {
                                    try Self.sharedController.presentChallenge(
                                        authResponse: response,
                                        threeDSRequestorAppURL: threeDSRequestorAppURL,
                                        transaction: transaction,
                                        from: viewController
                                    )
                                } catch {
                                    print(error)
                                }
                            }
                        }
                }
            }
        } catch {
            print(error)
        }
    }

    private func newScheme() -> Scheme {
        let scheme = Scheme(name: "Mastercard")
        scheme.ids = [directoryServerId]
        scheme.logoImageName = "3ds_logo"

        scheme.encryptionKeyValue = certificate
        scheme.rootCertificateValue = certificate
        return scheme
    }

    private static var uiCustomization: ThreeDSUICustomization?

    private lazy var threeDS2Service: ThreeDS2ServiceSDK = {
        let threeDS2Service = ThreeDS2ServiceSDK()
        
        let configBuilder = ConfigurationBuilder()
        do {
            try configBuilder.add(self.newScheme())
            try configBuilder.license(key: self.licenceKey)
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
            print("-")
        }

        return threeDS2Service
    }()

    private func newTransaction(uiCustomization uiCustom: ThreeDSUICustomization? = nil) throws -> Transaction {

        let transaction = try threeDS2Service.createTransaction(
            directoryServerId: directoryServerId,
            messageVersion: "2.1.0"
        )

        return transaction
    }
    // ToDo: Process exception errors
    //        } catch ThreeDS2Error.SDKNotInitialized(let message, _) {
    //        } catch ThreeDS2Error.InvalidInput(let message, _) {
    //        } catch ThreeDS2Error.SDKAlreadyInitialized(let message, _) {

    typealias ErrorHandler = (String) -> Void
    func verifyWarnings(errorHandler: @escaping ErrorHandler) {
        var sdkWarnings: [ThreeDS_SDK.Warning] = []
        do {
            sdkWarnings = try threeDS2Service.getWarnings()
        } catch let error as NSError {
            errorHandler(error.localizedDescription)
        } catch {
            errorHandler("ThreeDS SDK couldn't calculate warnings")
        }
        if !sdkWarnings.isEmpty {
            var message = ""
            for warning in sdkWarnings {
                message += warning.getMessage()
                message += "\n"
            }
            errorHandler(message)
        }
    }

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
              "device_info": \(deviceInfo),
              "device_type": "iOS"
            }
"""
        let bodyData = body.trimmingCharacters(in: .whitespacesAndNewlines).data(using: .utf8)

        var request = URLRequest(url: authorizeUrl)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = bodyData

        let task = URLSession.shared.dataTask(with: request) {(data, _, error) in
            guard let data = data else { return }

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

    func presentChallenge(authResponse: AuthResponse, threeDSRequestorAppURL: String?, transaction: Transaction, from viewController: UIViewController) throws {
        guard let aRes = authResponse.ares else { return }

        print("presentChallenge: \(aRes)")
        let receiver = OmiseChallengeStatusReceiver()
        receiver.onComplete = {
            print("here")
            // ...
        }

        let threeDSServerTransactionID = aRes.threeDSServerTransID
        let acsTransactionID = aRes.acsTransID
        let acsRefNumber = "3DS_LOA_SDK_NEAG_020200_00528"
        let acsSignedContent = aRes.acsSignedContent

        let challengeParameters = ChallengeParameters(
            threeDSServerTransactionID: threeDSServerTransactionID,
            acsTransactionID: acsTransactionID,
            acsRefNumber: acsRefNumber,
            acsSignedContent: acsSignedContent)
        
        if let threeDSRequestorAppURL = threeDSRequestorAppURL {
            challengeParameters.setThreeDSRequestorAppURL(threeDSRequestorAppURL: threeDSRequestorAppURL)
        }

        self.challengeParameters = challengeParameters
        self.receiver = receiver
        self.transaction = transaction

//        DispatchQueue.main.async {
            do {
                try transaction.doChallenge(
                    challengeParameters: challengeParameters,
                    challengeStatusReceiver: receiver,
                    timeOut: 5,
                    inViewController: viewController
                )
            } catch {
                print("doChallenge error: \(error)")
                print("-")
            }
//        }
    }
}

class OmiseChallengeStatusReceiver: ChallengeStatusReceiver {
    var onComplete: (() -> Void)?

    func completed(completionEvent: ThreeDS_SDK.CompletionEvent) {
        onComplete?()
    }

    func cancelled() {
        print("cancelled")
    }

    func timedout() {
        print("timedout")
    }

    func protocolError(protocolErrorEvent: ThreeDS_SDK.ProtocolErrorEvent) {
        print("protocolError")
    }

    func runtimeError(runtimeErrorEvent: ThreeDS_SDK.RuntimeErrorEvent) {
        print("runtimeError, \(runtimeErrorEvent.getErrorCode()): \(runtimeErrorEvent.getErrorMessage())")
        print("-")
    }
}
