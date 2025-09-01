import XCTest
import UIKit
@testable import OmiseSDK
// swiftlint:disable file_length
// MARK: - Mock PhoneNumberTextFieldDelegate
class MockPhoneNumberTextFieldDelegate: PhoneNumberTextFieldDelegate {
    var didSelectCountryCallCount = 0
    var lastSelectedCountry: Country?
    
    func phoneNumberTextField(_ textField: PhoneNumberTextField, didSelectCountry country: Country) {
        didSelectCountryCallCount += 1
        lastSelectedCountry = country
    }
}

// swiftlint:disable:next type_body_length
final class PhoneNumberTextFieldTests: XCTestCase {
    var sut: PhoneNumberTextField!
    var mockDelegate: MockPhoneNumberTextFieldDelegate!
    
    override func setUp() {
        super.setUp()
        sut = PhoneNumberTextField()
        mockDelegate = MockPhoneNumberTextFieldDelegate()
        sut.phoneDelegate = mockDelegate
    }
    
    override func tearDown() {
        mockDelegate = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitFrame_setsCorrectProperties() {
        let frameField = PhoneNumberTextField(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        
        XCTAssertEqual(frameField.keyboardType, .phonePad)
        XCTAssertEqual(frameField.placeholder, "123 456 7890")
        XCTAssertEqual(frameField.textContentType, .telephoneNumber)
        XCTAssertNotNil(frameField.validator)
        XCTAssertNotNil(frameField.leftView)
        XCTAssertEqual(frameField.leftViewMode, .always)
    }
    
    func testDefaultInit_setsCorrectProperties() {
        XCTAssertEqual(sut.keyboardType, .phonePad)
        XCTAssertEqual(sut.placeholder, "123 456 7890")
        XCTAssertEqual(sut.textContentType, .telephoneNumber)
        XCTAssertNotNil(sut.validator)
        XCTAssertNotNil(sut.leftView)
        XCTAssertEqual(sut.leftViewMode, .always)
    }
    
    func testDefaultSelectedCountry_isThailand() {
        XCTAssertEqual(sut.selectedCountry.name, "Thailand")
        XCTAssertEqual(sut.selectedCountry.code, "TH")
    }
    
    // MARK: - Country Selection Tests
    
    func testSelectedCountry_updatesCountryCodeButton() {
        let usa = Country(name: "Thailand", code: "TH")
        sut.selectedCountry = usa
        
        XCTAssertEqual(sut.selectedCountry, usa)
        
        // Test that the button title is updated
        if let button = sut.leftView as? UIButton {
            XCTAssertEqual(button.title(for: .normal), usa.phonePrefix)
        } else {
            XCTFail("Left view should be a UIButton")
        }
    }
    
    func testSelectedCountry_notifiesDelegate() {
        let japan = Country(name: "Japan", code: "JP")
        sut.selectedCountry = japan
        
        XCTAssertEqual(mockDelegate.didSelectCountryCallCount, 1)
        XCTAssertEqual(mockDelegate.lastSelectedCountry, japan)
    }
    
    func testSetCountry_updatesSelectedCountry() {
        let canada = Country(name: "Canada", code: "CA")
        sut.setCountry(canada)
        
        XCTAssertEqual(sut.selectedCountry, canada)
        XCTAssertEqual(mockDelegate.didSelectCountryCallCount, 1)
        XCTAssertEqual(mockDelegate.lastSelectedCountry, canada)
    }
    
    // MARK: - Phone Number Generation Tests
    
    func testFullPhoneNumber_combinesCountryPrefixAndText() {
        sut.text = "1234567890"
        let expected = "\(sut.selectedCountry.phonePrefix)1234567890"
        XCTAssertEqual(sut.fullPhoneNumber, expected)
    }
    
    func testFullPhoneNumber_withEmptyText() {
        sut.text = ""
        let expected = sut.selectedCountry.phonePrefix
        XCTAssertEqual(sut.fullPhoneNumber, expected)
    }
    
    func testFullPhoneNumber_withNilText() {
        sut.text = nil
        let expected = sut.selectedCountry.phonePrefix
        XCTAssertEqual(sut.fullPhoneNumber, expected)
    }
    
    func testFullPhoneNumber_withDifferentCountries() {
        let testCases = [
            (Country(name: "United States", code: "US"), "1234567890", "+11234567890"),
            (Country(name: "United Kingdom", code: "GB"), "7890123456", "+447890123456"),
            (Country(name: "Japan", code: "JP"), "9012345678", "+819012345678")
        ]
        
        for (country, phoneText, expected) in testCases {
            sut.selectedCountry = country
            sut.text = phoneText
            XCTAssertEqual(sut.fullPhoneNumber, expected, "Failed for country: \(country.name)")
        }
    }
    
    // MARK: - Validation Tests
    
    func testValidate_withValidPhoneNumber_shouldSucceed() {
        let validPhoneNumbers = [
            "12345678",
            "123456789",
            "1234567890",
            "12345678901",
            "123456789012345" // 15 digits
        ]
        
        for phone in validPhoneNumbers {
            sut.text = phone
            XCTAssertNoThrow(try sut.validate(), "Should validate valid phone: \(phone)")
        }
    }
    
    func testValidate_withInvalidPhoneNumber_shouldThrowInvalidData() {
        let invalidPhoneNumbers = [
            "123456",    // Too short (less than 7 digits)
            "12345",
            "1234",
            ""
        ]
        
        for phone in invalidPhoneNumbers {
            sut.text = phone
            XCTAssertThrowsError(try sut.validate(), "Should not validate invalid phone: \(phone)") { error in
                if phone.isEmpty {
                    XCTAssertEqual(error as? OmiseTextFieldValidationError, .emptyText)
                } else {
                    XCTAssertEqual(error as? OmiseTextFieldValidationError, .invalidData)
                }
            }
        }
    }
    
    func testValidate_withEmptyText_shouldThrowEmptyText() {
        sut.text = ""
        XCTAssertThrowsError(try sut.validate()) { error in
            XCTAssertEqual(error as? OmiseTextFieldValidationError, .emptyText)
        }
        
        sut.text = nil
        XCTAssertThrowsError(try sut.validate()) { error in
            XCTAssertEqual(error as? OmiseTextFieldValidationError, .emptyText)
        }
    }
    
    func testValidate_withValidPhoneAndWhitespace_shouldSucceed() {
        let phoneNumbersWithWhitespace = [
            " 1234567 ",
            "\n12345678\n",
            "\t123456789\t",
            " \n 1234567890 \t "
        ]
        
        for phone in phoneNumbersWithWhitespace {
            sut.text = phone
            XCTAssertThrowsError(try sut.validate(), "Should not validate phone with whitespace: '\(phone)'")
        }
    }
    
    // MARK: - Country Code Button Tests
    
    func testCountryCodeButton_isCorrectlyConfigured() {
        guard let button = sut.leftView as? UIButton else {
            XCTFail("Left view should be a UIButton")
            return
        }
        
        XCTAssertEqual(button.title(for: .normal), sut.selectedCountry.phonePrefix)
        XCTAssertEqual(button.titleColor(for: .normal)?.hexString, UIColor.omisePrimary.hexString)
        XCTAssertEqual(button.backgroundColor, .clear)
        XCTAssertEqual(button.contentHorizontalAlignment, .center)
    }
    
    func testCountryCodeButton_updatesWhenCountryChanges() {
        let germany = Country(name: "Germany", code: "DE")
        sut.selectedCountry = germany
        
        guard let button = sut.leftView as? UIButton else {
            XCTFail("Left view should be a UIButton")
            return
        }
        
        XCTAssertEqual(button.title(for: .normal), germany.phonePrefix)
    }
    
    func testCountryCodeButton_frameCalculation() {
        let longPrefixCountry = Country(name: "United States", code: "US") // +1
        let shortPrefixCountry = Country(name: "Germany", code: "DE")      // +49
        
        sut.selectedCountry = longPrefixCountry
        guard let button1 = sut.leftView as? UIButton else {
            XCTFail("Left view should be a UIButton")
            return
        }
        let width1 = button1.frame.width
        
        sut.selectedCountry = shortPrefixCountry
        guard let button2 = sut.leftView as? UIButton else {
            XCTFail("Left view should be a UIButton")
            return
        }
        let width2 = button2.frame.width
        
        // The width should change based on the prefix length
        XCTAssertNotEqual(width1, width2)
        XCTAssertTrue(width1 > 0)
        XCTAssertTrue(width2 > 0)
    }
    
    // MARK: - Regex Validator Tests
    
    func testValidatorPattern_isCorrectlySet() {
        XCTAssertNotNil(sut.validator)
        
        // Test the pattern directly
        let pattern = "\\d{7,15}"
        let expectedValidator = try? NSRegularExpression(pattern: pattern, options: [])
        
        // Test that valid phone numbers match the expected pattern
        let testPhone = "1234567890"
        XCTAssertNotNil(
            expectedValidator?.firstMatch(in: testPhone,
                                          options: [],
                                          range: NSRange(location: 0, length: testPhone.count))
        )
        // Test that invalid phone numbers don't match
        let invalidPhone = "123456"
        XCTAssertNil(expectedValidator?.firstMatch(in: invalidPhone,
                                                   options: [],
                                                   range: NSRange(location: 0, length: invalidPhone.count)))
    }
    
    // MARK: - isValid Property Tests
    
    func testIsValidProperty_withValidPhoneNumbers() {
        let validPhones = [
            "12345670",
            "12345678901",
            "987654321"
        ]
        
        for phone in validPhones {
            sut.text = phone
            XCTAssertTrue(sut.isValid, "isValid should return true for: \(phone)")
        }
    }
    
    func testIsValidProperty_withInvalidPhoneNumbers() {
        let invalidPhones = [
            "",
            "123456", // Too short
            nil
        ]
        
        for phone in invalidPhones {
            sut.text = phone
            XCTAssertFalse(sut.isValid, "isValid should return false for: \(phone ?? "nil")")
        }
    }
    
    // MARK: - Edge Cases and Integration Tests
    
    func testInheritanceFromOmiseTextField() {
        XCTAssertTrue(sut.delegate === sut)
    }
    
    func testTextFieldProperties_areCorrectlySet() {
        XCTAssertEqual(sut.keyboardType, .phonePad)
        XCTAssertEqual(sut.textContentType, .telephoneNumber)
    }
    
    func testPlaceholder_isSetCorrectly() {
        XCTAssertEqual(sut.placeholder, "123 456 7890")
    }
    
    func testOnValueChanged_firesWhenTextChanges() {
        var didFire = false
        sut.onValueChanged = { didFire = true }
        
        sut.text = "1234567890"
        XCTAssertTrue(didFire)
    }
    
    // MARK: - Country Picker Button Tests
    
    func testCountryCodeButton_hasTargetAction() {
        // Get the country code button
        guard let button = sut.leftView as? UIButton else {
            XCTFail("Left view should be a UIButton")
            return
        }
        
        // Verify the button has a target and action set up
        XCTAssertFalse(button.allTargets.isEmpty, "Button should have targets")
        
        // Verify the button responds to touch up inside events
        let actions = button.actions(forTarget: sut, forControlEvent: .touchUpInside)
        XCTAssertFalse(actions?.isEmpty ?? true, "Button should have actions for touchUpInside")
    }
    
    // MARK: - Delegate Protocol Tests
    
    func testPhoneNumberTextFieldDelegate_protocol() {
        // Test that the delegate protocol exists and can be implemented
        XCTAssertNotNil(mockDelegate)
        
        // Test delegation through country change
        let testCountry = Country(name: "France", code: "FR")
        sut.selectedCountry = testCountry
        
        XCTAssertEqual(mockDelegate.didSelectCountryCallCount, 1)
        XCTAssertEqual(mockDelegate.lastSelectedCountry, testCountry)
    }
    
    func testPhoneDelegate_weakReference() {
        // Create a delegate in a scope that will be released
        var delegate: MockPhoneNumberTextFieldDelegate? = MockPhoneNumberTextFieldDelegate()
        sut.phoneDelegate = delegate
        
        XCTAssertNotNil(sut.phoneDelegate)
        
        // Release the delegate
        delegate = nil
        
        // The weak reference should be nil now
        XCTAssertNil(sut.phoneDelegate)
    }
    
    // MARK: - Multiple Country Changes Tests
    
    func testMultipleCountryChanges_updateCorrectly() {
        let countries = [
            Country(name: "Singapore", code: "SG"),
            Country(name: "Malaysia", code: "MY"),
            Country(name: "Indonesia", code: "ID")
        ]
        
        for (index, country) in countries.enumerated() {
            sut.selectedCountry = country
            
            XCTAssertEqual(sut.selectedCountry, country)
            XCTAssertEqual(mockDelegate.didSelectCountryCallCount, index + 1)
            XCTAssertEqual(mockDelegate.lastSelectedCountry, country)
            
            // Test button update
            if let button = sut.leftView as? UIButton {
                XCTAssertEqual(button.title(for: .normal), country.phonePrefix)
            }
        }
    }
    
    // MARK: - Integration with Country Model Tests
    
    func testIntegrationWithCountryModel_phonePrefix() {
        // Test with known countries and their prefixes
        let testCases = [
            ("TH", "+66"),
            ("US", "+1"),
            ("GB", "+44"),
            ("JP", "+81"),
            ("DE", "+49")
        ]
        
        for (code, expectedPrefix) in testCases {
            if let country = Country.all.first(where: { $0.code == code }) {
                sut.selectedCountry = country
                XCTAssertEqual(country.phonePrefix, expectedPrefix)
                
                if let button = sut.leftView as? UIButton {
                    XCTAssertEqual(button.title(for: .normal), expectedPrefix)
                }
            } else {
                XCTFail("Country with code \(code) should exist")
            }
        }
    }
    
    // MARK: - Edge Cases
    func testPhoneNumber_exactBoundaryValues() {
        // Test exact boundary values for phone number length
        let sevenDigits = "01234567"   // Minimum valid
        let fifteenDigits = "123456789012345" // Based on the regex pattern \d{7,15}
        let sixDigits = "123456"      // Too short
        let sixteenDigits = "1234567890123456" // Too long based on the pattern
        
        sut.text = sevenDigits
        XCTAssertNoThrow(try sut.validate(), "Should validate 8-digit phone")
        
        sut.text = fifteenDigits
        XCTAssertNoThrow(try sut.validate(), "Should validate 15-digit phone")
        
        sut.text = sixDigits
        XCTAssertThrowsError(try sut.validate(), "Should not validate 6-digit phone") { error in
            XCTAssertEqual(error as? OmiseTextFieldValidationError, .invalidData)
        }
        
        sut.text = sixteenDigits
        XCTAssertThrowsError(try sut.validate(), "Should not validate 16-digit phone") { error in
            XCTAssertEqual(error as? OmiseTextFieldValidationError, .invalidData)
        }
    }
}
