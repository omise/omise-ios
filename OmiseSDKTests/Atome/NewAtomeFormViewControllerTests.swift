//
//  NewAtomeFormViewControllerTests.swift
//  OmiseSDKTests
//
//  Created by Andrei Solovev on 22/5/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import XCTest
import OmiseTestSDK
@testable import OmiseSDK

class NewAtomeFormViewControllerTests: XCTestCase {
    typealias ViewModel = NewAtomeFormViewModelMockup

    func testBindTitles() {
        let viewModel = ViewModel()
        for field in NewAtomeFormViewContext.Field.allCases {
            viewModel.titles[field] = "title: " + field.rawValue
        }

        let vc = NewAtomeFormViewController()
        vc.set(viewModel: viewModel)

        for field in ViewModel.Field.allCases {
            XCTAssertEqual(vc.input(for: field).title, "title: " + field.rawValue)
        }
    }

    func testBindErrors() {
        let viewModel = ViewModel()
        for field in NewAtomeFormViewContext.Field.allCases {
            viewModel.errors[field] = "error: " + field.rawValue
        }

        let vc = NewAtomeFormViewController()
        vc.set(viewModel: viewModel)
        vc.validate()
        for field in ViewModel.Field.allCases {
            XCTAssertEqual(vc.input(for: field).error, "error: " + field.rawValue)
        }
    }
    
    func testFieldValidation() {
        let vc = NewAtomeFormViewController()
        vc.set(viewModel: ViewModel())
//
        let validCases = TestCaseValueGenerator.validCases(NewAtomeFormViewContext.generateMockup)
//        for case in validCases {
//            vc.viewM
//            XCTAssertNil(view)
//        }
//        // test all valid
//
//        // test all invalid
//        let invalidCases = TestCaseValueGenerator.invalidCases(NewAtomeFormViewContext.generateMockup)
//
//        // test field by field
//        let mostInvalidCases = TestCaseValueGenerator.mostInvalidCases(NewAtomeFormViewContext.generateMockup)
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
        XCTAssertTrue(true)
    }
}
