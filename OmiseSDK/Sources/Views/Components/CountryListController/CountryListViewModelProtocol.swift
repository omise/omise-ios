import Foundation

protocol CountryListViewModelProtocol {
    var countries: [Country] { get }
    var filteredCountries: [Country] { get }
    var selectedCountry: Country? { get set }
    var onSelectCountry: (Country) -> Void { get set }
    
    func filterCountries(with searchText: String)
    func updateSelectedCountry(at index: Int)
}
