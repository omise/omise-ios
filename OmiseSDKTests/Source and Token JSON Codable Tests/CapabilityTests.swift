import Foundation
import XCTest
@testable import OmiseSDK

class CapabilityTests: XCTestCase {
    func testJSONEncodingDecoding() throws {
        let payments: [Capability.PaymentMethod] = [
            Capability.PaymentMethod(
                name: "card",
                currencies: ["THB", "JPY", "USD", "EUR", "GBP", "SGD", "AUD", "CHF", "CNY", "DKK", "HKD"],
                cardBrands: ["JCB", "Visa", "MasterCard", "UnionPay"],
                installmentTerms: nil,
                banks: nil,
                provider: nil
            ),
            Capability.PaymentMethod(
                name: "installment_bay",
                currencies: ["THB"],
                cardBrands: nil,
                installmentTerms: [3, 4, 6, 9, 10],
                banks: nil,
                provider: nil
            )
        ]
        
        // swiftlint:disable:next line_length
        let banks = ["test", "bbl", "kbank", "rbs", "ktb", "jpm", "mufg", "tmb", "scb", "smbc", "sc", "cimb", "uob", "bay", "mega", "boa", "cacib", "gsb", "hsbc", "db", "ghb", "baac", "mb", "bnp", "tbank", "ibank", "tisco", "kk", "icbc", "tcrb", "lhb"]

        let capability = Capability(
            countryCode: "TH",
            paymentMethods: payments,
            banks: Set(banks)
        )

        let sample: Capability = try sampleFromJSONBy(.capability)
        XCTAssertEqual(sample.banks, capability.banks)
        XCTAssertEqual(sample.countryCode, capability.countryCode)
        XCTAssertEqual(sample.paymentMethods[0], payments[0])
        XCTAssertEqual(sample.paymentMethods[1], payments[1])
    }
}
