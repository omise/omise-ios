//
//  NewAtomeInputView.swift
//  OmiseSDKUITests
//
//  Created by Andrei Solovev on 21/5/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import UIKit

class NewAtomeInputView: UIView {
    struct Style {
        var errorColor = UIColor(0xFB0000)
        var titleColor = UIColor(0x3C414D)
        var textColor = UIColor(0x3C414D)
        var textFieldHeight = CGFloat(47)
        var textFieldBorderColor = UIColor(0xE4E7ED)
        var textFieldBorderWidth = CGFloat(1)
        var textFieldCornerRadius = CGFloat(4)
    }

    let identifier: String
    private var style = Style()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = style.titleColor
        label.font = .preferredFont(forTextStyle: .subheadline)
        return label
    }()
    private lazy var textField: OmiseTextField = {
        let textField = OmiseTextField()
        textField.textColor = style.textColor
        textField.font = .preferredFont(forTextStyle: .body)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: style.textFieldHeight).isActive = true
        textField.borderWidth = style.textFieldBorderWidth
        textField.borderColor = style.textFieldBorderColor
        textField.cornerRadius = style.textFieldCornerRadius
        return textField
    }()
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "error!"
        label.textColor = style.errorColor
        label.font = .preferredFont(forTextStyle: .caption2)
        return label
    }()
    private lazy var contentView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 4
        return stackView
    }()

    var onTextFieldShouldReturn: () -> (Bool) = { return false }
    var onTextChanged: (String) -> Void = { _ in }

    @ProxyProperty(\NewAtomeInputView.textField.keyboardType) var keyboardType: UIKeyboardType
    @ProxyProperty(\NewAtomeInputView.textField.textContentType) var textContentType: UITextContentType?
    @ProxyProperty(\NewAtomeInputView.textField.autocapitalizationType) var autocapitalizationType: UITextAutocapitalizationType
    @ProxyProperty(\NewAtomeInputView.textField.returnKeyType) var returnKeyType: UIReturnKeyType
    @ProxyProperty(\NewAtomeInputView.textField.autocorrectionType) var autocorrectionType: UITextAutocorrectionType

    @ProxyProperty(\NewAtomeInputView.titleLabel.text) var title: String?
    @ProxyProperty(\NewAtomeInputView.textField.placeholder) var placeholder: String?
    @ProxyProperty(\NewAtomeInputView.textField.text) var text: String?
    @ProxyProperty(\NewAtomeInputView.errorLabel.text) var error: String?

    init(id: String, title: String? = nil, text: String? = nil, placeholder: String? = nil, error: String? = nil) {
        self.identifier = id
        super.init(frame: .zero)
        self.title = title
        self.text = text
        self.placeholder = placeholder
        self.error = error

        let titleLabelContainer = UIView()
        titleLabelContainer.backgroundColor = .clear
        titleLabelContainer.addSubviewAndFit(titleLabel, left: 2)
        contentView.addArrangedSubview(titleLabelContainer)
        contentView.addArrangedSubview(textField)
        contentView.addArrangedSubview(errorLabel)
        addSubviewAndFit(contentView)

        textField.addTarget(self, action: #selector(didChangeText), for: .editingChanged)
        textField.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")    }

    @objc func didChangeText() {
        onTextChanged(textField.text ?? "")
    }

    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }
}

extension NewAtomeInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onTextFieldShouldReturn()
    }
}

#if SWIFTUI_ENABLED
import SwiftUI
struct NewAtomeInputView_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewPresentable(view: NewAtomeInputView(id: "", title: "Yoo", placeholder: "entered text", error: "!!!!"))
    }
}
#endif
