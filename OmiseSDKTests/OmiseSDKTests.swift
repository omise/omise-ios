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
    
    func test_BuildPaymentArgument() {
        let publicKey = "test_public_key_123"
        let amount: Int64 = 10000
        let currency = "USD"
        let paymentMethods = ["credit_card", "promptpay"]
        let tokenizationMethods = ["card"]
        let merchantId = "merchant.com.example.app"
        let requestBillingAddress = true
        
        let result = sut.buildPaymentArguments(
            publicKey: publicKey,
            amount: amount,
            currency: currency,
            paymentMethods: paymentMethods,
            tokenizationMethods: tokenizationMethods,
            merchantId: merchantId,
            requestBillingAddress: requestBillingAddress
        )
        
        // Assert
        XCTAssertEqual(result["pkey"] as? String, publicKey)
        XCTAssertEqual(result["amount"] as? Int64, amount)
        XCTAssertEqual(result["currency"] as? String, currency)
        XCTAssertEqual(result["selectedPaymentMethods"] as? [String], paymentMethods)
        XCTAssertEqual(result["selectedTokenizationMethods"] as? [String], tokenizationMethods)
        XCTAssertEqual(result["applePayMerchantId"] as? String, merchantId)
        XCTAssertEqual(result["applePayCardBrands"] as? [String], ["visa", "amex", "discover", "masterCard", "JCB", "chinaUnionPay"])
        
        let billingFields = result["applePayRequiredBillingContactFields"] as? [String]
        XCTAssertNotNil(billingFields)
        XCTAssertEqual(billingFields, ["emailAddress", "name", "phoneNumber", "postalAddress"])
    }
}
