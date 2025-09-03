import XCTest
import UIKit
@testable import OmiseSDK

class ClosureBarButtonItemTests: XCTestCase {
    
    func testImageInitializer_callsHandler_andConfiguresTargetAction() {
        let dummyImage = UIImage()
        let expect = expectation(description: "image handler called")
        var receivedItem: UIBarButtonItem?
        
        let item = ClosureBarButtonItem(image: dummyImage, style: .plain) { sender in
            receivedItem = sender
            expect.fulfill()
        }
        
        // target should be the item itself
        XCTAssertIdentical(item.target, item)
        // action should be our selector
        XCTAssertEqual(item.action, #selector(ClosureBarButtonItem.barButtonItemPressed(sender:)))
        
        // Simulate tap
        item.barButtonItemPressed(sender: item)
        
        waitForExpectations(timeout: 0.1)
        XCTAssertIdentical(receivedItem, item)
    }
    
    func testTitleInitializer_callsHandler_andConfiguresTargetAction() {
        let expect = expectation(description: "title handler called")
        var receivedItem: UIBarButtonItem?
        
        let item = ClosureBarButtonItem(title: "Tap", style: .done) { sender in
            receivedItem = sender
            expect.fulfill()
        }
        
        XCTAssertIdentical(item.target, item)
        XCTAssertEqual(item.action, #selector(ClosureBarButtonItem.barButtonItemPressed(sender:)))
        
        item.barButtonItemPressed(sender: item)
        
        waitForExpectations(timeout: 0.1)
        XCTAssertIdentical(receivedItem, item)
    }
    
    func testSystemItemInitializer_callsHandler_andConfiguresTargetAction() {
        let expect = expectation(description: "systemItem handler called")
        var receivedItem: UIBarButtonItem?
        
        let item = ClosureBarButtonItem(barButtonSystemItem: .add) { sender in
            receivedItem = sender
            expect.fulfill()
        }
        
        XCTAssertIdentical(item.target, item)
        XCTAssertEqual(item.action, #selector(ClosureBarButtonItem.barButtonItemPressed(sender:)))
        
        item.barButtonItemPressed(sender: item)
        
        waitForExpectations(timeout: 0.1)
        XCTAssertIdentical(receivedItem, item)
    }
}
