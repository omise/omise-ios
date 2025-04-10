import XCTest
import UIKit

@testable import OmiseSDK

class CCVInfoControllerOnCloseTests: XCTestCase {
    
    var sut: CCVInfoController!
    
    override func setUp() {
        super.setUp()
        sut = CCVInfoController(nibName: nil, bundle: .omiseSDK)
        sut.loadViewIfNeeded()
        sut.preferredCardBrand = .visa
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testTapGesture_CallsOnCloseTapped() {
        let expectation = self.expectation(description: "onCloseTapped closure should be called")
        
        sut.onCloseTapped = {
            expectation.fulfill()
        }
        sut.onCloseTapped()
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
