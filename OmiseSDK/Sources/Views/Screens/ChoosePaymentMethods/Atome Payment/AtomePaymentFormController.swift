//
//  AtomePaymentInputsFormController.swift
//  OmiseSDKUITests
//
//  Created by Andrei Solovev on 16/5/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation
import UIKit

class AtomePaymentInputsFormController: PaymentFormController {
    typealias ViewModel = AtomePaymentFormViewModelProtocol
    typealias ViewContext = AtomePaymentFormViewContext
    typealias Field = ViewContext.Field

    lazy var shippingAddressLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = style.sectionTitleColor
        label.font = .preferredFont(forTextStyle: .callout)
        label.text = "Atome.shippingAddress".localized()
        return label
    }()

    var viewModel: ViewModel? {
        didSet {
            if let newViewModel = viewModel {
                bind(to: newViewModel)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: ViewModel? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let viewModel = viewModel {
            bind(to: viewModel)
        }
    }

    override func updateSubmitButtonState() {
        let isEnabled = viewModel?.isSubmitButtonEnabled(makeViewContext()) ?? false
        self.submitButton.isEnabled = isEnabled
        isSubmitButtonEnabled = isEnabled
    }
}

private extension AtomePaymentInputsFormController {

    func onSubmitButtonHandler() {
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

    func bind(to viewModel: ViewModel) {
        guard isViewLoaded else { return }
        setupInputs(viewModel: viewModel)
        setupSubmitButton(title: viewModel.submitButtonTitle, color: style.buttonTextColor)
        details = viewModel.headerText
        logoImage = UIImage(omise: viewModel.logoName)

        updateSubmitButtonState()
        applyPrimaryColor()
        applySecondaryColor()
    }

    
    func setupInputs(viewModel: ViewModel) {
        removeAllInputs()

        let fields = viewModel.fields
        for field in fields {
            // Shipping Address section header title
            if field == viewModel.fieldForShippingAddressHeader {
                inputsStackView.addArrangedSubview(SpacerView(vertical: 1))
                inputsStackView.addArrangedSubview(shippingAddressLabel)
            }

            let input = TextFieldView(id: field.rawValue)
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
        let vc = CountryListController(viewModel: viewModel.countryListViewModel)
        vc.title = input(for: .country)?.title ?? ""
        vc.viewModel?.onSelectCountry = { [weak self] country in
            guard let self = self else { return }
            self.input(for: .country)?.text = country.name
            self.navigationController?.popToViewController(self, animated: true)

        }
        navigationController?.pushViewController(vc, animated: true)
    }

    func setupInput(_ input: TextFieldView, field: Field, isLast: Bool, viewModel: ViewModel) {
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

        inputsStackView.arrangedSubviews.forEach {
            if let input = $0 as? TextFieldView {
                input.textColor = UIColor.omisePrimary
                input.titleColor = UIColor.omisePrimary
            }
        }
    }

    func applySecondaryColor() {
        guard isViewLoaded else {
            return
        }

        inputsStackView.arrangedSubviews.forEach {
            if let input = $0 as? TextFieldView {
                input.borderColor = UIColor.omiseSecondary
                input.placeholderTextColor = UIColor.omiseSecondary
            }
        }
    }
}

// MARK: Actions
private extension AtomePaymentInputsFormController {
    func hideErrorIfNil(field: Field) {
        if let viewModel = viewModel, let input = input(for: field) {
            let error = viewModel.error(for: field, validate: input.text)
            if error == nil {
                input.error = nil
            }
        }
    }
}

// MARK: Non-private for Unit-Testing
extension AtomePaymentInputsFormController {
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

    func updateError(for field: Field) {
        guard let input = input(for: field) else { return }
        input.error = viewModel?.error(for: field, validate: input.text)
    }

    func input(for field: Field) -> TextFieldView? {
        for input in inputsStackView.arrangedSubviews {
            guard let input = input as? TextFieldView, input.identifier == field.rawValue else {
                continue
            }
            return input
        }
        return nil
    }

    func input(after input: TextFieldView) -> TextFieldView? {
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
private extension AtomePaymentInputsFormController {
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

    func onKeboardNextTapped(input: TextFieldView) {
        if let nextInput = self.input(after: input) {
            _ = nextInput.becomeFirstResponder()
        }
    }

    func onKeyboardDoneTapped(input: TextFieldView) {
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
