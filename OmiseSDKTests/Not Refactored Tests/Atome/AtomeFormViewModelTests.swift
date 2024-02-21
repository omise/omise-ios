//
//  AtomePaymentViewModelTests.swift
//  OmiseSDKTests
//
//  Created by Andrei Solovev on 23/5/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import XCTest
import OmiseUnitTestKit
@testable import OmiseSDK

class AtomePaymentViewModelTests: XCTestCase {
    typealias ViewModel = AtomePaymentViewModelMockup

    let validCases = TestCaseValueGenerator.validCases(AtomePaymentViewContext.generateMockup)
    let invalidCases = TestCaseValueGenerator.invalidCases(AtomePaymentViewContext.generateMockup)
    let mostInvalidCases = TestCaseValueGenerator.mostInvalidCases(AtomePaymentViewContext.generateMockup)

}
