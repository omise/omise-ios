import XCTest
@testable import OmiseSDK

class PaymentInformationTestCase: XCTestCase {

    func testEncodeSourceParameter() throws {
        let encoder = Client.makeJSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        
        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: PaymentInformation.internetBanking(.bay), amount: 10_000_00, currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)
            
            XCTAssertEqual(
                """
                {
                  "amount" : 1000000,
                  "currency" : "thb",
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
                  "currency" : "thb",
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
                  "currency" : "thb",
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
                  "currency" : "thb",
                  "type" : "internet_banking_bbl"
                }
                """, encodedJSONString)
        }
        
        do {
            let sourceParameter = Source.CreateParameter(paymentInformation: PaymentInformation.alipay, amount: 300_00, currency: .thb)
            let encodedJSONString = String(data: try encoder.encode(sourceParameter), encoding: .utf8)
            
            XCTAssertEqual(
                """
                {
                  "amount" : 30000,
                  "currency" : "thb",
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
                  "currency" : "thb",
                  "type" : "bill_payment_tesco_lotus"
                }
                """, encodedJSONString)
        }
    }

}
