import UIKit

class BaseFormViewController: UIViewController {
    lazy var omiseFormToolbar: OmiseFormToolbar = {
        OmiseFormToolbar(
            frame: .init(x: 0, y: 0, width: 375, height: 0),
            onPrevious: gotoPreviousField,
            onNext: gotoNextField,
            onDone: doneEditing
        )
    }()
    
    lazy var requestingIndicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = .gray
        indicator.contentMode = .scaleAspectFill
        indicator.translatesAutoresizingMaskIntoConstraints(false)
            .setAccessibilityID("BaseForm.requestingIndicator")
        return indicator
    }()
    
    lazy var contentView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints(false)
        return sv
    }()
    
    var formFields: [OmiseTextField] = [] {
        didSet {
            for field in formFields {
                field.inputAccessoryView = omiseFormToolbar
            }
        }
    }
    
    var currentEditingTextField: OmiseTextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOSApplicationExtension 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        navigationItem.backBarButtonItem = .empty
        view.backgroundColor = .background
        omiseFormToolbar.barTintColor = .formAccessoryBarTintColor
        setupKeyboardNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        formFields.forEach {
            $0.removeTarget(self, action: nil, for: .allEvents)
        }
    }
    
    func updateNavigationButtons(for field: OmiseTextField) {
        currentEditingTextField = field
        field.borderColor = view.tintColor
        let isFirst = formFields.first == field
        let isLast = formFields.last == field
        omiseFormToolbar.setPreviousEnabled(!isFirst)
        omiseFormToolbar.setNextEnabled(!isLast)
    }
    
    func gotoPreviousField() {
        guard let currentField = currentEditingTextField,
              let index = formFields.firstIndex(of: currentField),
              index > 0
        else { return }
        formFields[index - 1].becomeFirstResponder()
    }
    
    func gotoNextField() {
        guard let currentField = currentEditingTextField,
              let index = formFields.firstIndex(of: currentField),
              index < formFields.count - 1
        else { return }
        formFields[index + 1].becomeFirstResponder()
    }
    
    func doneEditing() {
        view.endEditing(true)
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(keyboardWillChangeFrame(_:)),
                name: UIResponder.keyboardWillChangeFrameNotification,
                object: nil
            )
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(keyboardWillHide(_:)),
                name: UIResponder.keyboardWillHideNotification,
                object: nil
            )
    }
    
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        guard
            let frameEnd =
                (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                 as? NSValue)?.cgRectValue
        else { return }
        let convertedFrame = view.convert(frameEnd, from: view.window)
        contentView.contentInset.bottom = convertedFrame.height
        contentView.verticalScrollIndicatorInsets.bottom = convertedFrame.height
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        contentView.contentInset.bottom = 0
        contentView.verticalScrollIndicatorInsets.bottom = 0
    }
}

extension BaseFormViewController {
    func configure(_ label: UILabel) {
        label.textColor(.omisePrimary)
            .font(.preferredFont(forTextStyle: .subheadline))
            .numberOfLines(1)
            .enableDynamicType()
            .translatesAutoresizingMaskIntoConstraints(false)
    }
    
    func configureBody(_ label: UILabel) {
        label.textColor(.omisePrimary)
            .font(.preferredFont(forTextStyle: .body))
            .numberOfLines(0)
            .enableDynamicType()
            .translatesAutoresizingMaskIntoConstraints(false)
    }
    
    func configureError(_ label: UILabel) {
        label.textColor(.systemRed)
            .font(.preferredFont(forTextStyle: .caption2))
            .numberOfLines(0)
            .alpha( 0.0)
            .enableDynamicType()
            .translatesAutoresizingMaskIntoConstraints(false)
    }
    
    func configure(_ textField: OmiseTextField) {
        textField.cornerRadius = 4
        textField.borderWidth = 1
        textField.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
        textField.textColor = .omisePrimary
        textField.font = .preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.translatesAutoresizingMaskIntoConstraints(false)
    }
    
    func configure(_ button: MainActionButton) {
        button.font(.preferredFont(forTextStyle: .headline))
        button.defaultBackgroundColor = .omise
        button.disabledBackgroundColor = .line
        button.cornerRadius = cornerRadius
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints(false)
    }
}

// MARK: - Helper Extensions
extension BaseFormViewController {
    var padding: CGFloat { 20.0 }
    var spacing: CGFloat { 16.0 }
    var minSpacing: CGFloat { 8.0 }
    var cornerRadius: CGFloat { 4.0 }
    var addressFieldTag: Int { 1001 }
    var cityFieldTag: Int { 1002 }
    var stateFieldTag: Int { 1003 }
    var zipCodeFieldTag: Int { 1004 }
}
