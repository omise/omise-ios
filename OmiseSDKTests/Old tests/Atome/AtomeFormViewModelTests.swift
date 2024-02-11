//
//  AtomeFormViewModelTests.swift
//  OmiseSDKTests
//
//  Created by Andrei Solovev on 23/5/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import XCTest
import OmiseUnitTestKit
@testable import OmiseSDK

class AtomeFormViewModelTests: XCTestCase {
    typealias ViewModel = AtomeFormViewModelMockup

    let validCases = TestCaseValueGenerator.validCases(AtomeFormViewContext.generateMockup)
    let invalidCases = TestCaseValueGenerator.invalidCases(AtomeFormViewContext.generateMockup)
    let mostInvalidCases = TestCaseValueGenerator.mostInvalidCases(AtomeFormViewContext.generateMockup)

}
