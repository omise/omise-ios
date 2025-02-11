//
//  MockFlutterChannelHandler.swift
//  dev
//
//  Created by Tyler on 11/2/2568 BE.
//  Copyright © 2568 BE Omise. All rights reserved.
//

import Flutter
@testable import OmiseSDK

// Mock implementation of FlutterChannelHandler for testing purposes
class MockFlutterChannelHandler: FlutterChannelHandler {
    // Create a variable to store the mock result to verify later
    var mockCompletion: FlutterPaymentMethodCallback?
    
    // Stub for the method handleSelectPaymentMethodResult
    func handleSelectPaymentMethodResult(completion: @escaping FlutterPaymentMethodCallback) {
        // Store the completion handler for later use in tests
        mockCompletion = completion
    }
    
    // Method to trigger the completion handler with a success result
    func triggerSuccessResult(token: Token?, source: Source?) {
        // Call the completion handler with a success result
        let result = FlutterPaymentMethodResult(token: token, source: source)
        mockCompletion?(.success(result))
    }
    
    // Method to trigger the completion handler with a failure result
    func triggerFailureResult(error: Error) {
        // Call the completion handler with a failure result
        mockCompletion?(.failure(error))
    }
}
