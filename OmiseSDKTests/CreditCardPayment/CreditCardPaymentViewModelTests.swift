import XCTest
@testable import OmiseSDK

// MARK: - Tests
class CreditCardPaymentFormViewModelTests: XCTestCase {
    var sut: CreditCardPaymentFormViewModel!
    var mockDelegate: MockCreditCardDelegate!
    
    override func setUp() {
        super.setUp()
        mockDelegate = MockCreditCardDelegate()
        let country = Country(code: "TH")
        sut = CreditCardPaymentFormViewModel(
            country: country,
            paymentOption: .card,
            collect3DSData: .all,
            delegate: mockDelegate
        )
    }
    
    override func tearDown() {
        sut = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    func test_viewDidLoad_triggersInitialCountryClosure() {
        var closureCountry: Country?
        sut.input.set { closureCountry = $0 }
        
        sut.input.viewDidLoad()
        XCTAssertEqual(closureCountry, Country(code: "TH"))
    }
    
    func test_setCountryClosure_andSelectingCountryUpdates() {
        var closureCountry: Country?
        sut.input.set { closureCountry = $0 }
        let newCountry = Country(code: "JP")
        
        sut.selectedCountry = newCountry
        
        XCTAssertEqual(closureCountry, newCountry)
    }
    
    func test_didCancelForm_callsDelegate() {
        sut.input.didCancelForm()
        XCTAssertTrue(mockDelegate.didCancelFormCalled)
    }
    
    func test_startPayment_callsDelegate_andLoadingClosure() {
        let card = CreditCardPayment(
            pan: "4111111111111111",
            name: "Test User",
            expiryMonth: 12,
            expiryYear: 2030,
            cvv: "123",
            country: "TH",
            address: "1 Infinite Loop",
            state: "Bangkok",
            city: "Bangkok",
            zipcode: "95014",
            email: "example@example.com",
            phoneNumber: "66934344388"
        )
        var loadingStates: [Bool] = []
        sut.input.set { loadingStates.append($0) }
        
        sut.input.startPayment(for: card)
        
        XCTAssertTrue(mockDelegate.didSelectCardPaymentCalled)
        XCTAssertEqual(loadingStates, [true, false])
        
        // Verify card payload values
        XCTAssertEqual(mockDelegate.receivedCard?.name, "Test User")
        XCTAssertEqual(mockDelegate.receivedCard?.number, "4111111111111111")
        XCTAssertEqual(mockDelegate.receivedCard?.expirationMonth, 12)
        XCTAssertEqual(mockDelegate.receivedCard?.expirationYear, 2030)
        XCTAssertEqual(mockDelegate.receivedCard?.securityCode, "123")
        XCTAssertEqual(mockDelegate.receivedCard?.countryCode, "TH")
        XCTAssertEqual(mockDelegate.receivedCard?.street1, "1 Infinite Loop")
        XCTAssertEqual(mockDelegate.receivedCard?.state, "Bangkok")
        XCTAssertEqual(mockDelegate.receivedCard?.city, "Bangkok")
        XCTAssertEqual(mockDelegate.receivedCard?.postalCode, "95014")
    }
    
    func test_getBrandImage_returnsCorrectNames() {
        XCTAssertEqual(sut.input.getBrandImage(for: .visa), "Visa")
        XCTAssertEqual(sut.input.getBrandImage(for: .masterCard), "Mastercard")
        XCTAssertEqual(sut.input.getBrandImage(for: .jcb), "JCB")
        XCTAssertEqual(sut.input.getBrandImage(for: .unionPay), "UnionPay")
        XCTAssertEqual(sut.input.getBrandImage(for: .amex), "AMEX")
        XCTAssertEqual(sut.input.getBrandImage(for: .diners), "Diners")
        XCTAssertEqual(sut.input.getBrandImage(for: .discover), "Discover")
        XCTAssertNil(sut.input.getBrandImage(for: nil))
    }
    
    func test_outputErrorStrings_areNotEmpty() {
        XCTAssertFalse(sut.output.numberError.isEmpty)
        XCTAssertFalse(sut.output.nameError.isEmpty)
        XCTAssertFalse(sut.output.expiryError.isEmpty)
        XCTAssertFalse(sut.output.cvvError.isEmpty)
        XCTAssertFalse(sut.output.emailError.isEmpty)
        XCTAssertFalse(sut.output.phoneError.isEmpty)
    }
    
    func test_shouldShowAddressFields_reflectsCountryAVS() {
        sut.selectedCountry = Country(code: "JP")  // assume isAVS=false
        XCTAssertFalse(sut.output.shouldAddressFields)
        
        let avsCountry = Country(code: "US")
        sut.selectedCountry = avsCountry
        XCTAssertTrue(sut.output.shouldAddressFields)
    }

    func test_allCountries() {
        let allCodes      = Set(Country.all.map { $0.code })
        let sutCodes      = Set(sut.countries.map { $0.code })
        
        XCTAssertEqual(sutCodes, allCodes)
    }

    func test_filterCountries_updatesFilteredListAndReset() {
        sut.filterCountries(with: "thai")
        XCTAssertTrue(sut.filteredCountries.contains { $0.code == "TH" })

        sut.filterCountries(with: "jp")
        XCTAssertTrue(sut.filteredCountries.contains { $0.code == "JP" })

        sut.filterCountries(with: "")
        XCTAssertEqual(sut.filteredCountries.count, sut.countries.count)
    }

    func test_updateSelectedCountry_usesFilteredResultsAndGuardsBounds() {
        sut.filterCountries(with: "us")

        let outOfRangeIndex = sut.filteredCountries.count
        sut.updateSelectedCountry(at: outOfRangeIndex)
        XCTAssertEqual(sut.selectedCountry?.code, "TH")

        if let index = sut.filteredCountries.firstIndex(where: { $0.code == "US" }) {
            sut.updateSelectedCountry(at: index)
            XCTAssertEqual(sut.selectedCountry?.code, "US")
        } else {
            XCTFail("Expected US to be part of filtered list")
        }
    }

    func test_shouldShowEmailAndPhoneFields_follow3DSRequirements() {
        XCTAssertTrue(sut.output.shouldshowEmailField)
        XCTAssertTrue(sut.output.shouldShowPhoneField)

        let phoneOnly = CreditCardPaymentFormViewModel(
            country: Country(code: "SG"),
            paymentOption: .card,
            collect3DSData: .phoneNumber,
            delegate: mockDelegate
        )

        XCTAssertFalse(phoneOnly.output.shouldshowEmailField)
        XCTAssertTrue(phoneOnly.output.shouldShowPhoneField)

        let emailOnly = CreditCardPaymentFormViewModel(
            country: Country(code: "SG"),
            paymentOption: .card,
            collect3DSData: .email,
            delegate: mockDelegate
        )

        XCTAssertTrue(emailOnly.output.shouldshowEmailField)
        XCTAssertFalse(emailOnly.output.shouldShowPhoneField)
    }
}
