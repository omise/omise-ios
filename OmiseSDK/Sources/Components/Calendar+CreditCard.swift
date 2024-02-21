import Foundation

extension Calendar {
    /// Calendar used in the Credit Card information which is Gregorian Calendar
    static let creditCardInformationCalendar = Calendar(identifier: .gregorian)
    /// Range contains the valid range of the expiration month value
    static let validExpirationMonthRange: Range<Int> = {
        // swiftlint:disable:next force_unwrapping
        Calendar.creditCardInformationCalendar.maximumRange(of: .month)!
    }()
}
