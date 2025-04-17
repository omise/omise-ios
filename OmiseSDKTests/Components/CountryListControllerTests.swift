import XCTest
@testable import OmiseSDK
import UIKit

final class CountryListControllerTests: XCTestCase {
    // MARK: - Properties
    var mockVM: MockVM!
    var sut: CountryListController!
    
    private var tableView: UITableView {
        guard let tv = sut.view.subviews.compactMap({ $0 as? UITableView }).first else {
            fatalError("Expected a UITableView in \(sut.view.subviews)")
        }
        return tv
    }
    
    override func setUp() {
        super.setUp()
        mockVM = MockVM()
        sut = CountryListController(viewModel: mockVM)
        sut.loadViewIfNeeded()
        sut.preferredPrimaryColor = .systemBlue
        sut.preferredSecondaryColor = .systemRed
        sut.viewWillAppear(false)
    }
    
    override func tearDown() {
        sut = nil
        mockVM = nil
        super.tearDown()
    }
    
    func testNumberOfRows_matchesViewModelCountriesCount() {
        XCTAssertEqual(tableView.numberOfRows(inSection: 0),
                       mockVM.countries.count)
    }
    
    func testCellForRow_displaysCountryNameAndAccessory() {
        mockVM.selectedCountry = nil
        let cell0 = sut.tableView(tableView, cellForRowAt: [0, 0])
        XCTAssertEqual(cell0.textLabel?.text, "A")
        XCTAssertEqual(cell0.accessoryType, .none)
        
        mockVM.selectedCountry = mockVM.countries[1]
        let cell1 = sut.tableView(tableView, cellForRowAt: [0, 1])
        XCTAssertEqual(cell1.textLabel?.text, "B")
        XCTAssertEqual(cell1.accessoryType, .checkmark)
    }
    
    func testDidSelectRow_updatesViewModelSelectedCountry() {
        XCTAssertNil(mockVM.selectedCountry)
        sut.tableView(tableView, didSelectRowAt: [0, 1])
        XCTAssertEqual(mockVM.selectedCountry, mockVM.countries[1])
    }
}

// MARK: - Mock ViewModel
class MockVM: CountryListViewModelProtocol {
    var countries: [Country] = [.init(name: "A", code: "A"), .init(name: "B", code: "B")]
    var selectedCountry: Country?
    var onSelectCountry: (Country) -> Void = { _ in /* Non-optional default empty implementation */ }
}
