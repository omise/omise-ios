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

    struct Style {
        var backgroundColorForDisabledNextButton = UIColor(0xE4E7ED)
        var backgroundColorForEnabledNextButton = UIColor(0x1957F0)
        var textColorForNextButton = UIColor(0xFFFFFF)
        var textColor = UIColor(0x3C414D)
        var contentSpacing = CGFloat(12)
        var stackSpacing = CGFloat(8)
        var nextButtonHeight = CGFloat(47)
    }

    private var style = Style()

    var viewModel: ViewModel? {
        didSet {
            if let newViewModel = viewModel {
                bind(to: newViewModel)
            }
        }
    }

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var detailsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = style.textColor
        return label
    }()

    init(viewModel: ViewModel? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var nameInput = NewAtomeTextFieldContainer()
    private var emailInput = NewAtomeTextFieldContainer()
    private var phoneNumberInput = NewAtomeTextFieldContainer()
    private var shippingStreet2Input = NewAtomeTextFieldContainer()
    private var shippingStreetInput = NewAtomeTextFieldContainer()
    private var shippingCityInput = NewAtomeTextFieldContainer()
    private var shippingStateInput = NewAtomeTextFieldContainer()
    private var shippingCountryCodeInput = NewAtomeTextFieldContainer()
    private var shippingPostalCodeInput = NewAtomeTextFieldContainer()

    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: style.nextButtonHeight).isActive = true
        return button
    }()

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
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = style.stackSpacing
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()

        if let viewModel = viewModel {
            bind(to: viewModel)
        }
    }

    private func setupViews() {
        view.addSubviewAndFit(scrollView)
        scrollView.addSubviewAndFit(scrollContentView)
        scrollContentView.addSubviewAndFit(stackView, horizontal: style.contentSpacing)
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

    var currentContext: ViewContext {
        guard let fields = viewModel?.fields else { return ViewContext() }

        var context = ViewContext()
        for field in fields {
            context.setValue(input(for: field).text, for: field)
        }
        return context
    }

    func validate() {
        guard let fields = viewModel?.fields else {
            self.submitButton.isEnabled = false
            return
        }

        for field in fields {
            let inputContainer = input(for: field)
            inputContainer.error = viewModel?.error(for: field, value: inputContainer.text)
        }
        self.submitButton.isEnabled = viewModel?.isSubmitButtonEnabled(currentContext) ?? false
    }

    private func bind(to viewModel: ViewModel) {
        guard isViewLoaded else { return }
        setupInputs(viewModel: viewModel)
        setupSubmitButton(viewModel: viewModel)
        detailsLabel.text = viewModel.headerText
        logoImageView.image = UIImage(named: viewModel.logoName)
    }
}

private extension NewAtomeFormViewController {
    func setupSubmitButton(viewModel: ViewModel) {
        submitButton.setBackgroundImage(
            style.backgroundColorForDisabledNextButton.image(),
            for: .disabled
        )
        submitButton.setBackgroundImage(
            style.backgroundColorForEnabledNextButton.image(),
            for: .normal
        )
        submitButton.setTitleColor(style.textColorForNextButton, for: .normal)
        submitButton.setTitle(viewModel.submitButtonTitle, for: ControlState.normal)
    }

    func setupInputs(viewModel: ViewModel) {
        let fields = viewModel.fields
        for field in fields {
            let input = input(for: field)
            input.title = viewModel.title(for: field)
            input.title = viewModel.title(for: field)
            input.textContentType = viewModel.contentType(for: field)
            input.autocapitalizationType = viewModel.capitalization(for: field)
            input.keyboardType = viewModel.keyboardType(for: field)
            input.placeholder = viewModel.placeholder(for: field)
            input.autocorrectionType = .no

            if let nextInput = self.input(after: input) {
                input.returnKeyType = .next
                input.onTextFieldShouldReturn = { [weak nextInput] in
                    assert(false, "Need validation and show error here")
                    _ = nextInput?.becomeFirstResponder()
                    return false
                }
            } else {
                input.returnKeyType = .done
                input.onTextFieldShouldReturn = { [weak self] in
                    self?.onNextButtonTapped()
                    return true
                }
            }
        }
    }
    func input(after input: NewAtomeTextFieldContainer) -> NewAtomeTextFieldContainer? {
        guard let index = stackView.arrangedSubviews.firstIndex(of: input) else { return nil }

        for i in index + 1..<stackView.arrangedSubviews.count {
            if let nextInput = stackView.arrangedSubviews.at(i) as? NewAtomeTextFieldContainer {
                return nextInput
            }
        }
        return nil
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
}

extension NewAtomeFormViewController: NewAtomeFormViewControllerInterface {
    func onNextButtonTapped() {
        guard let viewModel = self.viewModel, viewModel.isSubmitButtonEnabled(currentContext) else { return }

        print("Sending data \(currentContext)")
    }
}

#if SWIFTUI_ENABLED
import SwiftUI

struct NewAtomeFormViewController_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewControllerPresentable(
            viewController: NewAtomeFormViewController(viewModel: NewAtomeFormViewModelMockup().applyMockupTitles())
        )
    }
}
#endif
