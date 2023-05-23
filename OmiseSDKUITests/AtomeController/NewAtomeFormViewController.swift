//
//  NewAtomeFormViewController.swift
//  OmiseSDKUITests
//
//  Created by Andrei Solovev on 16/5/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation
import UIKit

protocol NewAtomeFormViewControllerInterface {
    func onNextButtonTapped()

}
// @objc(OMSNewAtomeFormViewController)
/// swiftlint:disable:next attributes
class NewAtomeFormViewController: UIViewController {
    typealias ViewModel = NewAtomeFormViewModelProtocol
    typealias ViewContext = NewAtomeFormViewContext
    typealias Field = ViewContext.Field

    struct Const {
        var backgroundColorForDisabledNextButton = UIColor(0xE4E7ED)
        var backgroundColorForEnabledNextButton = UIColor(0x1957F0)
        var textColorForNextButton = UIColor(0xFFFFFF)
        var textColor = UIColor(0x3C414D)
        var logo = UIImage(named: "multiply.circle.fill")
        var detailsText = "Please input the below information to complete the charge creation with Atome."
    }

    private var const = Const()
    private var viewModel: ViewModel?

    init(viewModel: ViewModel? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = const.logo
        return imageView
    }()

    private lazy var detailsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = const.detailsText
        label.textColor = const.textColor
        return label
    }()

    private var nameInput = NewAtomeTextFieldContainer()
    private var emailInput = NewAtomeTextFieldContainer()
    private var phoneNumberInput = NewAtomeTextFieldContainer()
    private var shippingStreet2Input = NewAtomeTextFieldContainer()
    private var shippingStreetInput = NewAtomeTextFieldContainer()
    private var shippingCityInput = NewAtomeTextFieldContainer()
    private var shippingStateInput = NewAtomeTextFieldContainer()
    private var shippingCountryCodeInput = NewAtomeTextFieldContainer()
    private var shippingPostalCodeInput = NewAtomeTextFieldContainer()
    private var submitButton = UIButton()
    private var requestingIndicatorView = UIActivityIndicatorView()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()

    private lazy var scrollContentView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var stackView: UIStackView = {
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
        bind()
    }

    private func setupViews() {
        view.addSubviewAndFit(scrollView)
        scrollView.addSubviewAndFit(scrollContentView)
        scrollContentView.addSubviewAndFit(stackView, horizontal: 12.0)
        NSLayoutConstraint.activate([
            scrollContentView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        stackView.addArrangedSubview(logoImageView)
        stackView.addArrangedSubview(detailsLabel)
        stackView.addArrangedSubview(shippingPostalCodeInput)
        stackView.addArrangedSubview(nameInput)
        stackView.addArrangedSubview(emailInput)
        stackView.addArrangedSubview(phoneNumberInput)
        stackView.addArrangedSubview(shippingStreetInput)
        stackView.addArrangedSubview(shippingStreet2Input)
        stackView.addArrangedSubview(shippingCityInput)
        stackView.addArrangedSubview(shippingStateInput)
        stackView.addArrangedSubview(shippingCountryCodeInput)
        stackView.addArrangedSubview(shippingPostalCodeInput)
        stackView.addArrangedSubview(submitButton)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @discardableResult
    func setViewModel(_ viewModel: ViewModel) -> Self {
        self.viewModel = viewModel
        bind()
        return self
    }

    func input(for field: Field) -> NewAtomeTextFieldContainer {
        switch field {
        case .name: return nameInput
        case .email: return emailInput
        case .phoneNumber: return phoneNumberInput
        case .street2: return shippingStreet2Input
        case .street1: return shippingStreetInput
        case .city: return shippingCityInput
        case .state: return shippingStateInput
        case .country: return shippingCountryCodeInput
        case .postalCode: return shippingPostalCodeInput
        }
    }

    var currentContext: ViewContext {
        var context = ViewContext()
        for field in Field.allCases {
            context.setValue(input(for: field).text, for: field)
        }
        return context
    }

    func validate() {
        for field in Field.allCases {
            let inputContainer = input(for: field)
            inputContainer.error = viewModel?.error(for: field, value: inputContainer.text)
        }

        self.submitButton.isEnabled = viewModel?.isNextEnabled(currentContext) ?? false
    }

    private func bind() {
        guard let viewModel = viewModel else { return }
        for field in Field.allCases {
            input(for: field).title = viewModel.title(for: field)
        }

        submitButton.setBackgroundImage(
            const.backgroundColorForDisabledNextButton.image(),
            for: .disabled
        )
        submitButton.setBackgroundImage(
            const.backgroundColorForEnabledNextButton.image(),
            for: .normal
        )
        submitButton.setTitleColor(const.textColorForNextButton, for: .normal)
        submitButton.setTitle(viewModel.titleForNextButton, for: ControlState.normal)
    }
}

#if SWIFTUI_ENABLED
import SwiftUI

struct NewAtomeFormViewController_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewControllerPresentable(
            viewController: NewAtomeFormViewController()
                .setViewModel(NewAtomeFormViewModelMockup().applyMockupTitles())
        )
    }
}
#endif
