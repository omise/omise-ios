import Foundation
import XCTest
@testable import OmiseSDK

class OmiseSDKTests: XCTestCase {
    var sut: OmiseSDK!
    
    override func setUp() {
        super.setUp()
        sut = OmiseSDK(publicKey: "pkey_my_key")
        OmiseSDK.shared = sut
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    func testCountry() {
        let expectedCountry = Country(name: "Thailand", code: "TH")
        let capability = Capability(countryCode: "TH", paymentMethods: [], banks: Set<String>(), tokenizationMethods: Set<String>())
        if let client = OmiseSDK.shared.client as? Client {
            client.setLatestLoadedCapability(capability)
            XCTAssertEqual(expectedCountry, OmiseSDK.shared.country)
        } else {
            XCTFail("Client has a wrong type")
        }
    }
    
    func test_setupApplePay() {
        let info = ApplePayInfo(merchantIdentifier: "merchant_id", requestBillingAddress: true)
        sut.setupApplePay(for: info.merchantIdentifier, requiredBillingAddress: info.requestBillingAddress)
        
        XCTAssertNotNil(sut.applePayInfo)
        XCTAssertEqual(sut.applePayInfo, info)
    }
}
