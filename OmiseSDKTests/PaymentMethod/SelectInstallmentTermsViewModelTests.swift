import XCTest
import UIKit
@testable import OmiseSDK

class SelectInstallmentTermsViewModelTests: XCTestCase {
    
    var mockDelegate: MockSelectSourcePaymentDelegate!
    var sut: SelectInstallmentTermsViewModel!
    
    /// A dictionary mapping each installment SourceType to its expected available terms.
    let expectedTermsDict: [SourceType: [Int]] = [
        .installmentBAY: [3, 4, 6, 10],
        .installmentBBL: [4, 6, 8, 10],
        .installmentFirstChoice: [3, 4, 6, 10, 12, 18, 24, 36],
        .installmentMBB: [6, 12, 18, 24],
        .installmentKTC: [3, 4, 5, 6, 7, 8, 9, 10],
        .installmentKBank: [3, 4, 6, 10],
        .installmentSCB: [3, 4, 6, 9, 10],
        .installmentTTB: [3, 4, 6, 10, 12],
        .installmentUOB: [3, 4, 6, 10],
        .installmentWhiteLabelUOB: [3, 4, 6, 10],
        .installmentWhiteLabelBAY: [3, 4, 6, 9, 10],
        .installmentWhiteLabelFirstChoice: [3, 4, 6, 9, 10, 12, 18, 24, 36],
        .installmentWhiteLabelBBL: [4, 6, 8, 10],
        .installmentWhiteLabelKTC: [3, 4, 5, 6, 7, 8, 9, 10],
        .installmentWhiteLabelSCB: [3, 4, 6, 9, 10],
        .installmentWhiteLabelKBank: [3, 6, 10],
        .installmentWhiteLabelTTB: [4, 6, 10],
        .alipay: []
    ]
    
    override func setUp() {
        super.setUp()
        mockDelegate = MockSelectSourcePaymentDelegate()
    }
    
    override func tearDown() {
        mockDelegate = nil
        sut = nil
        super.tearDown()
    }
    
    func test_viewNavigationTitle_returnsSourceLocalizedTitle() {
        sut = SelectInstallmentTermsViewModel(sourceType: SourceType.installmentBAY, delegate: mockDelegate)
        XCTAssertEqual(sut.viewNavigationTitle, SourceType.installmentBAY.localizedTitle)
    }
    
    func test_allPaymentTerms_viewContexts_and_delegate_calls() {
        for (source, expectedTerms) in expectedTermsDict {
            sut = SelectInstallmentTermsViewModel(sourceType: source, delegate: mockDelegate)
            
            // Verify the number of view contexts equals the count of available terms.
            XCTAssertEqual(sut.numberOfViewContexts, expectedTerms.count)
            
            // Loop through each expected term.
            for (index, term) in expectedTerms.enumerated() {
                // --- Test viewContext(for:)
                guard let context = sut.viewContext(at: index) else {
                    XCTFail("Context for \(source.rawValue) at index \(index) is nil")
                    continue
                }
                let numberOfTermsTitleFormat = localized("installments.number-of-terms.text", "%d months")
                let expectedTitle = String.localizedStringWithFormat(numberOfTermsTitleFormat, term)
                XCTAssertEqual(context.title, expectedTitle)
                XCTAssertNil(context.icon)
                XCTAssertNotNil(context.accessoryIcon)
                
                // --- Test viewDidSelectCell(_:)
                mockDelegate.reset()
                let selectExpectation = expectation(description: "Delegate completion called for \(source.rawValue) index \(index)")
                sut.viewDidSelectCell(at: index) {
                    selectExpectation.fulfill()
                }
                XCTAssertTrue(mockDelegate.didSelectCalled)
                wait(for: [selectExpectation], timeout: 1.0)
                
                let expectedAnimation = !source.isWhiteLabelInstallment
                XCTAssertEqual(sut.viewShouldAnimateSelectedCell(at: index), expectedAnimation)
            }
        }
    }
    
    func test_viewContext_returnsNil_forInvalidIndex_forAllInstallmentTypes() {
        for (source, _) in expectedTermsDict {
            sut = SelectInstallmentTermsViewModel(sourceType: source, delegate: mockDelegate)
            let invalidIndex = sut.numberOfViewContexts
            XCTAssertNil(sut.viewContext(at: invalidIndex))
        }
    }
    
    func test_viewOnDataReloadHandler_isCalledImmediately_forAllInstallmentTypes() {
        for (source, _) in expectedTermsDict {
            sut = SelectInstallmentTermsViewModel(sourceType: source, delegate: mockDelegate)
            var callCount = 0
            sut.viewOnDataReloadHandler {
                callCount += 1
            }
            XCTAssertEqual(callCount, 1)
        }
    }
}
