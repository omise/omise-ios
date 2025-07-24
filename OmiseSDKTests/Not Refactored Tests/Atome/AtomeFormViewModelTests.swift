import XCTest
import OmiseUnitTestKit
@testable import OmiseSDK

// swiftlint:disable:next type_body_length
class AtomePaymentFormViewModelTests: XCTestCase {
    typealias ViewModel = AtomePaymentFormViewModelMockup
    
    let validCases = TestCaseValueGenerator.validCases(AtomePaymentFormViewContext.generateMockup)
    let invalidCases = TestCaseValueGenerator.invalidCases(AtomePaymentFormViewContext.generateMockup)
    let mostInvalidCases = TestCaseValueGenerator.mostInvalidCases(AtomePaymentFormViewContext.generateMockup)
    let allCountriesCodes: [String] = [ // swiftlint:disable:next line_length
        "AF", "AX", "AL", "DZ", "AS", "AD", "AO", "AO", "AI", "AQ", "AG", "AR", "AM", "AW", "AU", "AT", "AZ", "BS", "BH", "BD", "BB", "BY", "BE", "BZ", "BJ", "BM", "BT", "BO", "BQ", "BA", "BW", "BV", "BR", "IO", "BN", "BG", "BF", "BI", "CV", "KH", "CM", "CA", "KY", "CF", "TD", "CL", "CN", "CX", "CC", "CO", "KM", "CG", "CD", "CK", "CR", "CI", "HR", "CU", "CW", "CY", "CZ", "DK", "DJ", "DM", "DO", "EC", "EG", "SV", "GQ", "ER", "EE", "SZ", "ET", "FK", "FO", "FJ", "FI", "FR", "GF", "PF", "TF", "GA", "GM", "GE", "DE", "GH", "GI", "GR", "GL", "GD", "GP", "GU", "GT", "GG", "GN", "GW", "GY", "HT", "HM", "VA", "HN", "HK", "HU", "IS", "IN", "ID", "IQ", "IE", "IM", "IL", "IT", "JM", "JP", "JE", "JO", "KZ", "KE", "KI", "KR", "KW", "KG", "LA", "LV", "LB", "LS", "LR", "LY", "LI", "LT", "LU", "MO", "MG", "MW", "MY", "MV", "ML", "MT", "MH", "MQ", "MR", "MU", "YT", "MX", "FM", "MD", "MC", "MN", "ME", "MS", "MA", "MZ", "MM", "NA", "NR", "NP", "NL", "NC", "NZ", "NI", "NE", "NG", "NU", "NF", "MK", "MP", "NO", "OM", "PK", "PW", "PS", "PA", "PG", "PY", "PE", "PH", "PN", "PL", "PT", "PR", "QA", "RE", "RO", "RU", "RW", "BL", "SH", "KN", "LC", "MF", "PM", "VC", "WS", "SM", "ST", "SA", "SN", "RS", "SC", "SL", "SG", "SX", "SK", "SI", "SB", "SO", "ZA", "GS", "SS", "ES", "LK", "SD", "SR", "SJ", "SE", "CH", "SY", "TW", "TJ", "TZ", "TH", "TL", "TG", "TK", "TO", "TT", "TN", "TR", "TM", "TC", "TV", "UG", "UA", "AE", "GB", "UM", "US", "UY", "UZ", "VU", "VE", "VN", "VI", "VG", "WF", "EH", "YE", "ZM", "ZW"
    ]
    let contextDict: [AtomePaymentFormViewContext.Field: String] = [
        .name: "Test User",
        .email: "foo@bar.com",
        .phoneNumber: "+66123456789",
        .street1: "10 Main Street",
        .street2: "Suite 200",
        .city: "SampleCity",
        .state: "AB",
        .country: "TH",
        .postalCode: "10110",
        .billingStreet1: "99 Market Blvd",
        .billingStreet2: "Floor 5",
        .billingCity: "Billtown",
        .billingState: "CD",
        .billingCountry: "US",
        .billingPostalCode: "90210"
    ]
    var delegateMock: MockSelectSourcePaymentDelegate!
    var sut: AtomePaymentFormViewModel!
    
    override func setUp() {
        super.setUp()
        
        delegateMock = MockSelectSourcePaymentDelegate()
        let initialCountry = Country(name: "Thailand", code: "TH")
        sut = AtomePaymentFormViewModel(amount: 50_000, currentCountry: initialCountry, delegate: delegateMock)
    }
    
    override func tearDown() {
        sut = nil
        delegateMock = nil
        super.tearDown()
    }
    
    func testInitialProperties_areCorrectlyAssigned() {
        XCTAssertFalse(sut.submitButtonTitle.isEmpty)
        XCTAssertFalse(sut.headerText.isEmpty)
        XCTAssertEqual(sut.logoName, "Atome_Big")
        
        XCTAssertEqual(sut.fieldForShippingAddressHeader,
                       AtomePaymentFormViewContext.Field.street1)
        XCTAssertEqual(sut.fieldForBillingAddressHeader,
                       AtomePaymentFormViewContext.Field.billingStreet1)
        
        XCTAssertEqual(sut.countries.map { $0.code }, allCountriesCodes)
        XCTAssertEqual(sut.countryListViewModel.countries.map { $0.code }, allCountriesCodes)
        XCTAssertNil(sut.shippingCountry)
        XCTAssertNil(sut.billingCountry)
    }
    
    func testCountries_andSelectedCountry_andOnSelectCountry_mechanics() {
        XCTAssertEqual(sut.selectedCountry?.code, "TH")
        
        var captured: Country?
        sut.onSelectCountry = { c in captured = c }
        
        let newCountry = Country(name: "United States", code: "US")
        sut.selectedCountry = newCountry
        XCTAssertEqual(captured?.code, "US")
    }
    
    func testBillingAddressFields_areInExpectedOrder() {
        let billing = sut.billingAddressFields
        XCTAssertEqual(billing, [
            .billingStreet1,
            .billingStreet2,
            .billingCity,
            .billingState,
            .billingCountry,
            .billingPostalCode
        ])
    }
    
    func testAllFields_containsShippingPlusBilling() {
        let all = sut.fields
        
        XCTAssertEqual(all.count, 15)
        XCTAssertTrue(all.starts(with: [
            .name,
            .email,
            .phoneNumber,
            .street1,
            .street2,
            .city,
            .state,
            .country,
            .postalCode
        ]))
        XCTAssertTrue(all.suffix(6).elementsEqual(sut.billingAddressFields))
    }
    
    func testTitle_forOptionalShippingField_appendsOptionalSuffix() {
        let rawTitle: String = sut.title(for: .street2) ?? ""
        XCTAssertTrue(rawTitle.contains("Street 2"))
        XCTAssertTrue(rawTitle.contains("optional"))
    }
    
    func testTitle_forRequiredShippingField_doesNotAppendOptional() {
        let plain: String = sut.title(for: .street1) ?? ""
        XCTAssertEqual(plain, "Street")
    }
    
    func testTitle_forOptionalBillingField_doesNotAppendAnySuffix() {
        let t = sut.title(for: .billingStreet2)
        XCTAssertEqual(t, "Street 2")
    }
    
    func testError_forFieldWithNoValidatorRegex_andEmptyText_returnsErrorKey() {
        let e = sut.error(for: .city, validate: "")
        XCTAssertEqual(e, "Shipping city is required")
    }
    
    func testError_forFieldWithNoValidatorRegex_andNonEmptyText_returnsNil() {
        let e = sut.error(for: .city, validate: "NonEmpty")
        XCTAssertNil(e)
    }
    
    func testError_NilForName_andNonEmptyText_returnsNil() {
        let e = sut.error(for: .name, validate: "!!@NonEmpty")
        XCTAssertNil(e)
    }
    
    func testError_forOptionalFieldWithEmptyText_returnsNil() {
        XCTAssertNil(sut.error(for: .street2, validate: ""))
    }
    
    func testError_forFieldWithValidatorRegex_andMatchingText_returnsNil() {
        let e = sut.error(for: .email, validate: "johndoe@example.co")
        XCTAssertNil(e)
    }
    
    func testError_forFieldWithValidatorRegex_andInvalidText_returnsRegexErrorKey() {
        let e = sut.error(for: .email, validate: "notAnEmail")
        XCTAssertEqual(e, "Email is invalid")
    }
    
    func testError_forFieldWithValidatorRegex_andEmptyText_returnsErrorKey() {
        let e = sut.error(for: .phoneNumber, validate: "")
        XCTAssertEqual(e, "Please enter valid phone number")
    }
    
    func test_onSubmitButtonPressed_withoutDelegate_callsCompletionImmediately() {
        let vmNoDelegate = AtomePaymentFormViewModel(amount: 12_345, currentCountry: nil, delegate: nil)
        let emptyContext = AtomePaymentFormViewContext(fields: [:])
        
        var completionCalled = false
        vmNoDelegate.onSubmitButtonPressed(emptyContext) {
            completionCalled = true
        }
        
        XCTAssertTrue(completionCalled)
    }
    
    func test_onSubmitButtonPressed() throws {
        let fullContext = AtomePaymentFormViewContext(fields: contextDict)
        var completionCalled = false
        sut.onSubmitButtonPressed(fullContext) {
            completionCalled = true
        }
        XCTAssertTrue(completionCalled)
        XCTAssertTrue(delegateMock.didSelectCalled)
        
        guard let payment = delegateMock.selectedPayment,
              case let .atome(payload) = payment else {
            XCTFail("Cannot get Atome Payment Payload.")
            return
        }
        
        XCTAssertEqual(payload.phoneNumber, "+66123456789")
        
        XCTAssertEqual(payload.shipping.countryCode, "TH")
        XCTAssertEqual(payload.shipping.street1, "10 Main Street")
        XCTAssertEqual(payload.shipping.street2, "Suite 200")
        XCTAssertEqual(payload.shipping.city, "SampleCity")
        XCTAssertEqual(payload.shipping.state, "AB")
        XCTAssertEqual(payload.shipping.postalCode, "10110")
        
        XCTAssertEqual(payload.billing?.countryCode, "US")
        XCTAssertEqual(payload.billing?.street1, "99 Market Blvd")
        XCTAssertEqual(payload.billing?.street2, "Floor 5")
        XCTAssertEqual(payload.billing?.city, "Billtown")
        XCTAssertEqual(payload.billing?.state, "CD")
        XCTAssertEqual(payload.billing?.postalCode, "90210")
        
        XCTAssertEqual(payload.items.count, 1)
        let item = payload.items[0]
        XCTAssertEqual(item.amount, 50_000)
        XCTAssertEqual(item.sku, "3427842")
        XCTAssertEqual(item.category, "Shoes")
        XCTAssertEqual(item.name, "Prada shoes")
        XCTAssertEqual(item.quantity, 1)
        XCTAssertEqual(item.itemUri, "omise.co/product/shoes")
        XCTAssertEqual(item.imageUri, "omise.co/product/shoes/image")
        XCTAssertEqual(item.brand, "Gucci")
    }
    
    func test_allField_keyboardTypeMapping() {
        XCTAssertEqual(AtomePaymentFormViewContext.Field.email.keyboardType, .emailAddress)
        XCTAssertEqual(AtomePaymentFormViewContext.Field.phoneNumber.keyboardType, .phonePad)
        
        let numericFields: [AtomePaymentFormViewContext.Field] = [
            .postalCode,
            .street1,
            .street2,
            .billingPostalCode,
            .billingStreet1,
            .billingStreet2
        ]
        for field in numericFields {
            XCTAssertEqual(
                field.keyboardType,
                .numbersAndPunctuation,
                "Expected \(field) to map to .numbersAndPunctuation"
            )
        }
        
        let asciiFields = AtomePaymentFormViewContext.Field.allCases.filter {
            !numericFields.contains($0)
            && $0 != .email
            && $0 != .phoneNumber
        }
        for field in asciiFields {
            XCTAssertEqual(
                field.keyboardType,
                .asciiCapable,
                "Expected \(field) to default to .asciiCapable"
            )
        }
    }
    
    func test_allField_capitalizationMapping() {
        let wordsFields: [AtomePaymentFormViewContext.Field] = [
            .name,
            .city,
            .state,
            .street1,
            .street2,
            .billingCity,
            .billingState,
            .billingStreet1,
            .billingStreet2
        ]
        for field in wordsFields {
            XCTAssertEqual(
                field.capitalization,
                .words,
                "Expected \(field) to map to .words"
            )
        }
        
        let allCharsFields: [AtomePaymentFormViewContext.Field] = [
            .country,
            .billingCountry
        ]
        for field in allCharsFields {
            XCTAssertEqual(
                field.capitalization,
                .allCharacters,
                "Expected \(field) to map to .allCharacters"
            )
        }
        
        let noneFields = AtomePaymentFormViewContext.Field.allCases
            .filter { !wordsFields.contains($0) && !allCharsFields.contains($0) }
        for field in noneFields {
            XCTAssertEqual(
                field.capitalization,
                .none,
                "Expected \(field) to default to .none"
            )
        }
    }
    
    func test_allField_contentTypeMapping() {
        XCTAssertEqual(AtomePaymentFormViewContext.Field.name.contentType, .name)
        XCTAssertEqual(AtomePaymentFormViewContext.Field.phoneNumber.contentType, .telephoneNumber)
        XCTAssertEqual(AtomePaymentFormViewContext.Field.email.contentType, .emailAddress)
        XCTAssertEqual(AtomePaymentFormViewContext.Field.country.contentType, .countryName)
        XCTAssertEqual(AtomePaymentFormViewContext.Field.billingCountry.contentType, .countryName)
        XCTAssertEqual(AtomePaymentFormViewContext.Field.city.contentType, .addressCity)
        XCTAssertEqual(AtomePaymentFormViewContext.Field.billingCity.contentType, .addressCity)
        XCTAssertEqual(AtomePaymentFormViewContext.Field.postalCode.contentType, .postalCode)
        XCTAssertEqual(AtomePaymentFormViewContext.Field.billingPostalCode.contentType, .postalCode)
        XCTAssertEqual(AtomePaymentFormViewContext.Field.state.contentType, .addressState)
        XCTAssertEqual(AtomePaymentFormViewContext.Field.billingState.contentType, .addressState)
        XCTAssertEqual(AtomePaymentFormViewContext.Field.street1.contentType, .streetAddressLine1)
        XCTAssertEqual(AtomePaymentFormViewContext.Field.billingStreet1.contentType, .streetAddressLine1)
        XCTAssertEqual(AtomePaymentFormViewContext.Field.street2.contentType, .streetAddressLine2)
        XCTAssertEqual(AtomePaymentFormViewContext.Field.billingStreet2.contentType, .streetAddressLine2)
    }
}
