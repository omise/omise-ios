import XCTest
@testable import OmiseSDK

class PaymentInformationTestCase: XCTestCase {
    
    static func makeJSONEncoder() -> JSONEncoder {
        let encoder = Client.makeJSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        return encoder
    }
    
    func testEncodeInternetBankingSourceParameter() throws {
        let encoder = PaymentInformationTestCase.makeJSONEncoder()
        
        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: PaymentInformation.installment(PaymentInformation.Installment(brand: PaymentInformation.Installment.Brand.bay, numberOfTerms: 6)), amount: 10_000_00, currency: .thb)
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
            let sourceParameter = Source.CreateParameter(paymentInformation: PaymentInformation.installment(PaymentInformation.Installment(brand: PaymentInformation.Installment.Brand.firstChoice, numberOfTerms: 6)), amount: 100_00, currency: .thb)
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
            let sourceParameter = Source.CreateParameter(paymentInformation: PaymentInformation.installment(PaymentInformation.Installment(brand: PaymentInformation.Installment.Brand.bbl, numberOfTerms: 6)), amount: 1_000_00, currency: .thb)
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
            let sourceParameter = Source.CreateParameter(paymentInformation: PaymentInformation.installment(PaymentInformation.Installment(brand: PaymentInformation.Installment.Brand.ktc, numberOfTerms: 6)), amount: 10_00, currency: .thb)
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
            let sourceParameter = Source.CreateParameter(paymentInformation: PaymentInformation.installment(PaymentInformation.Installment(brand: PaymentInformation.Installment.Brand.kBank, numberOfTerms: 6)), amount: 10_00, currency: .thb)
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
    }
    
    func testEncodeInstallmentsSourceParameter() throws {
        let encoder = PaymentInformationTestCase.makeJSONEncoder()
        
        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: PaymentInformation.internetBanking(.bay), amount: 10_000_00, currency: .thb)
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
            let sourceParameter = Source.CreateParameter(paymentInformation: PaymentInformation.internetBanking(.ktb), amount: 100_00, currency: .thb)
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
            let sourceParameter = Source.CreateParameter(paymentInformation: PaymentInformation.internetBanking(.scb), amount: 1_000_00, currency: .thb)
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
            let sourceParameter = Source.CreateParameter(paymentInformation: PaymentInformation.internetBanking(.bbl), amount: 10_00, currency: .thb)
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
    
    func testEncodeBarcodeAlipaySourceParameter() throws {
        let encoder = PaymentInformationTestCase.makeJSONEncoder()
        
        do {
            let storeInformation = PaymentInformation.Barcode.AlipayBarcode.StoreInformation(storeID: "store_id_1", storeName: "Store Name")
            let sourceParameter = Source.CreateParameter(paymentInformation: PaymentInformation.barcode(.alipay(PaymentInformation.Barcode.AlipayBarcode.init(barcode: "barcode", storeInformation: storeInformation, terminalID: "Terminal 1"))), amount: 10_000_00, currency: .thb)
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
            let sourceParameter = Source.CreateParameter(paymentInformation: PaymentInformation.barcode(.alipay(PaymentInformation.Barcode.AlipayBarcode.init(barcode: "barcode", terminalID: "Terminal 1"))), amount: 10_000_00, currency: .thb)
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
            let sourceParameter = Source.CreateParameter(paymentInformation: PaymentInformation.barcode(.alipay(PaymentInformation.Barcode.AlipayBarcode.init(barcode: "barcode", terminalID: nil))), amount: 10_000_00, currency: .thb)
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
            let paymentInformation = PaymentInformation.truemoney(.init(phoneNumber: "0123456789"))
            let sourceParameter = Source.CreateParameter(paymentInformation: paymentInformation, amount: 10_000_00, currency: .thb)
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
            let sourceParameter = Source.CreateParameter(paymentInformation: .points(.citiPoints), amount: 10_000_00, currency: .thb)
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
    
    func testOtherPaymentInfromation() throws {
        let encoder = PaymentInformationTestCase.makeJSONEncoder()
        
        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: PaymentInformation.alipay, amount: 300_00, currency: .thb)
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
            let sourceParameter = Source.CreateParameter(paymentInformation: PaymentInformation.billPayment(.tescoLotus), amount: 123_45, currency: .thb)
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
