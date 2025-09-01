import Foundation
import OmiseUnitTestKit
#if OMISE_SDK_UNIT_TESTING
@testable import OmiseSDK
#endif

class CountryListViewModelMockup: CountryListViewModelProtocol {
    var countries: [Country] = [Country(name: "Thailand", code: "TH"), Country(name: "France", code: "FR")]
    private var _filteredCountries: [Country] = []
    var filteredCountries: [Country] {
        return _filteredCountries.isEmpty ? countries : _filteredCountries
    }
    lazy var selectedCountry: Country? = countries.first
    var onSelectCountry: (Country) -> Void = { _ in }
    
    func filterCountries(with searchText: String) {
        if searchText.isEmpty {
            _filteredCountries = []
        } else {
            _filteredCountries = countries.filter { country in
                let searchLower = searchText.lowercased()
                return country.name.lowercased().contains(searchLower) ||
                       country.code.lowercased().contains(searchLower)
            }
        }
    }
    
    func updateSelectedCountry(at index: Int) {
        guard index >= 0 && index < filteredCountries.count else { return }
        selectedCountry = filteredCountries[index]
    }
}
