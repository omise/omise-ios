import UIKit

class TextFieldView: UIView {
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
        return textField
    }()
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "error!"
        label.textColor = style.errorColor
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(forTextStyle: .caption2)
        return label
    }()
    private lazy var contentView: UIStackView = {
        let verticalContainerStack = UIStackView()
        verticalContainerStack.axis = .vertical
        verticalContainerStack.distribution = .equalSpacing
        verticalContainerStack.alignment = .fill
        verticalContainerStack.spacing = 4
        return verticalContainerStack
    }()

    var onTextFieldShouldReturn: () -> (Bool) = { return false }
    var onTextChanged: () -> Void = { /* Non-optional default empty implementation */ }
    var onBeginEditing: () -> Void = { /* Non-optional default empty implementation */ }
    var onEndEditing: () -> Void = { /* Non-optional default empty implementation */ }

    // swiftlint:disable attributes
    @ProxyProperty(\TextFieldView.textField.keyboardType) var keyboardType: UIKeyboardType
    @ProxyProperty(\TextFieldView.textField.textContentType) var textContentType: UITextContentType?
    @ProxyProperty(\TextFieldView.textField.autocapitalizationType) var autocapitalizationType: UITextAutocapitalizationType
    @ProxyProperty(\TextFieldView.textField.returnKeyType) var returnKeyType: UIReturnKeyType
    @ProxyProperty(\TextFieldView.textField.autocorrectionType) var autocorrectionType: UITextAutocorrectionType

    @ProxyProperty(\TextFieldView.titleLabel.text) var title: String?
    @ProxyProperty(\TextFieldView.textField.placeholder) var placeholder: String?
    @ProxyProperty(\TextFieldView.textField.text) var text: String?
    @ProxyProperty(\TextFieldView.errorLabel.text) var error: String?

    @ProxyProperty(\TextFieldView.titleLabel.textColor) var titleColor: UIColor?
    @ProxyProperty(\TextFieldView.textField.textColor) var textColor: UIColor?
    @ProxyProperty(\TextFieldView.textField.borderColor) var borderColor: UIColor?
    @ProxyProperty(\TextFieldView.textField.placeholderTextColor) var placeholderTextColor: UIColor?
    @ProxyProperty(\TextFieldView.textField.isUserInteractionEnabled) var textFieldUserInteractionEnabled: Bool
    // swiftlint:enable attributes

    init(id: String, title: String? = nil, text: String? = nil, placeholder: String? = nil, error: String? = nil, textField customTextField: OmiseTextField? = nil) {
        self.identifier = id
        super.init(frame: .zero)
        self.title = title
        self.text = text
        self.placeholder = placeholder
        self.error = error

        if let customTextField = customTextField {
            self.textField = customTextField
        }

        let titleLabelContainer = UIView()
        titleLabelContainer.backgroundColor = .clear
        titleLabelContainer.addSubviewAndFit(titleLabel, left: 2)
        contentView.addArrangedSubview(titleLabelContainer)
        contentView.addArrangedSubview(textField)
        contentView.addArrangedSubview(errorLabel)
        addSubviewAndFit(contentView)

        setupTextField()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }

    @objc private func didChangeText() {
        onTextChanged()
    }

    @objc private func didEndEditing() {
        onEndEditing()
    }
    @objc private func didBeginEditing() {
        onBeginEditing()
    }
}

private extension TextFieldView {
    func setupTextField() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: style.textFieldHeight).isActive = true
        textField.borderWidth = style.textFieldBorderWidth
        textField.borderColor = style.textFieldBorderColor
        textField.cornerRadius = style.textFieldCornerRadius
        textField.adjustsFontForContentSizeCategory = true

        textField.addTarget(self, action: #selector(didChangeText), for: .editingChanged)
        textField.addTarget(self, action: #selector(didBeginEditing), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(didEndEditing), for: .editingDidEnd)

        textField.onTextFieldShouldReturn = { [weak self] in
            guard let self = self else { return true }
            return self.onTextFieldShouldReturn()
        }
    }
}

#if SWIFTUI_ENABLED
import SwiftUI
struct TextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewPresentable(view: TextFieldView(id: "", title: "Yoo", placeholder: "entered text", error: "!!!!"))
    }
}
#endif
