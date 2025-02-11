//
//  FlutterEngineManagerTest.swift
//  dev
//
//  Created by Tyler on 10/2/2568 BE.
//  Copyright © 2568 BE Omise. All rights reserved.
//

import XCTest
import Flutter
@testable import OmiseSDK

class FlutterEngineManagerTests: XCTestCase {
    
    var flutterEngineManager: FlutterEngineManager!
    var mockDelegate: MockChoosePaymentMethodDelegate!
    var mockFlutterEngine: FlutterEngine!
    var mockMethodChannel: FlutterMethodChannel!
    var mockChannelHandler: MockFlutterChannelHandler!
    
    override func setUp() {
        super.setUp()
        // Mock FlutterEngine and MethodChannel
        mockFlutterEngine = FlutterEngine(name: "testEngine")
        mockFlutterEngine.run()
        mockMethodChannel = FlutterMethodChannel(name: OmiseFlutter.channelName,
                                                 binaryMessenger: mockFlutterEngine.binaryMessenger)
        mockChannelHandler = MockFlutterChannelHandler()
        // Initialize FlutterEngineManager with the mock engine
        flutterEngineManager = FlutterEngineManagerImpl(
            flutterEngine: mockFlutterEngine,
            methodChannel: mockMethodChannel,
            channelHander: mockChannelHandler,
            publicKey: "testPublicKey"
        )
        
        // Set up mock delegate
        mockDelegate = MockChoosePaymentMethodDelegate()
    }
    
    override func tearDown() {
        flutterEngineManager = nil
        mockDelegate = nil
        mockFlutterEngine = nil
        mockMethodChannel = nil
        super.tearDown()
    }
    
    // Test: Ensure that the Flutter view controller is presented and returns correctly
    func testPresentFlutterPaymentMethod() {
        let viewController = UIViewController()
        let amount: Int64 = 10_000
        let currency = "THB"
        
        flutterEngineManager.presentFlutterPaymentMethod(
            viewController: viewController,
            amount: amount,
            currency: currency,
            delegate: mockDelegate
        )
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
        let token: Token? = arguments["token"].decode(to: Token.self)
        let source: Source? = arguments["source"].decode(to: Source.self)
        
        mockChannelHandler.triggerSuccessResult(token: token, source: source)
        
        // Assert that delegate method is called
        XCTAssertTrue(mockDelegate.paymentMethodCompleted)
        XCTAssertNotNil(mockDelegate.tokenReceived)
        XCTAssertNotNil(mockDelegate.sourceReceived)
        XCTAssertEqual(mockDelegate.tokenReceived?.id, token?.id)
        XCTAssertEqual(mockDelegate.sourceReceived?.id, source?.id)
    }
    
    func testPresentFlutterPaymentMethodTokenOnly() {
        let viewController = UIViewController()
        let amount: Int64 = 10_000
        let currency = "THB"
        
        flutterEngineManager.presentFlutterPaymentMethod(
            viewController: viewController,
            amount: amount,
            currency: currency,
            delegate: mockDelegate
        )
        let arguments: [String: Any] = [
            "token": ["id": "token_id", "livemode": true, "used": false, "card": nil, "charge_status": "completed"],
            "source": []
        ]
        let token: Token? = arguments["token"].decode(to: Token.self)
        let source: Source? = arguments["source"].decode(to: Source.self)
        
        mockChannelHandler.triggerSuccessResult(token: token, source: source)
        
        // Assert that delegate method is called
        XCTAssertTrue(mockDelegate.paymentMethodCompleted)
        XCTAssertNotNil(mockDelegate.tokenReceived)
        XCTAssertNil(mockDelegate.sourceReceived)
        XCTAssertEqual(mockDelegate.tokenReceived?.id, token?.id)
    }
    
    func testPresentFlutterPaymentMethodSourceOnly() {
        let viewController = UIViewController()
        let amount: Int64 = 10_000
        let currency = "THB"
        
        flutterEngineManager.presentFlutterPaymentMethod(
            viewController: viewController,
            amount: amount,
            currency: currency,
            delegate: mockDelegate
        )
        let arguments: [String: Any] = [
            "token": [],
            "source": [
                "id": "src_test_5oxet335rx3xzdyn06g",
                "flow": "app_redirect",
                "amount": 1000000,
                "currency": "THB",
                "livemode": false,
                "type": "touch_n_go"
            ]
        ]
        let token: Token? = arguments["token"].decode(to: Token.self)
        let source: Source? = arguments["source"].decode(to: Source.self)
        mockChannelHandler.triggerSuccessResult(token: token, source: source)
        
        // Assert that delegate method is called
        XCTAssertTrue(mockDelegate.paymentMethodCompleted)
        XCTAssertNil(mockDelegate.tokenReceived)
        XCTAssertNotNil(mockDelegate.sourceReceived)
        XCTAssertEqual(mockDelegate.sourceReceived?.id, source?.id)
    }
    
    func testPresentFlutterPaymentMethodError() {
        let viewController = UIViewController()
        let amount: Int64 = 10_000
        let currency = "THB"
        
        flutterEngineManager.presentFlutterPaymentMethod(
            viewController: viewController,
            amount: amount,
            currency: currency,
            delegate: mockDelegate
        )
        let error = NSError(domain: "com.omise.omiseSDK",
                            code: 1002,
                            userInfo: [NSLocalizedDescriptionKey: "Arguments not found or invalid"])
        
        mockChannelHandler.triggerFailureResult(error: error)
        
        // Assert that delegate method is called
        XCTAssertTrue(mockDelegate.paymentMethodCompleted)
        XCTAssertNil(mockDelegate.tokenReceived)
        XCTAssertNil(mockDelegate.sourceReceived)
        XCTAssertNotNil(mockDelegate.errorReceived)
        XCTAssertEqual(mockDelegate.errorReceived?.localizedDescription, "Arguments not found or invalid")
    }
    
    func testHandlerCallbackSuccess() {
        func testPresentFlutterPaymentMethodSourceOnly() {
            let viewController = UIViewController()
            let amount: Int64 = 10_000
            let currency = "THB"
            
            flutterEngineManager.presentFlutterPaymentMethod(
                viewController: viewController,
                amount: amount,
                currency: currency,
                delegate: mockDelegate
            )
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
            let token: Token? = arguments["token"].decode(to: Token.self)
            let source: Source? = arguments["source"].decode(to: Source.self)
            
            mockChannelHandler.handleSelectPaymentMethodResult { callback in
                switch callback {
                case .success(let result):
                    XCTAssertNotNil(result.token)
                    XCTAssertEqual(result.token?.id, token?.id)
                    XCTAssertNotNil(result.source)
                    XCTAssertEqual(result.source?.id, source?.id)
                case .failure(let error):
                    XCTAssertNil(error)
                }
            }
            mockChannelHandler.triggerSuccessResult(token: token, source: source)
        }
    }
    
    func testHandlerCallbackError() {
        func testPresentFlutterPaymentMethodSourceOnly() {
            let viewController = UIViewController()
            let amount: Int64 = 10_000
            let currency = "THB"
            
            flutterEngineManager.presentFlutterPaymentMethod(
                viewController: viewController,
                amount: amount,
                currency: currency,
                delegate: mockDelegate
            )
            let nsError = NSError(
                domain: "com.omise.omiseSDK",
                code: 1002,
                userInfo: [NSLocalizedDescriptionKey: "Arguments not found or invalid"]
            )
            
            mockChannelHandler.handleSelectPaymentMethodResult { callback in
                switch callback {
                case .success(let result):
                    XCTAssertNil(result.token)
                    XCTAssertNil(result.source)
                case .failure(let error):
                    XCTAssertNotNil(error)
                    XCTAssertEqual(error.localizedDescription, nsError.localizedDescription)
                }
            }
            mockChannelHandler.triggerFailureResult(error: nsError)
        }
    }
}
