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

    func testFieldValidation() {
//        let vc = NewAtomeFormViewController()
//        vc.set(viewModel: ViewModel())

        let validCases = TestCaseValueGenerator.validCases(NewAtomeFormViewContext.generateMockup)
//        for case in validCases {
//            vc.viewM
//            XCTAssertNil(view)
//        }
        // test all valid

        // test all invalid
        let invalidCases = TestCaseValueGenerator.invalidCases(NewAtomeFormViewContext.generateMockup)

        // test field by field
        let mostInvalidCases = TestCaseValueGenerator.mostInvalidCases(NewAtomeFormViewContext.generateMockup)
//
//        print("--------")
//        print("--- validCases ---")
//        print(validCases)
//        print("--- invalidCases ---")
//        print(invalidCases)
//        print("--- mostInvalidCases ---")
//        print(mostInvalidCases)
//        print("--------")
//        XCTAssertTrue(true)
    }

    func testProcessing() {
        // test processing
        XCTAssert(true)
    }
}
