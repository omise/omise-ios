import XCTest
import OmiseSDK

class OmiseJsonParserTest: SDKTestCase {
    func testParseToken() throws {
        guard let data = fixturesDataFor("token_object") else {
            return XCTFail("fixture load failure.")
        }
        
        let token = try OmiseJsonParser.parseToken(from: data)
        guard let card = token.card else {
            XCTFail("failed to parse card data from token.")
            return
        }
    
        XCTAssertEqual(token.tokenId, "tokn_test_5086xl7c9k5rnx35qba")
        XCTAssertEqual(token.livemode, false)
        XCTAssertEqual(token.location, "https://vault.omise.co/tokens/tokn_test_5086xl7c9k5rnx35qba")
        XCTAssertEqual(token.used, false)
        XCTAssertEqual(card.cardId, "card_test_5086xl7amxfysl0ac5l")
        XCTAssertEqual(card.livemode, false)
        XCTAssertEqual(card.country, "us")
        XCTAssertEqual(card.postalCode, "10320")
        XCTAssertEqual(card.financing, "")
        XCTAssertEqual(card.lastDigits, "4242")
        XCTAssertEqual(card.brand, "Visa")
        XCTAssertEqual(card.expirationMonth, 10)
        XCTAssertEqual(card.expirationYear, 2018)
        XCTAssertEqual(card.fingerprint, "mKleiBfwp+PoJWB/ipngANuECUmRKjyxROwFW5IO7TM=")
        XCTAssertEqual(card.name, "Somchai Prasert")
        XCTAssertEqual(card.securityCodeCheck, true)
        XCTAssertEqual(card.created?.timeIntervalSince1970, 1433223706.0)
    }
    
    func testParseError() throws {
        guard let data = fixturesDataFor("error_object") else {
            XCTFail("fixture load failure.")
            return
        }

        let error = try OmiseJsonParser.parseError(from: data) as! OmiseError
        guard case let .api(code, message, location) = error else {
            XCTFail("error is not an API error")
            return
        }
        
        XCTAssertEqual(code, "authentication_failure")
        XCTAssertEqual(location, "https://www.omise.co/api-errors#authentication-failure")
        XCTAssertEqual(message, "authentication failed")
    }
}
