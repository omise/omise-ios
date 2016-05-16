import XCTest
import OmiseSDK

class TestOmiseTokenizerDelegate: OmiseTokenizerDelegate {
    var delegateAsyncResult: Bool? = .None
    
    var asyncExpectation: XCTestExpectation?
    
    func OmiseRequestTokenOnFailed(error: NSError?) {
        guard let expectation = asyncExpectation else {
            XCTFail("TestOmiseTokenizerDelegate was not setup correctly. Missing XCTExpectation reference")
            return
        }
        delegateAsyncResult = true
        expectation.fulfill()
    }
    
    func OmiseRequestTokenOnSucceeded(token: OmiseToken?) {
        guard let expectation = asyncExpectation else {
            XCTFail("TestOmiseTokenizerDelegate was not setup correctly. Missing XCTExpectation reference")
            return
        }
        delegateAsyncResult = true
        expectation.fulfill()
    }
}

class OmiseTokenizerTests: XCTestCase {
    func testOmiseCard() {
        
        let card = OmiseCard()
        card.cardId = "card_test_5086xl7amxfysl0ac5l"
        card.livemode = false
        card.location = "/customers/cust_test_5086xleuh9ft4bn0ac2/cards/card_test_5086xl7amxfysl0ac5l"
        card.country = "us"
        card.city = "Bangkok"
        card.postalCode = "10320"
        card.financing = ""
        card.lastDigits = "4242"
        card.brand = "Visa"
        card.expirationMonth = 10
        card.expirationYear = 2018
        card.fingerprint = "ipngANuECUmRKjyxROwFW5IO7TM"
        card.name = "Somchai Prasert"
        card.securityCodeCheck = true
        card.created = "2015-06-02T05:41:46Z"
        
        XCTAssertNotNil(card)
        XCTAssertEqual(card.cardId, "card_test_5086xl7amxfysl0ac5l")
        XCTAssertEqual(card.livemode, false)
        XCTAssertEqual(card.location, "/customers/cust_test_5086xleuh9ft4bn0ac2/cards/card_test_5086xl7amxfysl0ac5l")
        XCTAssertEqual(card.country, "us")
        XCTAssertEqual(card.postalCode, "10320")
        XCTAssertEqual(card.financing, "")
        XCTAssertEqual(card.lastDigits, "4242")
        XCTAssertEqual(card.brand, "Visa")
        XCTAssertEqual(card.expirationMonth, 10)
        XCTAssertEqual(card.expirationYear, 2018)
        XCTAssertEqual(card.fingerprint, "ipngANuECUmRKjyxROwFW5IO7TM")
        XCTAssertEqual(card.name, "Somchai Prasert")
        XCTAssertEqual(card.securityCodeCheck, true)
        XCTAssertEqual(card.created, "2015-06-02T05:41:46Z")
    }
    
    func testOmiseToken() {
        guard let data = fixturesDataFor("token_object") else {
            XCTFail("Could not load token_object")
            return
        }
        
        let jsonParser = OmiseJsonParser()
        guard let token = jsonParser.parseOmiseToken(data) else {
            XCTFail("Could not parse token")
            return
        }
        
        guard let card = token.card else {
            XCTFail("Could not parse card from token object")
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
        XCTAssertEqual(card.created, "2015-06-02T05:41:46Z")
        
    }
    
    func testOmiseError() {
        guard let data = fixturesDataFor("error_object") else {
            XCTFail("Could not load error_object")
            return
        }
        
        let jsonParser = OmiseJsonParser()
        guard let error = jsonParser.parseOmiseError(data) else {
            XCTFail("Could not parse error")
            return
        }
        
        XCTAssertEqual(error.code, "authentication_failure")
        XCTAssertEqual(error.location, "https://www.omise.co/api-errors#authentication-failure")
        XCTAssertEqual(error.message, "authentication failed")
    }
    
    func testRequestToken() {
        let tokenRequest = OmiseRequestObject()
        tokenRequest.publicKey = "pkey_test_4y7dh41kuvvawbhslxw" //required
        tokenRequest.card!.name = "JOHN DOE" //required
        tokenRequest.card!.city = "Bangkok" //optional
        tokenRequest.card!.postalCode = "10320" //optional
        tokenRequest.card!.number = "4242424242424242" //required
        tokenRequest.card!.expirationMonth = 11 //required
        tokenRequest.card!.expirationYear = 2016 //required
        tokenRequest.card!.securityCode = "123" //required
        
        let omise = Omise()
        let testDelegate = TestOmiseTokenizerDelegate()
        omise.delegate = testDelegate
        
        let expectation = expectationWithDescription("Omise calls the delegate as the result of an async method completion")
        testDelegate.asyncExpectation = expectation
        
        // Call Async
        omise.requestToken(tokenRequest)
        
        let timeOut: NSTimeInterval = 15.0
        waitForExpectationsWithTimeout(timeOut) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            
            guard let result = testDelegate.delegateAsyncResult else {
                XCTFail("Expected delegate to be called")
                return
            }
            
            XCTAssertTrue(result)
        }
    }
    
    // MARK: - Helper for load JSON file to test
    private func fixturesDataFor(filename: String) -> NSData? {
        let bundle = NSBundle(forClass: OmiseTokenizerTests.self)
        guard let path = bundle.pathForResource("Fixtures/objects/\(filename)", ofType: "json") else {
            XCTFail("could not load fixtures.")
            return nil
        }
        
        guard let data = NSData(contentsOfFile: path) else {
            XCTFail("could not load fixtures at path: \(path)")
            return nil
        }
        
        return data
    }
    
}
