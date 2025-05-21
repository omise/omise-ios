import XCTest
@testable import OmiseSDK
import ThreeDS_SDK

class NetceteraThreeDSControllerTests: XCTestCase {
    var sut: NetceteraThreeDSController!
    
    override func setUp() {
        super.setUp()
        sut = NetceteraThreeDSController()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_newService_neverCrashes_andReturnsAService() throws {
        let config = NetceteraConfig(
            id: "ABC",
            deviceInfoEncryptionAlg: "ABC-DEFC-000",
            deviceInfoEncryptionEnc: "ABCDEFG-HIJKL",
            deviceInfoEncryptionCertPem: """
        -----BEGIN CERTIFICATE-----
        BEVQQKDAVPbWlzZTEQMA4GA1UEBw
        mYbxjtVrTeMb1r2/J3jdXGg6LsNE0ouOU/XbEEA+Xpyrs
        2Xkh78gzaRiKCXfJYplDm/mBB==
        -----END CERTIFICATE-----
        """,
            directoryServerId: "001",
            key: "qmF3DYxVQAXjH0000MOCK0KEY000cXQ1uRSWT4Yrmjcd2mJkTGQ==",
            messageVersion: "0.0.0"
        )
        
        let service = sut.newService(config: config)
        XCTAssertNotNil(service)
    }
    
    func testThreeDSRequestorAppURLTransaction() {
        let transactionId = "1234-5678-9012-ABCD"
        let sdkTransId = "2222-5678-9012-ABCD"
        
        let aRes = AuthResponse.ARes(
            threeDSServerTransID: transactionId,
            acsTransID: "123",
            acsSignedContent: nil,
            acsUIType: nil,
            sdkTransID: sdkTransId
        )
        
        let netceteraController = NetceteraThreeDSController()
        
        let tests = [
            "": nil,
            
            "someApp://":
                "someApp://?transID=\(sdkTransId)",
            
            "someApp://3DSChallenge":
                "someApp://3DSChallenge?transID=\(sdkTransId)",
            
            "someApp://3ds/challenge?source=omiseSDK":
                "someApp://3ds/challenge?source=omiseSDK&transID=\(sdkTransId)"
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
