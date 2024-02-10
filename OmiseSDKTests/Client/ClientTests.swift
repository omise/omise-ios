import Foundation
import XCTest
@testable import OmiseSDK

class ClientTests: XCTestCase {
    let publicKey = "pkey_test_58wfnlwoxz1tbkdd993"
    let publicKeyBase64 = "cGtleV90ZXN0XzU4d2ZubHdveHoxdGJrZGQ5OTM="
    let requestTimeout: TimeInterval = 15.0

    var testClient: ClientNew!
    
    override func setUp() {
        super.setUp()
        testClient = ClientNew(publicKey: publicKey)
        
        // swiftlint:disable force_unwrapping
        let testEnvironment = Environment.dev(
            vaultURL: URL(string: "https://vault.staging-omise.co")!,
            apiURL: URL(string: "https://api.staging-omise.co")!
        )
        // swiftlint:enable force_unwrapping
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
     let expectation = self.expectation(description: "API: Capability")

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

    func testCreateTokenAPI() {
        let expectation = self.expectation(description: "API: Create Token")

        // TODO: Move to test data collection
        let card = PaymentInformationNew.Card(
            name: "Test User",
            number: "4242424242424242",
            expirationMonth: 4,
            expirationYear: 2024,
            securityCode: "123",
            countryCode: "th",
            city: nil,
            state: nil,
            street1: nil,
            street2: nil,
            postalCode: nil,
            phoneNumber: nil
        )

        let publicKey = "..."
        let client = ClientNew(publicKey: publicKey)

        client.createToken(card: card) { result in
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

        waitForExpectations(timeout: requestTimeout, handler: nil)
    }

    /*
     func testObserveChargeStatus() {
     let expectation = self.expectation(description: "API: Observe Charge Status")

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
