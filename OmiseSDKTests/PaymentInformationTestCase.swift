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
                  "type" : "installment_scb"
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
                  "type" : "mobile_banking_scb"
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
                  "type" : "fpx"
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
                  "type" : "bill_payment_tesco_lotus"
                }
                """, encodedJSONString)
        }
    }
    
}
