//
//  NetceteraThreeDSController.swift
//  OmiseSDK
//
//  Created by Andrei Solovev on 12/9/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation
import ThreeDS_SDK

class NetceteraThreeDSController {
    var licenceKey: String {
        // swiftlint:disable:next line_length
        "eyJhbGciOiJSUzI1NiJ9.eyJ2ZXJzaW9uIjoyLCJ2YWxpZC11bnRpbCI6IjIwMjMtMDktMzAiLCJuYW1lIjoiT21pc2UiLCJtb2R1bGUiOiIzRFMifQ.XrTHC8r-7wLXwmBXpWj4Ln3evQoTrGThvuHlowICIWRiB3T7eZbDZUiO1ZR6zWbcIaM9RYi9j99tncK2FmWz9tbTcLJALwjZ3K5MGTEe5BgnSqrSH3Wo_OOFqB_6StWMjK_RkS41yV0RfppOAc2bLAneYUqyYM2ll35KvY3I9eG9_bMirerqWE3zot7B2ptsMvAVmNnLxdUDEJhkja_pPbkJgPXZuTOtFBFY0ZtVDSp8an-bGN5oyOeUrKkfFAAAefS0thmZhE-iBLj1pDkPJuPbOq3sDxYt55UMa7Jl4dzi-pzrxqbF_H43KVBtBmrQRAc2kTDdU24UxfwX1mjNrg"
    }

    func config3DS() throws {
        do {
            let threeDS2Service: ThreeDS2Service = ThreeDS2ServiceSDK()
            let configBuilder = ConfigurationBuilder()
            try configBuilder.license(key: licenceKey)
            let configParameters = configBuilder.configParameters()
            try threeDS2Service.initialize(configParameters,
                                           locale: nil,
                                           uiCustomization: nil)

            let sdkWarnings = try threeDS2Service.getWarnings()

            let directoryServerId = "01"
            let transaction = try threeDS2Service.createTransaction(
                directoryServerId: directoryServerId,
                messageVersion: "2.1.0"
            )
            let authenticationParameters = try transaction.getAuthenticationRequestParameters()

        } catch {
            print(error)
            //        } catch ThreeDS2Error.SDKNotInitialized(let message, _) {
            // ...
            //        } catch ThreeDS2Error.InvalidInput(let message, _) {
            // ...
            //        } catch ThreeDS2Error.SDKAlreadyInitialized(let message, _) {
            // ...
        }
    }
}
