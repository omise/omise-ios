import Foundation
import XCTest
@testable import OmiseSDK

class OmiseSDKTests: XCTestCase {
    var sut: OmiseSDK!
    var mockVC: UIViewController!
    var mockDelegate: MockChoosePaymentMethodDelegate!
    var mockFlutterEngineManager: MockFlutterEngineManager!
    var dummyVC: UIViewController!
    
    override func setUp() {
        super.setUp()
        sut = OmiseSDK(publicKey: "pkey_my_key")
        mockVC = UIViewController()
        mockDelegate = MockChoosePaymentMethodDelegate()
        mockFlutterEngineManager = MockFlutterEngineManager()
        dummyVC = UIViewController()
        sut.flutterEngineManager = mockFlutterEngineManager
        OmiseSDK.shared = sut
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        mockVC = nil
        mockDelegate = nil
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
    
    func test_versionIsNotEmpty() {
        XCTAssertFalse(sut.version.isEmpty)
    }
    
    func test_versionMatchesSemanticVersionFormat() throws {
        let version = sut.version
        
        // semantic versioning: major.minor.patch
        let semverRegex = #"^\d+\.\d+\.\d+$"#
        
        let regex = try NSRegularExpression(pattern: semverRegex, options: [])
        let range = NSRange(location: 0, length: version.utf16.count)
        let match = regex.firstMatch(in: version, options: [], range: range)
        XCTAssertNotNil(match, "Version \(version) should match semantic versioning (major.minor.patch)")
    }
    
    func test_Configuration_init_storesURLs() throws {
        let vault = try XCTUnwrap(URL(string: "https://vault.example.com"))
        let api = try XCTUnwrap(URL(string: "https://api.example.com"))
        
        let config = Configuration(vaultURL: vault, apiURL: api)
        
        XCTAssertEqual(config.vaultURL, vault)
        XCTAssertEqual(config.apiURL, api)
    }
    
    func testPresentChoosePaymentMethod_buildsArgsAndForwardsCall() throws {
        // Act
        sut.presentChoosePaymentMethod(
            from: dummyVC,
            animated: false,
            amount: 5000,
            currency: "USD",
            allowedPaymentMethods: [.atome, .applePay],
            skipCapabilityValidation: false,
            isCardPaymentAllowed: true,
            handleErrors: true,
            delegate: mockDelegate
        )
        
        // Assert detach
        XCTAssertTrue(mockFlutterEngineManager.didDetach)
        
        // Assert present call
        XCTAssertEqual(mockFlutterEngineManager.presentCalls.count, 1)
        let call = try XCTUnwrap(mockFlutterEngineManager.presentCalls.first)
        XCTAssertEqual(call.method, .selectPaymentMethod)
        XCTAssertEqual(call.viewController, dummyVC)
        XCTAssertIdentical(call.delegate, mockDelegate)
        
        let args = call.arguments
        XCTAssertEqual(args["pkey"] as? String, "pkey_my_key")
        XCTAssertEqual(args["amount"] as? Int64, 5000)
        XCTAssertEqual(args["currency"] as? String, "USD")
        
        let paymentMethods = args["selectedPaymentMethods"] as? [String] ?? []
        XCTAssertEqual(
            Set(paymentMethods),
            Set([SourceType.atome.rawValue, SourceType.applePay.rawValue])
        )
        
        let tokenMethods = args["selectedTokenizationMethods"] as? [String] ?? []
        XCTAssertEqual(tokenMethods, [SourceType.applePay.rawValue])
    }
    
    func testPresentCreditCardPayment_forwardsCorrectArgs() throws {
        // Act
        sut.presentCreditCardPayment(
            from: dummyVC,
            animated: true,
            countryCode: "TH",
            handleErrors: true,
            delegate: mockDelegate
        )
        
        // Assert detach
        XCTAssertTrue(mockFlutterEngineManager.didDetach)
        
        // Assert present call
        XCTAssertEqual(mockFlutterEngineManager.presentCalls.count, 1)
        let call = try XCTUnwrap(mockFlutterEngineManager.presentCalls.first)
        XCTAssertEqual(call.method, .openCardPage)
        XCTAssertEqual(call.viewController, dummyVC)
        XCTAssertIdentical(call.delegate, mockDelegate)
        
        let args = call.arguments
        XCTAssertEqual(args["pkey"] as? String, "pkey_my_key")
        XCTAssertEqual(args.count, 1)
    }
    
    func testUpdatePublicKey() {
        XCTAssertEqual(sut.publicKey, "pkey_my_key")
        
        // Act
        sut.updatePublicKey(key: "new_key")
        
        // Assert
        XCTAssertEqual(sut.publicKey, "new_key")
    }
}
