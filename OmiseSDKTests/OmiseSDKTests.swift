import Foundation
import XCTest
@testable import OmiseSDK

class OmiseSDKTests: XCTestCase {
    var sut: OmiseSDK!
    var mockVC: UIViewController!
    var mockDelegate: MockChoosePaymentMethodDelegate!
    
    override func setUp() {
        super.setUp()
        sut = OmiseSDK(publicKey: "pkey_my_key")
        mockVC = UIViewController()
        mockDelegate = MockChoosePaymentMethodDelegate()
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
    
    func test_presentCreditCardPayment() {
        sut.presentCreditCardPayment(from: mockVC,
                                     delegate: mockDelegate)
        
        let navController = sut.presentedViewController as? UINavigationController
        let coordinator = navController?.delegate as? ChoosePaymentCoordinator
        
        XCTAssertEqual(coordinator?.amount, 0)
        XCTAssertNil(coordinator?.applePayInfo)
        XCTAssertEqual(coordinator?.currency, "")
        XCTAssertEqual(coordinator?.handleErrors, true)
    }
    
    func test_Configuration_init_storesURLs() throws {
        let vault = try XCTUnwrap(URL(string: "https://vault.example.com"))
        let api = try XCTUnwrap(URL(string: "https://api.example.com"))
        
        let config = Configuration(vaultURL: vault, apiURL: api)
        
        XCTAssertEqual(config.vaultURL, vault)
        XCTAssertEqual(config.apiURL, api)
    }
}
