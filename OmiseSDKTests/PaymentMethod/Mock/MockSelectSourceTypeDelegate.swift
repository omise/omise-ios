import Foundation
@testable import OmiseSDK

class MockSelectSourceTypeDelegate: SelectSourceTypeDelegate {
    var didSelectCalled = false
    var selectedSourceType: SourceType?
    var completionWasCalled = false
    
    func didSelectSourceType(_ sourceType: SourceType, completion: @escaping () -> Void) {
        didSelectCalled = true
        selectedSourceType = sourceType
        completion()
        completionWasCalled = true
    }
}
