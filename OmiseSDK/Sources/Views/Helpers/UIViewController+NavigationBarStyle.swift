import UIKit

extension UIViewController {

    enum NavigationBarStyle {
        case normal
        case shadow(color: UIColor)
    }
    func applyNavigationBarStyle(_ style: NavigationBarStyle = .normal) {
#if compiler(>=5.1)
        if #available(iOS 13, *) {
            let appearance = navigationItem.standardAppearance ?? UINavigationBarAppearance(idiom: .phone)
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.headings
            ]
            appearance.largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.headings
            ]

            switch style {
            case .normal:
                appearance.shadowColor = nil
            case .shadow(let color):
                let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
                let image = renderer.image { (context) in
                    context.cgContext.setFillColor(UIColor.line.cgColor)
                    context.fill(CGRect(origin: .zero, size: CGSize(width: 1, height: 1)))
                }
                appearance.shadowImage = image.resizableImage(withCapInsets: UIEdgeInsets.zero)
                    .withRenderingMode(.alwaysTemplate)
                appearance.shadowColor = color
            }

            navigationItem.standardAppearance = appearance

            // Copied from previous implementation
            navigationItem.scrollEdgeAppearance = navigationItem.standardAppearance
        }
#endif
    }
}
