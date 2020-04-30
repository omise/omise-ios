import XCTest
@testable import OmiseSDK


class CapabilityOperationFixtureTests: XCTestCase {
    
    func testCapabilityRetrieve() {
        let decoder = Client.makeJSONDecoder(for: Request<Source>?.none)
        
        do {
            let capabilityData = XCTestCase.fixturesData(forFilename: "capability")
            let capability = try decoder.decode(Capability.self, from: capabilityData)
            
            XCTAssertEqual(capability.supportedBackends.count, 8)
            
            if let creditCardBackend = capability.creditCardBackend {
                XCTAssertEqual(creditCardBackend.payment, .card([]))
                XCTAssertEqual(creditCardBackend.supportedCurrencies, [.thb, .jpy, .usd, .eur, .gbp, .sgd, .aud, .chf, .cny, .dkk, .hkd])
            } else {
                XCTFail("Capability doesn't have the Credit Card backend")
            }
            
            if let bayInstallmentBackend = capability[OMSSourceTypeValue.installmentBAY] {
                XCTAssertEqual(
                    bayInstallmentBackend.payment,
                    .installment(.bay, availableNumberOfTerms: IndexSet(arrayLiteral: 3, 4, 6, 9, 10))
                )
                XCTAssertEqual(bayInstallmentBackend.supportedCurrencies, [.thb])
            } else {
                XCTFail("Capability doesn't have the BAY Installment backend")
            }
            
            if let trueMoneyBackend = capability[OMSSourceTypeValue.trueMoney] {
                XCTAssertEqual(trueMoneyBackend.supportedCurrencies, [.thb])
            } else {
               XCTFail("Capability doesn't have the TrueMoney backend")
            }
            
            if let citiPointsBackend = capability[OMSSourceTypeValue.pointsCiti] {
                XCTAssertEqual(citiPointsBackend.supportedCurrencies, [.thb])
            } else {
               XCTFail("Capability doesn't have the Citi Points backend")
            }
            
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }
    
    func testEncodeCapabilityRetrieve() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Source>?.none)
        let capabilityData = XCTestCase.fixturesData(forFilename: "capability")
        let capability = try decoder.decode(Capability.self, from: capabilityData)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let encodedData = try encoder.encode(capability)

        
        let decodedCapability = try decoder.decode(Capability.self, from: encodedData)
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

