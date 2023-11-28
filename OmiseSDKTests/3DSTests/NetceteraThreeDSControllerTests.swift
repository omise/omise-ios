import XCTest
@testable import OmiseSDK
import ThreeDS_SDK

class NetceteraThreeDSControllerTests: XCTestCase {

    func testThreeDSRequestorAppURLTransaction() {
        let transactionId = "1234-5678-9012-ABCD"

        let aRes = AuthResponse.ARes(
            threeDSServerTransID: transactionId,
            acsTransID: "123",
            acsSignedContent: nil,
            acsUIType: nil
        )

        let netceteraController = NetceteraThreeDSController()

        let tests = [
            "": nil,

            "someApp://":
                "someApp://?transID=\(transactionId)",

            "someApp://3DSChallenge":
                "someApp://3DSChallenge?transID=\(transactionId)",

            "someApp://3ds/challenge?source=omiseSDK":
                "someApp://3ds/challenge?source=omiseSDK&transID=\(transactionId)"
        ]

        for (url, result) in tests {
            let params = netceteraController.prepareChallengeParameters(
                aRes: aRes,
                acsRefNumber: "123",
                threeDSRequestorAppURL: url
            )
            XCTAssertEqual(params.getThreeDSRequestorAppURL(), result)
        }
    }
}
