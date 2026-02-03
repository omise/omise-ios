import Foundation
import XCTest
@testable import OmiseSDK

class OmiseSDKTests: XCTestCase {
    var sut: OmiseSDK!
    var mockVC: UIViewController!
    var mockDelegate: MockChoosePaymentMethodDelegate!
    var mockPasskeyHandler: MockPasskeyAuthenticationHandler!
    var mockAuthorizingDelegate: MockAuthorizingPaymentDelegate!
    
    override func setUp() {
        super.setUp()
        mockPasskeyHandler = MockPasskeyAuthenticationHandler()
        mockAuthorizingDelegate = MockAuthorizingPaymentDelegate()
        sut = OmiseSDK(
            publicKey: "pkey_my_key",
            passkeyAuthenticationHandler: mockPasskeyHandler
        )
        mockVC = UIViewController()
        mockDelegate = MockChoosePaymentMethodDelegate()
        OmiseSDK.shared = sut
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        mockVC = nil
        mockDelegate = nil
        mockPasskeyHandler = nil
        mockAuthorizingDelegate = nil
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
    
    func test_presentChoosePaymentMethod() {
        sut.setupApplePay(for: "merchant_id", requiredBillingAddress: true)
        sut.presentChoosePaymentMethod(from: mockVC,
                                       amount: 1000,
                                       currency: "THB",
                                       zeroInterestInstallments: true,
                                       delegate: mockDelegate)
        
        let navController = sut.presentedViewController as? UINavigationController
        let coordinator = navController?.delegate as? ChoosePaymentCoordinator
        
        XCTAssertEqual(coordinator?.amount, 1000)
        XCTAssertEqual(coordinator?.applePayInfo?.merchantIdentifier, "merchant_id")
        XCTAssertEqual(coordinator?.applePayInfo?.requestBillingAddress, true)
        XCTAssertEqual(coordinator?.currency, "THB")
        XCTAssertEqual(coordinator?.handleErrors, true)
        XCTAssertEqual(coordinator?.zeroInterestInstallments, true)
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
    
    // MARK: - Passkey Authentication Tests
    func test_handleURLCallback_withPasskeyHandler_returnsTrue() throws {
        // Given
        let callbackURL = try XCTUnwrap(URL(string: "myapp://callback?result=success"))
        mockPasskeyHandler.shouldReturnTrueForCallback = true
        
        // When
        let result = sut.handleURLCallback(callbackURL)
        
        // Then
        XCTAssertTrue(result)
        XCTAssertEqual(mockPasskeyHandler.handlePasskeyCallbackCallCount, 1)
    }
    
    func test_handleURLCallback_withoutPasskeyHandler_fallsBackToDefault() throws {
        // Given
        let callbackURL = try XCTUnwrap(URL(string: "myapp://callback?result=success"))
        mockPasskeyHandler.shouldReturnTrueForCallback = false
        
        // When
        let result = sut.handleURLCallback(callbackURL)
        
        // Then
        XCTAssertEqual(mockPasskeyHandler.handlePasskeyCallbackCallCount, 1)
        // The result should be false since passkey handler returned false
        // and there are no expected URLs set up for the default behavior
        XCTAssertFalse(result)
    }
    
    func test_presentAuthorizingPayment_withSignatureParam_callsPasskeyHandler() throws {
        // Given
        let passkeyURL = try XCTUnwrap(URL(string: "https://sample.domain/?signature=aBcdXyzlibc"))
        let expectedReturnURLs = ["myapp://callback"]
        mockPasskeyHandler.shouldReturnTrueForShouldHandle = true
        
        // When
        sut.presentAuthorizingPayment(
            from: mockVC,
            authorizeURL: passkeyURL,
            expectedReturnURLStrings: expectedReturnURLs,
            threeDSRequestorAppURLString: "myapp://",
            delegate: mockAuthorizingDelegate
        )
        
        // Then
        XCTAssertEqual(mockPasskeyHandler.shouldHanlePasskeyCallCount, 1)
        XCTAssertEqual(mockPasskeyHandler.presentPasskeyAuthenticationCallCount, 1)
        XCTAssertEqual(mockPasskeyHandler.lastPresentedURL, passkeyURL)
    }
    
    func test_presentAuthorizingPayment_withoutSignatureParam_doesNotCallPasskeyHandler() throws {
        // Given
        let regularURL = try XCTUnwrap(URL(string: "https://regular.domain/authorize?t=token&sigv=1"))
        let expectedReturnURLs = ["myapp://callback"]
        mockPasskeyHandler.shouldReturnTrueForShouldHandle = false
        
        // When
        sut.presentAuthorizingPayment(
            from: mockVC,
            authorizeURL: regularURL,
            expectedReturnURLStrings: expectedReturnURLs,
            threeDSRequestorAppURLString: "myapp://",
            delegate: mockAuthorizingDelegate
        )
        
        // Then
        XCTAssertEqual(mockPasskeyHandler.shouldHanlePasskeyCallCount, 1)
        XCTAssertEqual(mockPasskeyHandler.presentPasskeyAuthenticationCallCount, 0)
    }
    
    func test_presentAuthorizingPayment_withSignatureAndExtraParams_callsPasskeyHandler() throws {
        // Given
        let passkeyURL = try XCTUnwrap(URL(string: "https://sample.domain/?t=token&signature=aBcdXyzlibc&sigv=1&extra=value"))
        let expectedReturnURLs = ["myapp://callback"]
        mockPasskeyHandler.shouldReturnTrueForShouldHandle = true
        
        // When
        sut.presentAuthorizingPayment(
            from: mockVC,
            authorizeURL: passkeyURL,
            expectedReturnURLStrings: expectedReturnURLs,
            threeDSRequestorAppURLString: "myapp://",
            delegate: mockAuthorizingDelegate
        )
        
        // Then
        XCTAssertEqual(mockPasskeyHandler.shouldHanlePasskeyCallCount, 1)
        XCTAssertEqual(mockPasskeyHandler.presentPasskeyAuthenticationCallCount, 1)
        XCTAssertEqual(mockPasskeyHandler.lastPresentedURL, passkeyURL)
    }
}
