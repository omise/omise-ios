import XCTest
import OmiseSDK

class CardExpiryDatePickerTests: XCTestCase {
    
    let currentMonth = Calendar.creditCardInformationCalendar.component(.month, from: Date())
    let currentYear = Calendar.creditCardInformationCalendar.component(.year, from: Date())

    var datePicker: CardExpiryDatePicker!
    
    override func setUp() {
        super.setUp()
        datePicker = CardExpiryDatePicker(frame: .zero)
    }
    
    func testInititalValues() throws {
        XCTAssertEqual(datePicker.month, currentMonth)
        XCTAssertEqual(datePicker.year, currentYear)
        
        XCTAssertEqual(datePicker.selectedRow(inComponent: 0), currentMonth - 1)
        XCTAssertEqual(datePicker.selectedRow(inComponent: 1), 0)
    }
    
    func testSelectMonth() {
        let expectation = self.expectation(description: "month changes after row is selected")
        let expectedMonth = 8
        
        datePicker.onDateSelected = { month, _ in
            XCTAssertEqual(month, expectedMonth)
            expectation.fulfill()
        }
        
        datePicker.selectRow(expectedMonth - 1, inComponent: 0, animated: false)
        datePicker.pickerView(datePicker, didSelectRow: expectedMonth - 1, inComponent: 0)
        
        XCTAssertEqual(datePicker.month, expectedMonth)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSelectYear() {
        let expectation = self.expectation(description: "year changes after row is selected")
        let expectedYear = currentYear + 4
        
        datePicker.onDateSelected = { _, year in
            XCTAssertEqual(year, expectedYear)
            expectation.fulfill()
        }
        
        datePicker.selectRow(4, inComponent: 1, animated: false)
        datePicker.pickerView(datePicker, didSelectRow: 4, inComponent: 1)
        
        XCTAssertEqual(datePicker.year, expectedYear)
        
        waitForExpectations(timeout: 1, handler: nil)
    }

}
