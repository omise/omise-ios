import UIKit

final class TextFieldTableViewCell: UITableViewCell {
    static let reuseIdentifier = "TextFieldTableViewCell"
    
    let titleLabel = UILabel()
    let textField = UITextField()
    var onCommit: ((String) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, text: String, placeholder: String, keyboardType: UIKeyboardType, accessory: UIToolbar?) {
        titleLabel.text = title
        textField.text = text
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        textField.inputAccessoryView = accessory
        textField.returnKeyType = .done
    }
    
    private func setup() {
        selectionStyle = .none
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textAlignment = .right
        textField.delegate = self
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textField.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

extension TextFieldTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        onCommit?(textField.text ?? "")
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        onCommit?(textField.text ?? "")
    }
}
