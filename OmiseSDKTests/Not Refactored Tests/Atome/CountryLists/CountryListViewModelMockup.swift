import Foundation
import OmiseUnitTestKit
#if OMISE_SDK_UNIT_TESTING
@testable import OmiseSDK
#endif

class CountryListViewModelMockup: CountryListViewModelProtocol {
    var countries: [Country] = [Country(name: "Thailand", code: "TH"), Country(name: "France", code: "FR")]
    lazy var selectedCountry: Country? = countries.first
    var onSelectCountry: (Country) -> Void = { _ in }
}
