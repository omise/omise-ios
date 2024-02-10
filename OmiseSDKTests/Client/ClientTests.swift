import Foundation
import XCTest
@testable import OmiseSDK

class ClientTests: XCTestCase {
    let publicKey = "pkey_test_58wfnlwoxz1tbkdd993"
    let publicKeyBase64 = "cGtleV90ZXN0XzU4d2ZubHdveHoxdGJrZGQ5OTM="

    var testClient: ClientNew!
    
    override func setUp() {
        super.setUp()
        testClient = ClientNew(publicKey: publicKey)
        
        let testEnvironment = Environment.dev(
            vaultURL: URL(string: "https://vault.staging-omise.co")!,
            apiURL: URL(string: "https://api.staging-omise.co")!
        )
        Configuration.setDefault(Configuration(environment: testEnvironment))
    }

    override func tearDown() {
        testClient = nil
        super.tearDown()
    }

    // TODO:
    // - Mark testClient.userAgent as private
    // - Move this test to testUrlRequest
    func testUserAgent() {
        let sdkVersion = "1.0.0"
        let platform = "12.0.0"
        let device = "iPhone"

        let expectedResult = "OmiseIOS/\(sdkVersion) iOS/\(platform) Apple/\(device)"
        let result = testClient.userAgent(sdkVersion: sdkVersion, platform: platform, device: device)
        XCTAssertEqual(expectedResult, result)
    }

    // TODO:
    // - Mark testClient.httpHeaders as private
    // - Move this test to testUrlRequest
    func testHTTPHeaders() {
        let userAgent = "OmiseIOSSDK/3.0.0 iOS/12.0.0 Apple/iPhone"
        let apiVersion = "2019-05-29"
        let contentType = "application/json; charset=utf8"

        let expectedResult = [
            "Authorization": "Basic \(publicKeyBase64)",
            "User-Agent": userAgent,
            "Content-Type": contentType,
            "Omise-Version": apiVersion
        ]

        let result = testClient.httpHeaders(
            publicKey: publicKey,
            userAgent: userAgent,
            apiVersion: apiVersion,
            contentType: contentType
        )
        XCTAssertEqual(expectedResult, result)
    }

    /*
    func testCapabilityAPI() {
        let expectation = self.expectation(description: "Capability API test")

        testClient?.capability { result in
            print(result)

            do {
                let value = try result.get()
                print(value)
                XCTAssertNotNil(value)
            } catch {
                XCTFail("Failed with \(error)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 15.0, handler: nil)
    }
     */

    /*
    func testObserveChargeStatus() {
        let expectation = self.expectation(description: "Capability API test")

        let tokenID = "test token id"
        let publicKey = "test pkey"
        let client = ClientNew(publicKey: publicKey)
        client.observeChargeStatusUntilChange(tokenID: tokenID) { result in
            do {
                let value = try result.get()
                print(value)
                XCTAssertNotNil(value)
            } catch {
                XCTFail("Failed with \(error)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 15.0, handler: nil)

    }
     */

    func testCreateSourceAPI() {
//        let paymentInfo = PaymentInfo(
//            sourceType: SourceTypeValue.alipay
//        )
//
//        let extendedPaymentInfo = AtomePaymentInfo(
//            phoneNumber: "123"
//        )
//        client.request(.createSource(paymentInfo: paymentInfo))
//        client.request(.createSource(paymentInfo: extendedPaymentInfo))
    }
}

class MockupNetwork: NetworkService {

}
