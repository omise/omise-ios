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
        view.backgroundColor = .background
        omiseFormToolbar.barTintColor = .formAccessoryBarTintColor
        setupKeyboardNotifications()
    }
    
    func updateNavigationButtons(for field: OmiseTextField) {
        currentEditingTextField = field
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
        contentView.scrollIndicatorInsets.bottom = convertedFrame.height
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        contentView.contentInset.bottom = 0
        contentView.scrollIndicatorInsets.bottom = 0
    }
}
