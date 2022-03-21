// swiftlint:disable file_length
import XCTest
@testable import OmiseSDK

// swiftlint:disable type_body_length function_body_length
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
                  "installment_term" : 6,
                  "platform_type" : "IOS",
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
                  "installment_term" : 6,
                  "platform_type" : "IOS",
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
                  "installment_term" : 6,
                  "platform_type" : "IOS",
                  "type" : "installment_bbl"
                }
                """, encodedJSONString)
        }

        do {
            let installment = PaymentInformation.Installment(brand: .ezypay, numberOfTerms: 6)
            let sourceParameter = Source.CreateParameter(paymentInformation: .installment(installment),
                                                         amount: 5_000_00,
                                                         currency: .myr)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 500000,
                  "currency" : "MYR",
                  "installment_term" : 6,
                  "platform_type" : "IOS",
                  "type" : "installment_ezypay"
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
                  "installment_term" : 6,
                  "platform_type" : "IOS",
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
                  "installment_term" : 6,
                  "platform_type" : "IOS",
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
                  "installment_term" : 9,
                  "platform_type" : "IOS",
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
                  "installment_term" : 6,
                  "platform_type" : "IOS",
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
                  "installment_term" : 6,
                  "platform_type" : "IOS",
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
                  "installment_term" : 6,
                  "platform_type" : "IOS",
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
                  "platform_type" : "IOS",
                  "type" : "internet_banking_bay"
                }
                """, encodedJSONString)
        }

        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .internetBanking(.ktb),
                                                         amount: 100_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 10000,
                  "currency" : "THB",
                  "platform_type" : "IOS",
                  "type" : "internet_banking_ktb"
                }
                """, encodedJSONString)
        }

        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .internetBanking(.scb),
                                                         amount: 1_000_00,
                                                         currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 100000,
                  "currency" : "THB",
                  "platform_type" : "IOS",
                  "type" : "internet_banking_scb"
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
                  "platform_type" : "IOS",
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
                  "platform_type" : "IOS",
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
                  "platform_type" : "IOS",
                  "type" : "mobile_banking_kbank"
                }
                """, encodedJSONString)
        }
        
        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: .mobileBanking(.ocbcPao),
                                                         amount: 10_000_00,
                                                         currency: .sgd)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "currency" : "SGD",
                  "platform_type" : "IOS",
                  "type" : "mobile_banking_ocbc_pao"
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
                  "platform_type" : "IOS",
                  "type" : "mobile_banking_bay"
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
                  "platform_type" : "IOS",
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
                  "platform_type" : "IOS",
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
                  "platform_type" : "IOS",
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
                  "phone_number" : "0123456789",
                  "platform_type" : "IOS",
                  "type" : "truemoney"
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
                  "platform_type" : "IOS",
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
                  "platform_type" : "IOS",
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
                  "platform_type" : "IOS",
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
                  "platform_type" : "IOS",
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
                  "platform_type" : "IOS",
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
                  "platform_type" : "IOS",
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
                  "platform_type" : "IOS",
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
                  "platform_type" : "IOS",
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
                  "platform_type" : "IOS",
                  "type" : "rabbit_linepay"
                }
                """, encodedJSONString)
        }
    }

    func testOtherPaymentInfromation() throws {
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
                  "platform_type" : "IOS",
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
                  "platform_type" : "IOS",
                  "type" : "bill_payment_tesco_lotus"
                }
                """, encodedJSONString)
        }
    }

}
