import XCTest
@testable import OmiseSDK
import UIKit

// swiftlint:disable file_length
// MARK: - Mock ViewModel
class MockCountryCodePickerViewModel: CountryCodePickerViewModelProtocol {
    var input: CountryCodePickerViewModelInput { self }
    var output: CountryCodePickerViewModelOutput { self }
    
    // MARK: - Callbacks
    var onCountrySelected: (Country) -> Void = { _ in }
    var onCancel: () -> Void = {}
    var onDataUpdated: () -> Void = {}
    
    // MARK: - Test Properties
    var viewDidLoadCalled = false
    var filterCountriesCalled = false
    var selectCountryCalled = false
    var cancelCalled = false
    var lastSearchText = ""
    var lastSelectedIndex = -1
    
    // MARK: - Mock Data
    var mockCountries: [Country] = [
        Country(name: "Thailand", code: "TH"),
        Country(name: "United States", code: "US"),
        Country(name: "Japan", code: "JP")
    ]
    var mockSelectedCountry = Country(name: "Thailand", code: "TH")
    var mockTitle = "Test Title"
}

// MARK: - Helpers
private func extractTableView(from controller: CountryCodePickerController) -> UITableView? {
    return controller.view.subviews.compactMap { $0 as? UITableView }.first
}

final class SpyCountryCodePickerController: CountryCodePickerController {
    private(set) var dismissCalled = false

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        dismissCalled = true
        completion?()
    }
}

final class PoppingSpyNavigationController: UINavigationController {
    private(set) var popCallCount = 0

    override func popViewController(animated: Bool) -> UIViewController? {
        popCallCount += 1
        return super.popViewController(animated: animated)
    }
}

// MARK: - Mock Input
extension MockCountryCodePickerViewModel: CountryCodePickerViewModelInput {
    func viewDidLoad() {
        viewDidLoadCalled = true
        onDataUpdated()
    }
    
    func filterCountries(with searchText: String) {
        filterCountriesCalled = true
        lastSearchText = searchText
        
        // Simulate filtering
        let allCountries = [
            Country(name: "Thailand", code: "TH"),
            Country(name: "United States", code: "US"),
            Country(name: "Japan", code: "JP")
        ]
        
        if searchText.isEmpty {
            mockCountries = allCountries
        } else {
            mockCountries = allCountries.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        onDataUpdated()
    }
    
    func selectCountry(at index: Int) {
        selectCountryCalled = true
        lastSelectedIndex = index
        
        if index >= 0 && index < mockCountries.count {
            let selectedCountry = mockCountries[index]
            onCountrySelected(selectedCountry)
        }
    }
    
    func cancel() {
        cancelCalled = true
        onCancel()
    }
}

// MARK: - Mock Output
extension MockCountryCodePickerViewModel: CountryCodePickerViewModelOutput {
    var countries: [Country] {
        return mockCountries
    }
    
    var selectedCountry: Country {
        return mockSelectedCountry
    }
    
    var title: String {
        return mockTitle
    }
    
    var selectedCountryIndex: Int? {
        return mockCountries.firstIndex { $0.code == mockSelectedCountry.code }
    }
}

// MARK: - Tests
class CountryCodePickerControllerTest: XCTestCase {
    
    var sut: SpyCountryCodePickerController!
    var mockViewModel: MockCountryCodePickerViewModel!
    
    override func setUp() {
        super.setUp()
        mockViewModel = MockCountryCodePickerViewModel()
        sut = SpyCountryCodePickerController(viewModel: mockViewModel)
    }
    
    override func tearDown() {
        sut = nil
        mockViewModel = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    func testInit_SetsViewModelCorrectly() {
        // Then
        XCTAssertNotNil(sut)
        XCTAssertNotNil(mockViewModel.onDataUpdated)
        XCTAssertNotNil(mockViewModel.onCancel)
    }
    
    func testConvenienceInit_CreatesViewModelAndCallbacks() {
        // Given
        let selectedCountry = Country(name: "Test", code: "TE")
        
        // When
        let controller = CountryCodePickerController(selectedCountry: selectedCountry) { _ in }
        
        // Then
        XCTAssertNotNil(controller)
    }
    
    // MARK: - Lifecycle Tests
    func testViewDidLoad_CallsViewModelViewDidLoad() {
        // When
        sut.loadViewIfNeeded()
        
        // Then
        XCTAssertTrue(mockViewModel.viewDidLoadCalled)
    }
    
    func testViewDidLoad_SetsUpUI() {
        // When
        sut.loadViewIfNeeded()
        
        // Then
        XCTAssertEqual(sut.title, mockViewModel.mockTitle)
        XCTAssertEqual(sut.view.backgroundColor, .systemBackground)
    }
    
    // MARK: - TableView Tests
    func testNumberOfRows_ReturnsCountriesCount() {
        // Given
        sut.loadViewIfNeeded()
        let tableView = UITableView()
        
        // When
        let numberOfRows = sut.tableView(tableView, numberOfRowsInSection: 0)
        
        // Then
        XCTAssertEqual(numberOfRows, mockViewModel.mockCountries.count)
    }
    
    func testCellForRowAt_ConfiguresCell() {
        // Given
        sut.loadViewIfNeeded()
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CountryCodeCell")
        let indexPath = IndexPath(row: 0, section: 0)
        
        // When
        let cell = sut.tableView(tableView, cellForRowAt: indexPath)
        let country = mockViewModel.mockCountries[0]
        
        // Then
        XCTAssertEqual(cell.textLabel?.text, "\(country.name) (\(country.phonePrefix))")
        XCTAssertEqual(cell.accessoryType, .checkmark) // First country matches selected
    }
    
    func testSelectedCountryIndex_ReturnsCorrectIndex() {
        // When
        sut.loadViewIfNeeded()
        
        // Then
        XCTAssertEqual(mockViewModel.selectedCountryIndex, 0) // Thailand is at index 0 in mock data
    }
    
    func testDidSelectRowAt_CallsViewModelSelectCountry() {
        // Given
        sut.loadViewIfNeeded()
        let tableView = UITableView()
        let indexPath = IndexPath(row: 1, section: 0)
        
        // When
        sut.tableView(tableView, didSelectRowAt: indexPath)
        
        // Then
        XCTAssertTrue(mockViewModel.selectCountryCalled)
        XCTAssertEqual(mockViewModel.lastSelectedIndex, 1)
    }
    
    // MARK: - Search Tests
    func testUpdateSearchResults_CallsViewModelFilterCountries() {
        // Given
        sut.loadViewIfNeeded()
        let searchController = UISearchController()
        searchController.searchBar.text = "thai"
        
        // When
        sut.updateSearchResults(for: searchController)
        
        // Then
        XCTAssertTrue(mockViewModel.filterCountriesCalled)
        XCTAssertEqual(mockViewModel.lastSearchText, "thai")
    }
    
    func testUpdateSearchResults_WithEmptyText_CallsViewModelWithEmptyString() {
        // Given
        sut.loadViewIfNeeded()
        let searchController = UISearchController()
        searchController.searchBar.text = ""
        
        // When
        sut.updateSearchResults(for: searchController)
        
        // Then
        XCTAssertTrue(mockViewModel.filterCountriesCalled)
        XCTAssertEqual(mockViewModel.lastSearchText, "")
    }
    
    // MARK: - ViewModel Binding Tests
    func testOnDataUpdated_ReloadsTableView() {
        sut.loadViewIfNeeded()
        mockViewModel.mockSelectedCountry = mockViewModel.mockCountries[2]

        mockViewModel.onDataUpdated()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))

        guard let tableView = extractTableView(from: sut) else {
            return XCTFail("Expected embedded table view")
        }
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), mockViewModel.mockCountries.count)
        let visibleRows = tableView.indexPathsForVisibleRows ?? []
        XCTAssertTrue(visibleRows.contains(IndexPath(row: 2, section: 0)))
    }

    func testHandleCancelPopsWhenInNavigationStack() {
        sut.loadViewIfNeeded()
        let navigation = PoppingSpyNavigationController(rootViewController: UIViewController())
        navigation.pushViewController(sut, animated: false)
        mockViewModel.onCancel()

        XCTAssertEqual(navigation.popCallCount, 1)
        XCTAssertFalse(sut.dismissCalled)
    }

    func testHandleCancelDismissesWhenNoNavigation() {
        sut.loadViewIfNeeded()
        mockViewModel.onCancel()

        XCTAssertTrue(sut.dismissCalled)
    }

    func testDidSelectRow_pushesAndCancelsThroughNavigation() {
        sut.loadViewIfNeeded()
        guard let tableView = extractTableView(from: sut) else {
            return XCTFail("Expected embedded table view")
        }
        let navigation = PoppingSpyNavigationController(rootViewController: UIViewController())
        navigation.pushViewController(sut, animated: false)
        mockViewModel.selectCountryCalled = false

        sut.tableView(tableView, didSelectRowAt: IndexPath(row: 1, section: 0))

        XCTAssertTrue(mockViewModel.selectCountryCalled)
        XCTAssertEqual(navigation.popCallCount, 1)
    }
}

// MARK: - ViewModel Tests
class CountryCodePickerViewModelTest: XCTestCase {
    
    var sut: CountryCodePickerViewModel!
    let testCountry = Country(name: "Thailand", code: "TH")
    
    override func setUp() {
        super.setUp()
        sut = CountryCodePickerViewModel(selectedCountry: testCountry)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    func testInit_SetsSelectedCountry() {
        // Then
        XCTAssertEqual(sut.output.selectedCountry.code, testCountry.code)
        XCTAssertEqual(sut.output.selectedCountry.name, testCountry.name)
    }
    
    // MARK: - Output Tests
    func testOutput_Title() {
        // Then
        XCTAssertEqual(sut.output.title, "Select Country Code")
    }
    
    func testOutput_Countries_InitiallyEmpty() {
        // Then
        XCTAssertGreaterThan(sut.output.countries.count, 0) // Should have all countries initially
    }
    
    // MARK: - Input Tests
    func testViewDidLoad_CallsOnDataUpdated() {
        // Given
        var dataUpdatedCalled = false
        sut.onDataUpdated = { dataUpdatedCalled = true }
        
        // When
        sut.input.viewDidLoad()
        
        // Then
        XCTAssertTrue(dataUpdatedCalled)
    }
    
    func testViewDidLoad_ProvideSelectedCountryIndex() {
        // When
        sut.input.viewDidLoad()
        
        // Then
        XCTAssertNotNil(sut.output.selectedCountryIndex) // Should provide index of selected country
        if let index = sut.output.selectedCountryIndex {
            XCTAssertEqual(sut.output.countries[index].code, testCountry.code)
        }
    }
    
    func testFilterCountries_WithEmptyString_ShowsAllCountries() {
        // Given
        let initialCount = sut.output.countries.count
        
        // When
        sut.input.filterCountries(with: "")
        
        // Then
        XCTAssertEqual(sut.output.countries.count, initialCount)
    }
    
    func testFilterCountries_WithSearchText_FiltersCountries() {
        // Given
        var dataUpdatedCalled = false
        sut.onDataUpdated = { dataUpdatedCalled = true }
        
        // When
        sut.input.filterCountries(with: "Thailand")
        
        // Then
        XCTAssertTrue(dataUpdatedCalled)
        XCTAssertTrue(sut.output.countries.contains { $0.name.contains("Thailand") })
    }
    
    func testSelectedCountryIndex_ReturnsCorrectIndex() {
        // When
        sut.input.viewDidLoad()
        
        // Then
        if let index = sut.output.selectedCountryIndex {
            let countryAtIndex = sut.output.countries[index]
            XCTAssertEqual(countryAtIndex.code, testCountry.code)
        } else {
            XCTFail("selectedCountryIndex should not be nil")
        }
    }
    
    func testSelectCountry_ValidIndex_CallsOnCountrySelected() {
        // Given
        var selectedCountry: Country?
        sut.onCountrySelected = { country in selectedCountry = country }
        
        // When
        sut.input.selectCountry(at: 0)
        
        // Then
        XCTAssertNotNil(selectedCountry)
    }
    
    func testSelectCountry_InvalidIndex_DoesNotCallCallback() {
        // Given
        var selectedCountry: Country?
        sut.onCountrySelected = { country in selectedCountry = country }
        
        // When
        sut.input.selectCountry(at: -1)
        
        // Then
        XCTAssertNil(selectedCountry)
    }
    
    func testCancel_CallsOnCancel() {
        // Given
        var cancelCalled = false
        sut.onCancel = { cancelCalled = true }
        
        // When
        sut.input.cancel()
        
        // Then
        XCTAssertTrue(cancelCalled)
    }
}
// swiftlint:enable file_length
