import XCTest
@testable import OmiseSDK

class CapabilityOperationFixtureTests: XCTestCase {

    func validateCapabilitySupportsCurrency(_ capability: CapabilityOld, sourceType: SourceTypeValue, currencies: Set<Currency>) {
        if let backend = capability[sourceType] {
            XCTAssertEqual(backend.supportedCurrencies, currencies)
        } else {
            XCTFail("CapabilityOld doesn't have the \(sourceType) backend")
        }
    }

    func testCapabilityRetrieve() {
        let decoder = ClientOld.makeJSONDecoder(for: Request<SourceOLD>?.none)

        do {
            let capabilityData = try XCTestCase.fixturesData(forFilename: "capability")
            let capability = try decoder.decode(CapabilityOld.self, from: capabilityData)

            XCTAssertEqual(capability.supportedBackends.count, 33)

            if let creditCardBackend = capability.creditCardBackend {
                XCTAssertEqual(creditCardBackend.payment, .card([]))
                XCTAssertEqual(creditCardBackend.supportedCurrencies, [.thb, .jpy, .usd, .eur, .gbp, .sgd, .aud, .chf, .cny, .dkk, .hkd])
            } else {
                XCTFail("CapabilityOld doesn't have the Credit Card backend")
            }

            if let bayInstallmentBackend = capability[SourceTypeValue.installmentBAY] {
                XCTAssertEqual(
                    bayInstallmentBackend.payment,
                    .installment(.bay, availableNumberOfTerms: IndexSet([3, 4, 6, 9, 10]))
                )
                XCTAssertEqual(bayInstallmentBackend.supportedCurrencies, [.thb])
            } else {
                XCTFail("CapabilityOld doesn't have the BAY Installment backend")
            }

            if let fpxBackend = capability[SourceTypeValue.fpx] {
                XCTAssertEqual(fpxBackend.banks, [
                    CapabilityOld.Backend.Bank(name: "UOB", code: "uob", isActive: true)
                ])
            } else {
               XCTFail("CapabilityOld doesn't have the FPX backend")
            }

            if let mobileBankingKBankBackend = capability[SourceTypeValue.mobileBankingKBank] {
                XCTAssertEqual(
                    mobileBankingKBankBackend.payment, .mobileBanking(.kbank))
                XCTAssertEqual(mobileBankingKBankBackend.supportedCurrencies, [.thb])
            } else {
                XCTFail("CapabilityOld doesn't have the Mobile Banking KBank backend")
            }

            validateCapabilitySupportsCurrency(capability, sourceType: .trueMoney, currencies: [.thb])
            validateCapabilitySupportsCurrency(capability, sourceType: .trueMoneyJumpApp, currencies: [.thb])
            validateCapabilitySupportsCurrency(capability, sourceType: .pointsCiti, currencies: [.thb])
            validateCapabilitySupportsCurrency(capability, sourceType: .rabbitLinepay, currencies: [.thb])
            validateCapabilitySupportsCurrency(capability, sourceType: .grabPay, currencies: [.sgd, .myr])
            validateCapabilitySupportsCurrency(capability, sourceType: .payPay, currencies: [.jpy])
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }

    func testEncodeCapabilityRetrieve() throws {
        let decoder = ClientOld.makeJSONDecoder(for: Request<SourceOLD>?.none)
        let capabilityData = try XCTestCase.fixturesData(forFilename: "capability")
        let capability = try decoder.decode(CapabilityOld.self, from: capabilityData)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let encodedData = try encoder.encode(capability)

        let decodedCapability = try decoder.decode(CapabilityOld.self, from: encodedData)
        XCTAssertEqual(capability.supportedBackends.count, decodedCapability.supportedBackends.count)

        XCTAssertEqual(capability.creditCardBackend?.payment, decodedCapability.creditCardBackend?.payment)
        XCTAssertEqual(capability.creditCardBackend?.supportedCurrencies,
                       decodedCapability.creditCardBackend?.supportedCurrencies)
        XCTAssertEqual(
            capability[.installmentBAY]?.payment,
            decodedCapability[.installmentBAY]?.payment
        )
        XCTAssertEqual(capability[.installmentBAY]?.supportedCurrencies,
                       decodedCapability[.installmentBAY]?.supportedCurrencies)
        XCTAssertEqual(capability[.installmentBAY]?.payment,
                       decodedCapability[.installmentBAY]?.payment)
    }
}
