//
//  UIView+Helpers.swift
//  OmiseSDK
//
//  Created by Andrei Solovev on 16/5/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import UIKit

extension UIView {

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
}
