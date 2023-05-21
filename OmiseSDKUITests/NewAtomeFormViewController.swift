//
//  NewAtomeFormViewController.swift
//  OmiseSDKUITests
//
//  Created by Andrei Solovev on 16/5/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation

import UIKit

//@objc(OMSNewAtomeFormViewController)
// swiftlint:disable:next attributes
class NewAtomeFormViewController: UIViewController {
    private struct ViewContext {
        var name: String = ""
        var phoneNumber: String = ""
        var email: String = ""
        var country: String = ""
        var city: String = ""
        var postalCode: String = ""
        var state: String = ""
        var street1: String = ""
        var street2: String = ""
    }

    private var nameTextField = OmiseTextField()
    private var emailTextField = OmiseTextField()
    private var phoneNumberTextField = OmiseTextField()
    private var shippingStreet2TextField = OmiseTextField()
    private var shippingStreetTextField = OmiseTextField()
    private var shippingCityTextField = OmiseTextField()
    private var shippingStateTextField = OmiseTextField()
    private var shippingCountryCodeTextField = OmiseTextField()
    private var shippingPostalCodeTextField = OmiseTextField()
    private var submitButton = UIButton()
    private var requestingIndicatorView = UIActivityIndicatorView()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()

    private lazy var contentView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 12
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        view.addSubviewAndFit(scrollView)
        scrollView.addSubviewAndFit(contentView)

        nameTextField.placeholder = "Enter your name (Optional)"
        shippingPostalCodeTextField.placeholder = "Pllostal (Optional)"
        emailTextField.placeholder = "emailTextField"
        phoneNumberTextField.placeholder = "phoneNumberTextField"
        shippingStreet2TextField.placeholder = "shipp ingStreet2TextField"
        shippingStreetTextField.placeholder = "shippingStreetTextField"
        shippingCityTextField.placeholder = "shippingCityTextField"
        shippingStateTextField.placeholder = "shippingStateTextField"
        shippingCountryCodeTextField.placeholder = "s   hipp     ingCountryCodeTextField  1 2 3 4 5 6 7 8"
        submitButton.setTitle("Press me", for: .normal)
        submitButton.setTitleColor(.red, for: .normal)
        submitButton.backgroundColor = .blue



        contentView.addArrangedSubview(shippingPostalCodeTextField)
        submitButton.setTitle("Press me", for: .normal)
        contentView.addArrangedSubview(nameTextField)
        contentView.addArrangedSubview(emailTextField)
        contentView.addArrangedSubview(phoneNumberTextField)
        contentView.addArrangedSubview(shippingStreet2TextField)
        contentView.addArrangedSubview(shippingStreetTextField)
        contentView.addArrangedSubview(shippingCityTextField)
        contentView.addArrangedSubview(shippingStateTextField)
        contentView.addArrangedSubview(shippingCountryCodeTextField)
        contentView.addArrangedSubview(shippingPostalCodeTextField)
        contentView.addArrangedSubview(submitButton)
    }
}


import SwiftUI
struct NewAtomeFormViewController_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewControllerPresentable(viewController: NewAtomeFormViewController())
    }
}