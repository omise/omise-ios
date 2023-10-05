//
//  AtomeFormViewController.swift
//  OmiseSDKUITests
//
//  Created by Andrei Solovev on 16/5/23.
//  Copyright © 2023 Omise. All rights reserved.
//

// swiftlint:disable file_length

import Foundation
import UIKit

protocol AtomeFormViewControllerInterface {
    func onSubmitButtonTapped()
}

class AtomeFormViewController: UIViewController, PaymentChooserUI {
    struct Style {
        var backgroundColorForDisabledNextButton = UIColor(0xE4E7ED)
        var backgroundColorForEnabledNextButton = UIColor(0x1957F0)
        var textColorForNextButton = UIColor(0xFFFFFF)
        var textColor = UIColor(0x3C414D)
        var shippingAddressLabelColor = UIColor(0x9B9B9B)
        var contentSpacing = CGFloat(18)
        var stackSpacing = CGFloat(12)
        var inputsSpacing = CGFloat(10)
        var nextButtonHeight = CGFloat(47)
    }

    typealias ViewModel = AtomeFormViewModelProtocol
    typealias ViewContext = AtomeFormViewContext
    typealias Field = ViewContext.Field

    var viewModel: ViewModel? {
        didSet {
            if let newViewModel = viewModel {
                bind(to: newViewModel)
            }
        }
    }

    var preferredPrimaryColor: UIColor? {
        didSet {
            applyPrimaryColor()
        }
    }

    var preferredSecondaryColor: UIColor? {
        didSet {
            applySecondaryColor()
        }
    }

    private var style = Style()

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var detailsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = style.textColor
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()

    private lazy var shippingAddressLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = style.shippingAddressLabelColor
        label.font = .preferredFont(forTextStyle: .callout)
        label.text = "Atome.shippingAddress".localized()
        return label
    }()

    private lazy var submitButton: UIButton = {
        let button = MainActionButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: style.nextButtonHeight).isActive = true
        button.titleLabel?.adjustsFontForContentSizeCategory = true

        button.defaultBackgroundColor = .omise
        button.disabledBackgroundColor = .line

        button.cornerRadius(4)
        return button
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .white)
        indicator.color = UIColor(0x3D404C)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.adjustContentInsetOnKeyboardAppear()
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

    private lazy var inputsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = style.stackSpacing
        return stackView
    }()

    init(viewModel: ViewModel? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()

        if let viewModel = viewModel {
            bind(to: viewModel)
        }
    }
}

// MARK: Setups
private extension AtomeFormViewController {
    func setupViews() {
        view.backgroundColor = .background
        applyPrimaryColor()
        applySecondaryColor()
        
        if #available(iOS 11, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        view.addSubviewAndFit(scrollView)
        scrollView.addSubviewAndFit(scrollContentView)
        scrollContentView.addSubviewAndFit(stackView, horizontal: style.contentSpacing)
        NSLayoutConstraint.activate([
            scrollContentView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        stackView.addArrangedSubview(SpacerView(vertical: 12.0))
        stackView.addArrangedSubview(logoImageView)
        stackView.addArrangedSubview(detailsLabel)
        stackView.addArrangedSubview(SpacerView(vertical: 12.0))
        stackView.addArrangedSubview(inputsStackView)
        stackView.addArrangedSubview(submitButton)

        navigationItem.titleView = activityIndicator
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }

    func bind(to viewModel: ViewModel) {
        guard isViewLoaded else { return }
        setupInputs(viewModel: viewModel)
        setupSubmitButton(viewModel: viewModel)
        detailsLabel.text = viewModel.headerText
        logoImageView.image = UIImage(named: viewModel.logoName, in: .omiseSDK, compatibleWith: nil)

        updateSubmitButtonState()
        applyPrimaryColor()
        applySecondaryColor()
    }

    func setupSubmitButton(viewModel: ViewModel) {
        submitButton.setTitleColor(style.textColorForNextButton, for: .normal)
        submitButton.setTitle(viewModel.submitButtonTitle, for: ControlState.normal)
        submitButton.addTarget(self, action: #selector(onSubmitButtonTapped), for: .touchUpInside)
    }

    func removeAllInputs() {
        for view in inputsStackView.arrangedSubviews {
            inputsStackView.removeArrangedSubview(view)
        }
    }

    func setupInputs(viewModel: ViewModel) {
        removeAllInputs()

        let fields = viewModel.fields
        for field in fields {
            if field == viewModel.fieldForShippingAddressHeader {
                inputsStackView.addArrangedSubview(SpacerView(vertical: 1))
                inputsStackView.addArrangedSubview(shippingAddressLabel)
            }

            let input = AtomeInputView(id: field.rawValue)
            inputsStackView.addArrangedSubview(input)
            setupInput(input, field: field, isLast: field == fields.last, viewModel: viewModel)

            if field == .country {
                input.textFieldUserInteractionEnabled = false
                input.text = viewModel.countryListViewModel.selectedCountry?.name
                input.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCountryInputTapped)))
            }

        }
    }

    @objc func onCountryInputTapped() {
        guard let viewModel = viewModel else { return }
        let vc = CountryListViewController(viewModel: viewModel.countryListViewModel)
        vc.title = input(for: .country)?.title ?? ""
        vc.viewModel?.onSelectCountry = { [weak self] country in
            guard let self = self else { return }
            self.input(for: .country)?.text = country.name
            self.navigationController?.popToViewController(self, animated: true)

        }
        navigationController?.pushViewController(vc, animated: true)
    }

    func setupInput(_ input: AtomeInputView, field: Field, isLast: Bool, viewModel: ViewModel) {
        input.title = viewModel.title(for: field)
        input.placeholder = ""
        input.textContentType = viewModel.contentType(for: field)
        input.autocapitalizationType = viewModel.capitalization(for: field)
        input.keyboardType = viewModel.keyboardType(for: field)
        input.autocorrectionType = .no

        input.onTextChanged = { [weak self, field] in
            self?.onTextChanged(field: field)
        }

        input.onEndEditing = { [weak self, field] in
            self?.onEndEditing(field: field)
        }

        input.onBeginEditing = { [weak self, field] in
            self?.onBeginEditing(field: field)
        }

        setupOnTextFieldShouldReturn(field: field, isLast: isLast)
    }

    func applyPrimaryColor() {
        guard isViewLoaded else {
            return
        }

        detailsLabel.textColor = currentPrimaryColor
        activityIndicator.color = currentPrimaryColor
        inputsStackView.arrangedSubviews.forEach {
            if let input = $0 as? AtomeInputView {
                input.textColor = currentPrimaryColor
                input.titleColor = currentPrimaryColor
            }
        }
    }

    func applySecondaryColor() {
        guard isViewLoaded else {
            return
        }

        inputsStackView.arrangedSubviews.forEach {
            if let input = $0 as? AtomeInputView {
                input.borderColor = currentSecondaryColor
                input.placeholderTextColor = currentSecondaryColor
            }
        }
    }
}

// MARK: Actions
private extension AtomeFormViewController {
    func hideErrorIfNil(field: Field) {
        if let viewModel = viewModel, let input = input(for: field) {
            let error = viewModel.error(for: field, validate: input.text)
            if error == nil {
                input.error = nil
            }
        }
    }

    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }

    func startActivityIndicator() {
        activityIndicator.startAnimating()
        scrollContentView.isUserInteractionEnabled = false
        submitButton.isEnabled = false
        view.tintAdjustmentMode = .dimmed
    }

    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
        scrollContentView.isUserInteractionEnabled = true
        updateSubmitButtonState()
        view.tintAdjustmentMode = .automatic
    }
}

// MARK: Non-private for Unit-Testing
extension AtomeFormViewController {
    func showAllErrors() {
        guard let viewModel = self.viewModel else { return }

        for field in viewModel.fields {
            updateError(for: field)
        }
    }
    
    func makeViewContext() -> ViewContext {
        guard let viewModel = viewModel else { return ViewContext() }

        var context = ViewContext()
        let fields = viewModel.fields
        for field in fields {
            switch field {
            case .country: context[field] = viewModel.countryListViewModel.selectedCountry?.code ?? ""
            default: context[field] = input(for: field)?.text ?? ""
            }
        }
        return context
    }

    func updateSubmitButtonState() {
        let isEnabled = viewModel?.isSubmitButtonEnabled(makeViewContext()) ?? false
        self.submitButton.isEnabled = isEnabled
    }

    func updateError(for field: Field) {
        guard let input = input(for: field) else { return }
        input.error = viewModel?.error(for: field, validate: input.text)
    }

    func input(for field: Field) -> AtomeInputView? {
        for input in inputsStackView.arrangedSubviews {
            guard let input = input as? AtomeInputView, input.identifier == field.rawValue else {
                continue
            }
            return input
        }
        return nil
    }

    func input(after input: AtomeInputView) -> AtomeInputView? {
        guard
            let inputField = Field(rawValue: input.identifier),
            let viewModel = viewModel,
            let index = viewModel.fields.firstIndex(of: inputField),
            let nextField = viewModel.fields.at(index + 1),
            let nextInput = self.input(for: nextField) else {
            return nil
        }

        if nextInput.textFieldUserInteractionEnabled {
            return nextInput
        } else {
            return self.input(after: nextInput)
        }
    }
}

// MARK: Input Processing
private extension AtomeFormViewController {
    func onTextChanged(field: Field) {
        updateSubmitButtonState()
        hideErrorIfNil(field: field)
    }

    func onEndEditing(field: Field) {
        updateError(for: field)
    }

    func onBeginEditing(field: Field) {
        switch field {
        case .phoneNumber: onPhoneNumberBeginEditing()
        default: return
        }
    }

    func onPhoneNumberBeginEditing() {
        guard let input = input(for: .phoneNumber) else { return }
        if input.text?.isEmpty ?? true {
            input.text = "+"
        }
    }

    func onReturnKeyTapped(field: Field) -> Bool {
        guard let input = input(for: field) else { return true }
        self.onKeboardNextTapped(input: input)
        return false
    }

    func setupOnTextFieldShouldReturn(field: Field, isLast: Bool) {
        guard let input = input(for: field) else { return }

        if isLast {
            input.returnKeyType = .next
            input.onTextFieldShouldReturn = { [weak self, weak input] in
                guard let self = self, let input = input else { return true }
                self.onKeyboardDoneTapped(input: input)
                return true
            }
        } else {
            input.returnKeyType = .next
            input.onTextFieldShouldReturn = { [weak self, weak input] in
                guard let self = self, let input = input else { return true }
                self.onKeboardNextTapped(input: input)
                return false
            }
        }
    }

    func onKeboardNextTapped(input: AtomeInputView) {
        if let nextInput = self.input(after: input) {
            _ = nextInput.becomeFirstResponder()
        }
    }

    func onKeyboardDoneTapped(input: AtomeInputView) {
        if submitButton.isEnabled {
            onSubmitButtonTapped()
        } else {
            showAllErrors()
            goToFirstInvalidField()
        }
    }

    func goToFirstInvalidField() {
        guard let viewModel = self.viewModel else { return }

        for field in viewModel.fields {
            if let input = input(for: field), input.error != nil {
                input.becomeFirstResponder()
                return
            }
        }

    }
}

// MARK: AtomeFormViewControllerInterface
extension AtomeFormViewController: AtomeFormViewControllerInterface {
    @objc func onSubmitButtonTapped() {
        let currentContext = makeViewContext()
        guard let viewModel = self.viewModel, viewModel.isSubmitButtonEnabled(currentContext) else {
            return
        }

        hideKeyboard()
        startActivityIndicator()
        viewModel.onSubmitButtonPressed(currentContext) { [weak self] in
            self?.stopActivityIndicator()
        }
    }
}

#if SWIFTUI_ENABLED
import SwiftUI

// MARK: Preview
struct AtomeFormViewController_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewControllerPresentable(
            viewController:
                AtomeFormViewController(
                    viewModel: AtomeFormViewModelMockup().applyMockupTitles().applyMockupFields()
                )
        )
    }
}
#endif
