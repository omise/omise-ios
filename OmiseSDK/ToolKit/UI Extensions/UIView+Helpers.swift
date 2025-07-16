import UIKit

extension UIView {
    
    @discardableResult
    func backgroundColor(_ backgroundColor: UIColor) -> Self {
        self.backgroundColor = backgroundColor
        return self
    }
    
    @discardableResult
    func translatesAutoresizingMaskIntoConstraints(_ flag: Bool) -> Self {
        translatesAutoresizingMaskIntoConstraints = flag
        return self
    }
    
    @discardableResult
    func clipsToBounds(_ clipToBounds: Bool) -> Self {
        clipsToBounds = true
        return self
    }
    
    @discardableResult
    func cornerRadius(_ radius: CGFloat) -> Self {
        layer.cornerRadius = radius
        return self
    }
    
    var isHiddenInStackView: Bool {
        get {
            isHidden
        }
        set {
            if isHidden != newValue {
                isHidden = newValue
            }
        }
    }
    
    @discardableResult
    func addSubviewAndFit(_ view: UIView, vertical: CGFloat = 0, horizontal: CGFloat = 0) -> Self {
        addSubview(view)
        view.fit(to: self, top: vertical, left: horizontal, bottom: vertical, right: horizontal)
        return self
    }
    
    @discardableResult
    func addSubviewAndFit(_ view: UIView, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> Self {
        addSubview(view)
        view.fit(to: self, top: top, left: left, bottom: bottom, right: right)
        return self
    }
    
    @discardableResult
    func fit(to anotherView: UIView, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: anotherView.topAnchor, constant: top),
            bottomAnchor.constraint(equalTo: anotherView.bottomAnchor, constant: -bottom),
            leftAnchor.constraint(equalTo: anotherView.leftAnchor, constant: left),
            rightAnchor.constraint(equalTo: anotherView.rightAnchor, constant: -right)
        ])
        return self
    }
    
    @discardableResult
    func addSubviewToCenter(_ anotherView: UIView) -> Self {
        addSubview(anotherView)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            anotherView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            anotherView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        return self
    }
    
    @discardableResult
    func layoutConstraints(width: CGFloat? = nil, height: CGFloat? = nil) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let width = width {
            NSLayoutConstraint.activate([
                widthAnchor.constraint(equalToConstant: width)
            ])
        }
        
        if let height = height {
            NSLayoutConstraint.activate([
                heightAnchor.constraint(equalToConstant: height)
            ])
        }
        return self
    }
    
    @discardableResult
    func constrainWidth(equalTo otherView: UIView, constant: CGFloat) -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalTo: otherView.widthAnchor, constant: constant)
        ])
        return self
    }
    
    @discardableResult
    func setToCenter(of anotherView: UIView) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: anotherView.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: anotherView.centerYAnchor)
        ])
        return self
    }
}

// MARK: - Accessibility Identifier Helper
extension UIView {
    var allSubviews: [UIView] {
        return subviews + subviews.flatMap(\.allSubviews)
    }
    
    func view(withAccessibilityIdentifier identifier: String) -> UIView? {
        return allSubviews.first { $0.accessibilityIdentifier == identifier }
    }
    
    @discardableResult
    func setAccessibilityID(_ id: String) -> Self {
        accessibilityIdentifier = id
        return self
    }
}
