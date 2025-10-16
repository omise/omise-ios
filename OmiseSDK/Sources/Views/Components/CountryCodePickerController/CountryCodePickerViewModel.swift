import Foundation

// MARK: - Protocols
protocol CountryCodePickerViewModelInput {
    func viewDidLoad()
    func filterCountries(with searchText: String)
    func selectCountry(at index: Int)
    func cancel()
}

protocol CountryCodePickerViewModelOutput {
    var countries: [Country] { get }
    var selectedCountry: Country { get }
    var title: String { get }
    var selectedCountryIndex: Int? { get }
}

protocol CountryCodePickerViewModelProtocol: AnyObject {
    var input: CountryCodePickerViewModelInput { get }
    var output: CountryCodePickerViewModelOutput { get }
    
    var onCountrySelected: (Country) -> Void { get set }
    var onCancel: () -> Void { get set }
    var onDataUpdated: () -> Void { get set }
}

// MARK: - ViewModel Implementation
class CountryCodePickerViewModel: CountryCodePickerViewModelProtocol {
    var input: CountryCodePickerViewModelInput { self }
    var output: CountryCodePickerViewModelOutput { self }
    
    // MARK: - Private Properties
    private let allCountries = Country.sortedAll
    private var filteredCountries: [Country] = []
    private let initialSelectedCountry: Country
    private let isPresentedModally: Bool
    
    // MARK: - Callbacks
    var onCountrySelected: (Country) -> Void = { _ in /* Non-optional default empty implementation */ }
    var onCancel: () -> Void = { /* Non-optional default empty implementation */ }
    var onDataUpdated: () -> Void = { /* Non-optional default empty implementation */ }
    
    // MARK: - Initialization
    init(selectedCountry: Country) {
        self.initialSelectedCountry = selectedCountry
        self.isPresentedModally = false
        self.filteredCountries = allCountries
    }
}

// MARK: - Input
extension CountryCodePickerViewModel: CountryCodePickerViewModelInput {
    func viewDidLoad() {
        filteredCountries = allCountries
        onDataUpdated()
    }
    
    func filterCountries(with searchText: String) {
        if searchText.isEmpty {
            filteredCountries = allCountries
        } else {
            filteredCountries = allCountries.filter { country in
                let searchLower = searchText.lowercased()
                return country.name.lowercased().contains(searchLower) ||
                country.code.lowercased().contains(searchLower) ||
                country.phonePrefix.contains(searchText)
            }
        }
        onDataUpdated()
    }
    
    func selectCountry(at index: Int) {
        guard index >= 0 && index < filteredCountries.count else { return }
        let selectedCountry = filteredCountries[index]
        onCountrySelected(selectedCountry)
    }
    
    func cancel() {
        onCancel()
    }
}

// MARK: - Output
extension CountryCodePickerViewModel: CountryCodePickerViewModelOutput {
    var countries: [Country] {
        return filteredCountries
    }
    
    var selectedCountry: Country {
        return initialSelectedCountry
    }
    
    var title: String {
        return "CreditCard.search.country.code.title".localized()
    }
    
    var selectedCountryIndex: Int? {
        return filteredCountries.firstIndex { $0.code == initialSelectedCountry.code }
    }
}
