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
    func onSubmitButtonTapped()

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
        var contentSpacing = CGFloat(18)
        var stackSpacing = CGFloat(12)
        var inputsSpacing = CGFloat(10)
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
        label.textAlignment = .center
        label.textColor = style.textColor
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()

    init(viewModel: ViewModel? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: style.nextButtonHeight).isActive = true
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()

        if let viewModel = viewModel {
            bind(to: viewModel)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
}

// MARK: Non-private for Unit-Testing
extension NewAtomeFormViewController {
    func makeViewContext() -> ViewContext{
        guard let fields = viewModel?.fields else { return ViewContext() }

        var context = ViewContext()
        for field in fields {
            context.setValue(input(for: field)?.text, for: field)
        }
        return context
    }

    func updateSubmitButtonState() {
        let isEnabled = viewModel?.isSubmitButtonEnabled(makeViewContext()) ?? false
        self.submitButton.isEnabled = isEnabled
    }

    func refreshError(for field: Field) {
        guard let input = input(for: field) else { return }
        input.error = viewModel?.error(for: field, validate: input.text)
    }

    func validateAll() {
        for field in viewModel?.fields ?? [] {
            refreshError(for: field)
        }

        updateSubmitButtonState()
    }

    func input(for field: Field) -> NewAtomeInputView? {
        for input in inputsStackView.arrangedSubviews {
            guard let input = input as? NewAtomeInputView, input.identifier == field.rawValue else {
                continue
            }
            return input
        }
        return nil
    }

    func field(for input: NewAtomeInputView) -> Field? {
        return Field(rawValue: input.identifier)
    }
}

private extension NewAtomeFormViewController {
    func startActivityIndicator() {
        activityIndicator.startAnimating()
        scrollContentView.isUserInteractionEnabled = false
    }

    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
        scrollContentView.isUserInteractionEnabled = true
    }


    func setupViews() {
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

        view.addSubviewAndFit(activityIndicator)
    }

    func bind(to viewModel: ViewModel) {
        guard isViewLoaded else { return }
        setupInputs(viewModel: viewModel)
        setupSubmitButton(viewModel: viewModel)
        detailsLabel.text = viewModel.headerText
        logoImageView.image = UIImage(named: viewModel.logoName, in: .omiseSDK, compatibleWith: nil)

        updateSubmitButtonState()
    }

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

    func removeAllInputs() {
        for view in inputsStackView.arrangedSubviews {
            inputsStackView.removeArrangedSubview(view)
        }
    }

    func setupInputs(viewModel: ViewModel) {
        removeAllInputs()

        let fields = viewModel.fields
        for field in fields {
            let input = NewAtomeInputView(id: field.rawValue)
            inputsStackView.addArrangedSubview(input)

            input.title = viewModel.title(for: field)
            input.placeholder = viewModel.placeholder(for: field)
            input.textContentType = viewModel.contentType(for: field)
            input.autocapitalizationType = viewModel.capitalization(for: field)
            input.keyboardType = viewModel.keyboardType(for: field)
            input.autocorrectionType = .no

            input.onTextChanged = { [weak self] _ in
//                self?.validate()
            }

            if field != fields.last {
                input.returnKeyType = .next
                input.onTextFieldShouldReturn = { [weak self, weak input] in
                    guard let self = self, let input = input else { return true }
                    self.onKeboardNextTapped(input: input)
                    return false
                }
            } else {
                input.returnKeyType = .done
                input.onTextFieldShouldReturn = { [weak self, weak input] in
                    guard let self = self, let input = input else { return true }
                    self.onKeyboardDoneTapped(input: input)
                    return true
                }
            }
        }
    }

    func onKeboardNextTapped(input: NewAtomeInputView) {
        validateAll()

        if let nextInput = self.input(after: input) {
            _ = nextInput.becomeFirstResponder()
        }
    }

    func onKeyboardDoneTapped(input: NewAtomeInputView) {
        onSubmitButtonTapped()
    }

    func input(after input: NewAtomeInputView) -> NewAtomeInputView? {
        guard
            let inputField = Field(rawValue: input.identifier),
            let viewModel = viewModel,
            let index = viewModel.fields.firstIndex(of: inputField),
            let nextField = viewModel.fields.at(index + 1),
            let nextInput = self.input(for: nextField) else {
            return nil
        }

        return nextInput
    }
}

extension NewAtomeFormViewController: NewAtomeFormViewControllerInterface {
    func onSubmitButtonTapped() {
        let currentContext = makeViewContext()
        guard let viewModel = self.viewModel, viewModel.isSubmitButtonEnabled(currentContext) else { return }

        startActivityIndicator()
        viewModel.onSubmitButtonPressed(currentContext) {
            stopActivityIndicator()
        }
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
