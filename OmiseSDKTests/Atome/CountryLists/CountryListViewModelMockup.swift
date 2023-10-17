import Foundation
import OmiseUnitTestKit
#if OMISE_SDK_UNIT_TESTING
@testable import OmiseSDK
#endif

class CountryListViewModelMockup: CountryListViewModelProtocol {
    var countries: [CountryInfo] = [CountryInfo(name: "Thailand", code: "TH"), CountryInfo(name: "France", code: "FR")]
    lazy var selectedCountry: CountryInfo? = countries.first
    var onSelectCountry: (CountryInfo) -> Void = { _ in }
}
