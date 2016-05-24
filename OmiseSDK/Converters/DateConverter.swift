import Foundation

final public class DateConverter {
    static let formatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
    }()
    
    public static func convertFromString(dateString: String?) -> NSDate? {
        guard let dateString = dateString else {
            return nil
        }
        return formatter.dateFromString(dateString)
    }
}