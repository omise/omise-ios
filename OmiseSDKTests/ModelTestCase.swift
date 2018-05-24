import XCTest
@testable import OmiseSDK

class ModelTestCase: XCTestCase {
    
    func testDecodeToken() throws {
        let decoder = Client.makeJSONDecoder()
        let tokenData = XCTestCase.fixturesDataFor("token_object")
        let token = try decoder.decode(Token.self, from: tokenData)
        
        XCTAssertEqual("tokn_test_5086xl7c9k5rnx35qba", token.id)
        XCTAssertEqual("https://vault.omise.co/tokens/tokn_test_5086xl7c9k5rnx35qba", token.location)
        XCTAssertFalse(token.isLiveMode)
        XCTAssertEqual(XCTestCase.dateFromJSONString("2015-06-02T05:41:46Z"), token.createdDate)
        XCTAssertFalse(token.isUsed)
        XCTAssertEqual("card_test_5086xl7amxfysl0ac5l", token.card.id)
    }
    
    func testDecodeCard() throws {
        let decoder = Client.makeJSONDecoder()
        let cardData = XCTestCase.fixturesDataFor("card_object")
        let card = try decoder.decode(Card.self, from: cardData)
        
        XCTAssertEqual("card_test_5086xl7amxfysl0ac5l", card.id)
        XCTAssertEqual("4242", card.lastDigits)
        XCTAssertTrue(card.securityCodeCheck)
        XCTAssertEqual(10, card.expirationMonth)
        XCTAssertEqual(2018, card.expirationYear)
        XCTAssertEqual("Somchai Prasert", card.name)
        XCTAssertEqual("mKleiBfwp+PoJWB/ipngANuECUmRKjyxROwFW5IO7TM=", card.fingerprint)
        XCTAssertEqual(XCTestCase.dateFromJSONString("2015-06-02T05:41:46Z"), card.createdDate)
        XCTAssertEqual("us", card.countryCode)
    }
    
    func testDecodeSource() throws {
        let decoder = Client.makeJSONDecoder()
        let cardData = XCTestCase.fixturesDataFor("source_object")
        let source = try decoder.decode(Source.self, from: cardData)
        
        XCTAssertEqual("src_test_59trf2nxk43b5nml8z0", source.id)
        XCTAssertEqual(Currency.thb, source.currency)
        XCTAssertEqual(100000, source.amount)
        XCTAssertEqual(SourceType.billPaymentTescoLotus, source.type)
        XCTAssertEqual(Flow.offline, source.flow)
    }
    
    func testEncodeTokenParams() throws {
        let encoder = Client.makeJSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        
        do {
            let tokenParameter = Token.CreateParameter(name: "John Appleseed", number: "4242424242424242", expirationMonth: 6, expirationYear: 2018, securityCode: "123")
            let encodedJSONString = String(data: try encoder.encode(tokenParameter), encoding: .utf8)
            
            XCTAssertEqual(
                """
                {
                  "card" : {
                    "expiration_month" : 6,
                    "expiration_year" : 2018,
                    "name" : "John Appleseed",
                    "number" : "4242424242424242",
                    "security_code" : "123"
                  }
                }
                """, encodedJSONString)
        }
        
        do {
            let tokenParameter = Token.CreateParameter(name: "John Appleseed", number: "4242424242424242", expirationMonth: 6, expirationYear: 2018, securityCode: "123", city: "Bangkok", postalCode: "12345")
            let encodedJSONString = String(data: try encoder.encode(tokenParameter), encoding: .utf8)
            
            XCTAssertEqual(
                """
                {
                  "card" : {
                    "city" : "Bangkok",
                    "expiration_month" : 6,
                    "expiration_year" : 2018,
                    "name" : "John Appleseed",
                    "number" : "4242424242424242",
                    "postal_code" : "12345",
                    "security_code" : "123"
                  }
                }
                """, encodedJSONString)
        }
    }
    
    func testEncodeSourceParameter() throws {
        let encoder = Client.makeJSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        
        do {
            let sourceParameter = Source.CreateParameter(type: SourceType.internetBankingBAY, amount: 10_000_00, currency: .thb)
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
            let sourceParameter = Source.CreateParameter(type: SourceType.internetBankingKTB, amount: 100_00, currency: .thb)
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
            let sourceParameter = Source.CreateParameter(type: SourceType.internetBankingSCB, amount: 1_000_00, currency: .thb)
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
            let sourceParameter = Source.CreateParameter(type: SourceType.internetBankingBBL, amount: 10_00, currency: .thb)
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
            let sourceParameter = Source.CreateParameter(type: SourceType.alipay, amount: 300_00, currency: .thb)
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
            let sourceParameter = Source.CreateParameter(type: SourceType.billPaymentTescoLotus, amount: 123_45, currency: .thb)
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
