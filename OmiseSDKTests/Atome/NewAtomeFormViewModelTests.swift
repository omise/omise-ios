//
//  NewAtomeFormViewModelTests.swift
//  OmiseSDKTests
//
//  Created by Andrei Solovev on 23/5/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import XCTest
import OmiseTestSDK
@testable import OmiseSDK

class NewAtomeFormViewModelTests: XCTestCase {
    typealias ViewModel = NewAtomeFormViewModelMockup

    let validCases = TestCaseValueGenerator.validCases(NewAtomeFormViewContext.generateMockup)
    let invalidCases = TestCaseValueGenerator.invalidCases(NewAtomeFormViewContext.generateMockup)
    let mostInvalidCases = TestCaseValueGenerator.mostInvalidCases(NewAtomeFormViewContext.generateMockup)

}
