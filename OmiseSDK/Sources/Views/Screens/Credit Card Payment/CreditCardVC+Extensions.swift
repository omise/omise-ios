import UIKit

extension CreditCardPaymentController {
    func configureFieldView(_ view: TextFieldView) {
        view.title = view.fieldType?.localizedTitle
        view.placeholder = ""
        view.autocorrectionType = .no
        view.textContentType = view.fieldType?.contentType
        view.autocapitalizationType = view.fieldType?.autoCapitalization ?? .none
        view.keyboardType = view.fieldType?.keyboard ?? .default
        view.titleColor = .omisePrimary
        view.textColor = .omisePrimary
        view.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
        view.textField.tag = getFieldTag(for: view)
        view.accessibilityIdentifier = view.fieldType?.accessibilityIdentifier
        view.textField.accessibilityIdentifier = view.fieldType?.fieldAccessibilityIdentifier
        view.textField.adjustsFontForContentSizeCategory = true
    }
    
    func setErrorMessage(for view: TextFieldView) {
        view.error = view.fieldType?.errorMessage
    }
    
    func getFieldTag(for view: TextFieldView) -> Int {
        guard let field = view.fieldType else { return 0 }
        switch field {
        case .address: return addressFieldTag
        case .city: return cityFieldTag
        case .state: return stateFieldTag
        case .postalCode: return zipCodeFieldTag
        }
    }
    
    func isAddressTagGroup(_ field: OmiseTextField) -> Bool {
        field.tag == addressFieldTag ||
        field.tag == cityFieldTag ||
        field.tag == stateFieldTag ||
        field.tag == zipCodeFieldTag
    }
}

private extension TextFieldView {
    var fieldType: CreditCardAddressField? {
        CreditCardAddressField(rawValue: self.identifier)
    }
}

extension CreditCardPaymentController {
    func presentViewController(_ viewController: UIViewController) {
        if let nc = navigationController {
            nc.pushViewController(viewController, animated: true)
        } else {
            present(viewController, animated: true)
        }
    }
    
    func dismissViewController() {
        if let nc = self.navigationController {
            nc.popToViewController(self, animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
}

enum CreditCardAddressField: String, CaseIterable {
    case address
    case city
    case state
    case postalCode
    
    var id: String {
        self.rawValue
    }
    
    var contentType: UITextContentType {
        switch self {
        case .address: .streetAddressLine1
        case .city: .addressCity
        case .state: .addressState
        case .postalCode: .postalCode
        }
    }
    
    var autoCapitalization: UITextAutocapitalizationType {
        switch self {
        case .address, .city, .state: .words
        case .postalCode: .none
        }
    }
    
    var keyboard: UIKeyboardType {
        switch self {
        case .address, .postalCode: .numbersAndPunctuation
        case .city, .state: .asciiCapable
        }
    }
    
    var localizedTitle: String {
        "CreditCard.field.\(self)".localized()
    }
    
    var errorMessage: String {
        "CreditCard.field.\(self).error".localized()
    }
    
    var fieldAccessibilityIdentifier: String {
        "CreditCardForm.field.\(self)"
    }
    
    var accessibilityIdentifier: String {
        "CreditCardForm.\(self)"
    }
}
