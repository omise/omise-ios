// swiftlint:disable file_length
import XCTest
@testable import OmiseSDK

// swiftlint:disable function_body_length
// swiftlint:disable:next type_body_length
class PaymentInformationTestCase: XCTestCase {

    static func makeJSONEncoder() -> JSONEncoder {
        let encoder = Client.makeJSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        return encoder
    }

    func testEncodeInstallmentsSourceParameter() throws {
        let encoder = PaymentInformationTestCase.makeJSONEncoder()

        do {
            let installment = PaymentInformation.Installment(brand: .bay, numberOfTerms: 6)
            let sourceParameter = Source.CreateParameter(paymentInformation: .installment(installment),
                                                         amount: 10_000_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "currency" : "THB",
                  "email" : null,
                  "installment_term" : 6,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "installment_bay"
                }
                """, encodedJSONString)
        }

        do {
            let installment = PaymentInformation.Installment(brand: .firstChoice, numberOfTerms: 6)
            let sourceParameter = Source.CreateParameter(paymentInformation: .installment(installment),
                                                         amount: 100_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 10000,
                  "currency" : "THB",
                  "email" : null,
                  "installment_term" : 6,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "installment_first_choice"
                }
                """, encodedJSONString)
        }

        do {
            let installment = PaymentInformation.Installment(brand: .bbl, numberOfTerms: 6)
            let sourceParameter = Source.CreateParameter(paymentInformation: .installment(installment),
                                                         amount: 1_000_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 100000,
                  "currency" : "THB",
                  "email" : null,
                  "installment_term" : 6,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "installment_bbl"
                }
                """, encodedJSONString)
        }

        do {
            let installment = PaymentInformation.Installment(brand: .mbb, numberOfTerms: 6)
            let sourceParameter = Source.CreateParameter(paymentInformation: .installment(installment),
                                                         amount: 5_000_00,
                                                         currency: .myr)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 500000,
                  "currency" : "MYR",
                  "email" : null,
                  "installment_term" : 6,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "installment_mbb"
                }
                """, encodedJSONString)
        }

        do {
            let installment = PaymentInformation.Installment(brand: .ktc, numberOfTerms: 6)
            let sourceParameter = Source.CreateParameter(paymentInformation: .installment(installment),
                                                         amount: 10_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 1000,
                  "currency" : "THB",
                  "email" : null,
                  "installment_term" : 6,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "installment_ktc"
                }
                """, encodedJSONString)
        }

        do {
            let installment = PaymentInformation.Installment(brand: .kBank, numberOfTerms: 6)
            let sourceParameter = Source.CreateParameter(paymentInformation: .installment(installment),
                                                         amount: 10_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 1000,
                  "currency" : "THB",
                  "email" : null,
                  "installment_term" : 6,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "installment_kbank"
                }
                """, encodedJSONString)
        }

        do {
            let installment = PaymentInformation.Installment(brand: .scb, numberOfTerms: 9)
            let sourceParameter = Source.CreateParameter(paymentInformation: .installment(installment),
                                                         amount: 30_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 3000,
                  "currency" : "THB",
                  "email" : null,
                  "installment_term" : 9,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "installment_scb"
                }
                """, encodedJSONString)
        }

        do {
            let installment = PaymentInformation.Installment(brand: .citi, numberOfTerms: 6)
            let sourceParameter = Source.CreateParameter(paymentInformation: .installment(installment),
                                                         amount: 30_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 3000,
                  "currency" : "THB",
                  "email" : null,
                  "installment_term" : 6,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "installment_citi"
                }
                """, encodedJSONString)
        }

        do {
            let installment = PaymentInformation.Installment(brand: .ttb, numberOfTerms: 6)
            let sourceParameter = Source.CreateParameter(paymentInformation: .installment(installment),
                                                         amount: 30_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 3000,
                  "currency" : "THB",
                  "email" : null,
                  "installment_term" : 6,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "installment_ttb"
                }
                """, encodedJSONString)
        }

        do {
            let installment = PaymentInformation.Installment(brand: .uob, numberOfTerms: 6)
            let sourceParameter = Source.CreateParameter(paymentInformation: .installment(installment),
                                                         amount: 30_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 3000,
                  "currency" : "THB",
                  "email" : null,
                  "installment_term" : 6,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "installment_uob"
                }
                """, encodedJSONString)
        }
    }

    func testEncodeInternetBankingSourceParameter() throws {
        let encoder = PaymentInformationTestCase.makeJSONEncoder()

        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .internetBanking(.bay),
                                                         amount: 10_000_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "currency" : "THB",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "internet_banking_bay"
                }
                """, encodedJSONString)
        }

        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .internetBanking(.bbl),
                                                         amount: 10_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 1000,
                  "currency" : "THB",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "internet_banking_bbl"
                }
                """, encodedJSONString)
        }
    }

    func testEncodeMobileBankingSourceParameter() throws {
        let encoder = PaymentInformationTestCase.makeJSONEncoder()

        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .mobileBanking(.scb),
                                                         amount: 10_000_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "currency" : "THB",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "mobile_banking_scb"
                }
                """, encodedJSONString)
        }

        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .mobileBanking(.kbank),
                                                         amount: 10_000_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "currency" : "THB",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "mobile_banking_kbank"
                }
                """, encodedJSONString)
        }

        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .ocbcPao,
                                                         amount: 10_000_00,
                                                         currency: .sgd)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "currency" : "SGD",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "mobile_banking_ocbc_pao"
                }
                """, encodedJSONString)
        }

        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .ocbcDigital,
                                                         amount: 10_000_00,
                                                         currency: .sgd)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "currency" : "SGD",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "mobile_banking_ocbc"
                }
                """, encodedJSONString)
        }

        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .mobileBanking(.bay),
                                                         amount: 10_000_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "currency" : "THB",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "mobile_banking_bay"
                }
                """, encodedJSONString)
        }

        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .mobileBanking(.bbl),
                                                         amount: 10_000_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "currency" : "THB",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "mobile_banking_bbl"
                }
                """, encodedJSONString)
        }

        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .mobileBanking(.ktb),
                                                         amount: 10_000_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "currency" : "THB",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "mobile_banking_ktb"
                }
                """, encodedJSONString)
        }
    }

    func testEncodeBarcodeAlipaySourceParameter() throws {
        let encoder = PaymentInformationTestCase.makeJSONEncoder()

        do {
            typealias AlipayBarcode = PaymentInformation.Barcode.AlipayBarcode
            let storeInformation = AlipayBarcode.StoreInformation(storeID: "store_id_1", storeName: "Store Name")
            let barcode = AlipayBarcode(barcode: "barcode",
                                        storeInformation: storeInformation,
                                        terminalID: "Terminal 1")
            let sourceParameter = Source.CreateParameter(paymentInformation: .barcode(.alipay(barcode)),
                                                         amount: 10_000_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)
            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "barcode" : "barcode",
                  "currency" : "THB",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "store_id" : "store_id_1",
                  "store_name" : "Store Name",
                  "terminal_id" : "Terminal 1",
                  "type" : "barcode_alipay"
                }
                """, encodedJSONString)
        }

        do {
            let barcode = PaymentInformation.Barcode.AlipayBarcode(barcode: "barcode", terminalID: "Terminal 1")
            let sourceParameter = Source.CreateParameter(paymentInformation: .barcode(.alipay(barcode)),
                                                         amount: 10_000_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)
            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "barcode" : "barcode",
                  "currency" : "THB",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "terminal_id" : "Terminal 1",
                  "type" : "barcode_alipay"
                }
                """, encodedJSONString)
        }

        do {
            let barcode = PaymentInformation.Barcode.AlipayBarcode(barcode: "barcode", terminalID: nil)
            let sourceParameter = Source.CreateParameter(paymentInformation: .barcode(.alipay(barcode)),
                                                         amount: 10_000_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)
            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "barcode" : "barcode",
                  "currency" : "THB",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "barcode_alipay"
                }
                """, encodedJSONString)
        }
    }

    func testEncodeTrueMoneySourceParameter() throws {
        let encoder = PaymentInformationTestCase.makeJSONEncoder()

        do {
            let trueMoney = PaymentInformation.TrueMoney(phoneNumber: "0123456789")
            let sourceParameter = Source.CreateParameter(paymentInformation: .truemoney(trueMoney),
                                                         amount: 10_000_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)
            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "currency" : "THB",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : "0123456789",
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "truemoney"
                }
                """, encodedJSONString)
        }
    }

    func testEncodeTrueMoneyJumpAppSourceParameter() throws {
        let encoder = PaymentInformationTestCase.makeJSONEncoder()

        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .truemoneyJumpApp,
                                                         amount: 10_000_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)
            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "currency" : "THB",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "truemoney_jumpapp"
                }
                """, encodedJSONString)
        }
    }
    func testEncodePointsSourceParameter() throws {
        let encoder = PaymentInformationTestCase.makeJSONEncoder()

        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .points(.citiPoints),
                                                         amount: 10_000_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)
            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "currency" : "THB",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "points_citi"
                }
                """, encodedJSONString)
        }
    }

    func testEncodeFPXSourceParameter() throws {
        let encoder = PaymentInformationTestCase.makeJSONEncoder()

        do {
            let fpx = PaymentInformation.FPX(bank: "uob", email: "support@omise.co")
            let sourceParameter = Source.CreateParameter(paymentInformation: .fpx(fpx),
                                                         amount: 10_000_00,
                                                         currency: .myr)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)
            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "bank" : "uob",
                  "currency" : "MYR",
                  "email" : "support@omise.co",
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "fpx"
                }
                """, encodedJSONString)
        }
    }

    func testEncodeAlipayPlusSourceParameter() throws {
        let encoder = PaymentInformationTestCase.makeJSONEncoder()

        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .alipayCN,
                                                         amount: 10_000_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "currency" : "THB",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "alipay_cn"
                }
                """, encodedJSONString)
        }

        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .alipayHK,
                                                         amount: 10_000_00,
                                                         currency: .hkd)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "currency" : "HKD",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "alipay_hk"
                }
                """, encodedJSONString)
        }

        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .dana,
                                                         amount: 10_000_00,
                                                         currency: .jpy)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "currency" : "JPY",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "dana"
                }
                """, encodedJSONString)
        }

        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .gcash,
                                                         amount: 10_000_00,
                                                         currency: .usd)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "currency" : "USD",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "gcash"
                }
                """, encodedJSONString)
        }

        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .kakaoPay,
                                                         amount: 10_000_00,
                                                         currency: .usd)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "currency" : "USD",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "kakaopay"
                }
                """, encodedJSONString)
        }

        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .touchNGo,
                                                         amount: 10_000_00,
                                                         currency: .sgd)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "currency" : "SGD",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "touch_n_go"
                }
                """, encodedJSONString)
        }

        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .rabbitLinepay,
                                                         amount: 50_000_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 5000000,
                  "currency" : "THB",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "rabbit_linepay"
                }
                """, encodedJSONString)
        }

        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .grabPay,
                                                         amount: 1_000_00,
                                                         currency: .sgd)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 100000,
                  "currency" : "SGD",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "grabpay"
                }
                """, encodedJSONString)
        }
    }

    func testEncodeDuitNowOBWSourceParameter() throws {
        let encoder = PaymentInformationTestCase.makeJSONEncoder()

        do {
            let duitNowOBW = PaymentInformation.DuitNowOBW(bank: "affin")
            let sourceParameter = Source.CreateParameter(paymentInformation: .duitNowOBW(duitNowOBW),
                                                         amount: 10_000_00,
                                                         currency: .myr)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)
            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "bank" : "affin",
                  "currency" : "MYR",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "duitnow_obw"
                }
                """, encodedJSONString)
        }
    }

    func testEncodeAtomeSourceParameter() throws {
        let encoder = PaymentInformationTestCase.makeJSONEncoder()

        do {
            let shipping = PaymentInformation.Atome.ShippingAddress(
                country: "TH",
                city: "Bangkok",
                postalCode: "10200",
                state: "---",
                street1: "4 Sukhumvit 103 rd.",
                street2: "")

            let items = [
                PaymentInformation.Atome.Item(
                    sku: "1",
                    category: "1",
                    name: "1",
                    quantity: 1,
                    amount: 1000000,
                    itemUri: "1",
                    imageUri: "!",
                    brand: "1")
            ]

            let atome = PaymentInformation.Atome(phoneNumber: "+66800000101",
                                                 shippingAddress: shipping,
                                                 items: items)

            let sourceParameter = Source.CreateParameter(paymentInformation: .atome(atome),
                                                         amount: 10_000_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)
            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "currency" : "THB",
                  "email" : null,
                  "items" : [
                {
                "amount" : 1000000,
                "brand" : "1",
                "category" : "1",
                "image_uri" : "!",
                "item_uri" : "1",
                "name" : "1",
                "quantity" : 1,
                "sku" : "1"
                }
                ],
                  "name" : null,
                  "phone_number" : "+66800000101",
                  "platform_type" : "IOS",
                  "shipping" : {
                  "city" : "Bangkok",
                  "country" : "TH",
                  "postal_code" : "10200",
                  "state" : "---",
                  "street1" : "4 Sukhumvit 103 rd.",
                  "street2" : ""
                },
                  "type" : "atome"
                }
                """
                    .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    .replacingOccurrences(of: " ", with: ""),
                encodedJSONString?
                    .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    .replacingOccurrences(of: " ", with: ""))
        }
    }

    func testEncodePayPaySourceParameter() throws {
        let encoder = PaymentInformationTestCase.makeJSONEncoder()

        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .payPay,
                                                         amount: 10_000_00,
                                                         currency: .jpy)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)
            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "currency" : "JPY",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "paypay"
                }
                """, encodedJSONString)
        }
    }
    
    func testOtherPaymentInformation() throws {
        let encoder = PaymentInformationTestCase.makeJSONEncoder()

        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .alipay,
                                                         amount: 300_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 30000,
                  "currency" : "THB",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "alipay"
                }
                """, encodedJSONString)
        }

        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .billPayment(.tescoLotus),
                                                         amount: 123_45,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 12345,
                  "currency" : "THB",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "bill_payment_tesco_lotus"
                }
                """, encodedJSONString)
        }
        
        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .boost,
                                                         amount: 123_45,
                                                         currency: .myr)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 12345,
                  "currency" : "MYR",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "boost"
                }
                """, encodedJSONString)
        }
        
        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .shopeePay,
                                                         amount: 123_45,
                                                         currency: .myr)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 12345,
                  "currency" : "MYR",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "shopeepay"
                }
                """, encodedJSONString)
        }
        
        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .maybankQRPay,
                                                         amount: 123_45,
                                                         currency: .myr)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 12345,
                  "currency" : "MYR",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "maybank_qr"
                }
                """, encodedJSONString)
        }
        
        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .duitNowQR,
                                                         amount: 123_45,
                                                         currency: .myr)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 12345,
                  "currency" : "MYR",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "duitnow_qr"
                }
                """, encodedJSONString)
        }

        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .shopeePayJumpApp,
                                                         amount: 123_45,
                                                         currency: .myr)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 12345,
                  "currency" : "MYR",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "shopeepay_jumpapp"
                }
                """, encodedJSONString)
        }
    }

    func testEncodeWeChatSourceParameter() throws {
        let encoder = PaymentInformationTestCase.makeJSONEncoder()

        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .weChat,
                                                         amount: 10_000_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)
            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "currency" : "THB",
                  "email" : null,
                  "items" : null,
                  "name" : null,
                  "phone_number" : null,
                  "platform_type" : "IOS",
                  "shipping" : null,
                  "type" : "wechat_pay"
                }
                """, encodedJSONString)
        }
    }

}
// swiftlint:enable function_body_length
