import Foundation

protocol CountryListViewModelProtocol {
    var countries: [Country] { get }
    var selectedCountry: Country? { get set }
    var onSelectCountry: (Country) -> Void { get set }
}
