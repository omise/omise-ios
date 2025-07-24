import UIKit

// swiftlint:disable discouraged_object_literal
extension UIColor {
    private static let defaultHeadings: UIColor = #colorLiteral(red: 0.01568627451, green: 0.02745098039, blue: 0.05098039216, alpha: 1)
    public static let headings: UIColor = {
#if compiler(>=5.1)
        if #available(iOS 13, *) {
            return UIColor { traitCollection -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                } else {
                    return defaultHeadings
                }
            }
        } else {
            return defaultHeadings
        }
#else
        return defaultHeadings
#endif
    }()
    
    private static let defaultLine: UIColor = #colorLiteral(red: 0.8941176471, green: 0.9058823529, blue: 0.9294117647, alpha: 1)
    public static let line: UIColor = {
#if compiler(>=5.1)
        if #available(iOS 13, *) {
            return UIColor { traitCollection -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return #colorLiteral(red: 0.2274509804, green: 0.2274509804, blue: 0.2352941176, alpha: 1)
                } else {
                    return defaultLine
                }
            }
        } else {
            return defaultLine
        }
#else
        return defaultLine
#endif
    }()
    // swiftlint:enable discouraged_object_literal
}
