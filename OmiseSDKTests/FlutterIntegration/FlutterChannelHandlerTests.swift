import XCTest
@testable import OmiseSDK
import Flutter

class FlutterChannelHandlerImplTests: XCTestCase {
    var mockFlutterChannel: MockFlutterMethodChannel!
    var flutterChannelHandler: FlutterChannelHandlerImpl!
    
    override func setUp() {
        super.setUp()
        
        mockFlutterChannel = MockFlutterMethodChannel()
        flutterChannelHandler = FlutterChannelHandlerImpl(channel: mockFlutterChannel)
    }
    
    override func tearDown() {
        mockFlutterChannel = nil
        flutterChannelHandler = nil
        super.tearDown()
    }
    
    /// Test Case: Valid token and source received from Flutter
    func testHandleSelectPaymentMethodResult_Success() {
        // Given
        let arguments: [String: Any] = [
            "token": ["id": "token_id", "livemode": true, "used": false, "card": nil, "charge_status": "completed"],
            "source": [
                "id": "src_test_5oxet335rx3xzdyn06g",
                "flow": "app_redirect",
                "amount": 1000000,
                "currency": "THB",
                "livemode": false,
                "type": "touch_n_go"
            ]
        ]
        
        let expectation = self.expectation(description: "Flutter method call handler completes")
        
        // When
        flutterChannelHandler.handleSelectPaymentMethodResult { result in
            switch result {
            case .success(let paymentMethodResult):
                XCTAssertEqual(paymentMethodResult.token?.id, "token_id")
                XCTAssertEqual(paymentMethodResult.source?.id, "src_test_5oxet335rx3xzdyn06g")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
        }
        
        // Simulate method call from Flutter
        mockFlutterChannel.simulateMethodCall(method: "selectPaymentMethodResult", arguments: arguments)
        
        waitForExpectations(timeout: 1.0)
    }
    
    /// Test Case: Missing both token and source in the method arguments
    func testHandleSelectPaymentMethodResult_MissingTokenAndSource() {
        // Given: Arguments are missing both "token" and "source"
        let arguments: [String: Any] = [:]
        
        let expectation = self.expectation(description: "Flutter method call handler completes")
        
        // When
        flutterChannelHandler.handleSelectPaymentMethodResult { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "Missing source and token")
                expectation.fulfill()
            }
        }
        
        // Simulate method call with missing data
        mockFlutterChannel.simulateMethodCall(method: "selectPaymentMethodResult", arguments: arguments)
        
        waitForExpectations(timeout: 1.0)
    }
    
    /// Test Case: Invalid arguments provided to the method
    func testHandleSelectPaymentMethodResult_InvalidArguments() {
        // Given: Arguments are invalid (incorrect key-value pairs)
        let arguments: [String: Any] = ["invalidKey": "invalidValue"]
        
        let expectation = self.expectation(description: "Flutter method call handler completes")
        
        // When
        flutterChannelHandler.handleSelectPaymentMethodResult { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "Missing source and token")
                expectation.fulfill()
            }
        }
        
        // Simulate method call with invalid arguments
        mockFlutterChannel.simulateMethodCall(method: "selectPaymentMethodResult", arguments: arguments)
        
        waitForExpectations(timeout: 1.0)
    }
    
    /// Test Case: Invalid arguments provided to the method
    func testHandleSelectPaymentMethodResult_NilArguments() {
        // Given: Arguments are nil
        let expectation = self.expectation(description: "Flutter method call handler completes")
        
        // When
        flutterChannelHandler.handleSelectPaymentMethodResult { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "Arguments not found or invalid")
                expectation.fulfill()
            }
        }
        
        // Simulate method call with invalid arguments
        mockFlutterChannel.simulateMethodCall(method: "selectPaymentMethodResult", arguments: nil)
        
        waitForExpectations(timeout: 1.0)
    }
    
    /// Test Case: Simulate successful Flutter method call with missing source
    func testHandleSelectPaymentMethodResult_MissingSource() {
        // Given: Arguments have a token but no source
        let arguments: [String: Any] = [
            "token": ["id": "token_id", "livemode": true, "used": false, "card": nil, "charge_status": "completed"]
        ]
        
        let expectation = self.expectation(description: "Flutter method call handler completes")
        
        // When
        flutterChannelHandler.handleSelectPaymentMethodResult { result in
            switch result {
            case .success(let paymentMethodResult):
                XCTAssertNotNil(paymentMethodResult.token)
                XCTAssertNil(paymentMethodResult.source)  // Source is missing
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
        }
        
        // Simulate method call with missing source
        mockFlutterChannel.simulateMethodCall(method: "selectPaymentMethodResult", arguments: arguments)
        
        waitForExpectations(timeout: 1.0)
    }
    
    /// Test Case: Simulate successful Flutter method call with missing token
    func testHandleSelectPaymentMethodResult_MissingToken() {
        // Given: Arguments have a source but no token
        let arguments: [String: Any] = [
            "source": [
                "id": "src_test_5oxet335rx3xzdyn06g",
                "flow": "app_redirect",
                "amount": 1000000,
                "currency": "THB",
                "livemode": false,
                "type": "touch_n_go"
            ]
        ]
        
        let expectation = self.expectation(description: "Flutter method call handler completes")
        
        // When
        flutterChannelHandler.handleSelectPaymentMethodResult { result in
            switch result {
            case .success(let paymentMethodResult):
                XCTAssertNil(paymentMethodResult.token)  // Token is missing
                XCTAssertNotNil(paymentMethodResult.source)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
        }
        
        // Simulate method call with missing token
        mockFlutterChannel.simulateMethodCall(method: "selectPaymentMethodResult", arguments: arguments)
        
        waitForExpectations(timeout: 1.0)
    }
}
