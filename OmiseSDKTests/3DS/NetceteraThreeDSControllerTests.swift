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
                threeDSRequestorAppURL: url
            )
            XCTAssertEqual(params.getThreeDSRequestorAppURL(), result)
        }
    }
    
    func test_processAuthenticationResponse() {
        let onComplete: ((Result<Void, Error>) -> Void) = { _ in /* Non-optional default empty implementation */ }
        let success = AuthResponse(serverStatus: "success", ares: nil)
        XCTAssertTrue(NetceteraThreeDSController.processAuthenticationResponse(success, onComplete: onComplete))
        
        let failed = AuthResponse(serverStatus: "failed", ares: nil)
        XCTAssertTrue(NetceteraThreeDSController.processAuthenticationResponse(failed, onComplete: onComplete))
        
        let unknown = AuthResponse(serverStatus: "something_unknow", ares: nil)
        XCTAssertTrue(NetceteraThreeDSController.processAuthenticationResponse(unknown, onComplete: onComplete))
        
        let challenge = AuthResponse(serverStatus: "challenge", ares: nil)
        XCTAssertFalse(NetceteraThreeDSController.processAuthenticationResponse(challenge, onComplete: onComplete))
    }
    
}
