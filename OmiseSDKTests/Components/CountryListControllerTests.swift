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

    func testSettingViewModelBeforeViewLoadsDefersBinding() {
        let controller = CountryListController()
        XCTAssertFalse(controller.isViewLoaded)
        controller.viewModel = mockVM
        XCTAssertFalse(controller.isViewLoaded)
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
    
    func testMockVM_filterCountries_worksCorrectly() {
        // Initially should have all countries
        XCTAssertEqual(mockVM.filteredCountries.count, 2)
        
        // Filter by "A"
        mockVM.filterCountries(with: "A")
        XCTAssertEqual(mockVM.filteredCountries.count, 1)
        XCTAssertEqual(mockVM.filteredCountries.first?.name, "A")
        
        // Clear filter
        mockVM.filterCountries(with: "")
        XCTAssertEqual(mockVM.filteredCountries.count, 2)
    }

    func testPreferredColorsBeforeAndAfterViewLoad() {
        let controller = CountryListController(viewModel: mockVM)
        controller.preferredPrimaryColor = .red
        controller.preferredSecondaryColor = .blue

        controller.loadViewIfNeeded()
        controller.preferredPrimaryColor = .green
        controller.preferredSecondaryColor = .yellow

        XCTAssertNotNil(controller.view)
    }

    func testViewWillDisappearResetsSearchAndFilters() {
        sut.viewDidLoad()
        mockVM.filterCountries(with: "A")
        XCTAssertEqual(mockVM.filteredCountries.count, 1)

        sut.navigationItem.searchController?.searchBar.text = "A"
        sut.viewWillDisappear(false)

        XCTAssertEqual(sut.navigationItem.searchController?.searchBar.text, "")
        XCTAssertEqual(mockVM.filteredCountries.count, 2)
    }

    func testViewDidAppearScrollsToSelectedCountry() {
        mockVM.selectedCountry = mockVM.countries[1]
        sut.viewDidAppear(false)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))

        XCTAssertEqual(tableView.indexPathsForVisibleRows?.first?.row, 1)
    }

    func testUpdateSearchResultsTriggersFilterAndScroll() {
        sut.viewDidLoad()
        guard let searchController = sut.navigationItem.searchController else {
            return XCTFail("Expected search controller")
        }
        mockVM.selectedCountry = mockVM.countries[0]
        mockVM.filterCountriesCalled = false
        searchController.searchBar.text = "B"
        sut.updateSearchResults(for: searchController)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))

        XCTAssertTrue(mockVM.filterCountriesCalled)
    }
}

// MARK: - Mock ViewModel
class MockVM: CountryListViewModelProtocol {
    var countries: [Country] = [.init(name: "A", code: "A"), .init(name: "B", code: "B")]
    var filteredCountries: [Country] = []
    var selectedCountry: Country?
    var onSelectCountry: (Country) -> Void = { _ in /* Non-optional default empty implementation */ }
    var filterCountriesCalled = false
    
    init() {
        filteredCountries = countries
    }
    
    func filterCountries(with searchText: String) {
        filterCountriesCalled = true
        if searchText.isEmpty {
            filteredCountries = countries
        } else {
            filteredCountries = countries.filter { country in
                country.name.lowercased().contains(searchText.lowercased()) ||
                country.code.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    func updateSelectedCountry(at index: Int) {
        guard index >= 0 && index < filteredCountries.count else { return }
        selectedCountry = filteredCountries[index]
        onSelectCountry(selectedCountry ?? .init(name: "Australia", code: "AU"))
    }
}
