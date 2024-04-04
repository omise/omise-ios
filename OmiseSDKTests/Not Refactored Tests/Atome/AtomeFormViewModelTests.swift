import XCTest
import OmiseUnitTestKit
@testable import OmiseSDK

class AtomePaymentFormViewModelTests: XCTestCase {
    typealias ViewModel = AtomePaymentFormViewModelMockup

    let validCases = TestCaseValueGenerator.validCases(AtomePaymentFormViewContext.generateMockup)
    let invalidCases = TestCaseValueGenerator.invalidCases(AtomePaymentFormViewContext.generateMockup)
    let mostInvalidCases = TestCaseValueGenerator.mostInvalidCases(AtomePaymentFormViewContext.generateMockup)

}
