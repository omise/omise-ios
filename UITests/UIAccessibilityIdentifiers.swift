import Foundation

enum AccessibilityIdentifiers {
    
    enum MainView {
        static let view = "mainView"
        static let choosePaymentButton = "choosePaymentButton"
        static let creditCardPaymentButton = "creditCardPaymentButton"
        static let authorizeButton = "authorizeButton"
        static let amountLabel = "amountLabel"
        static let currencyLabel = "currencyLabel"
        static let paymentMethodsLabel = "paymentMethodsLabel"
        static let capabilityLabel = "capabilityLabel"
        static let publicKeyLabel = "publicKeyLabel"
    }
    
    enum CreditCardForm {
        static let cardNumberTextField = "CreditCardForm.cardNumberTextField"
        static let nameTextField = "CreditCardForm.nameTextField"
        static let expiryDateTextField = "CreditCardForm.expiryDateTextField"
        static let cvvTextField = "CreditCardForm.cvvTextField"
        static let emailTextField = "CreditCardForm.emailTextField"
        static let phoneTextField = "CreditCardForm.phoneTextField"
        static let cardNumberError = "CreditCardForm.cardNumberError"
        static let cardNameError = "CreditCardForm.cardNameError"
        static let expiryDateError = "CreditCardForm.expiryDateError"
        static let cvvError = "CreditCardForm.cvvError"
        static let emailError = "CreditCardForm.emailError"
        static let phoneError = "CreditCardForm.phoneError"
        static let submitButton = "CreditCardForm.submitButton"
        static let addressStackView = "CreditCardForm.addressStackView"
    }
    
    enum PaymentMethodSelection {
        static let paymentMethodList = "paymentMethodList"
        static let paymentConfirmationView = "paymentConfirmationView"
    }
    
    enum Authorization {
        static let authorizationView = "authorizationView"
        static let emailTextField = "emailTextField"
        static let authorizeSubmitButton = "authorizeSubmitButton"
        static let authorizationResultIndicator = "authorizationResultIndicator"
    }
    
    enum Results {
        static let paymentSuccessIndicator = "paymentSuccessIndicator"
        static let paymentErrorIndicator = "paymentErrorIndicator"
        static let errorMessage = "errorMessage"
    }

    enum Settings {
        static let zeroInterestSwitch = "zeroInterestInstallmentsSwitch"
    }
    
    static func allIdentifiers() -> [String] {
        return [
            MainView.view,
            MainView.choosePaymentButton,
            MainView.creditCardPaymentButton,
            MainView.authorizeButton,
            MainView.amountLabel,
            MainView.currencyLabel,
            MainView.paymentMethodsLabel,
            MainView.capabilityLabel,
            MainView.publicKeyLabel,
            CreditCardForm.cardNumberTextField,
            CreditCardForm.nameTextField,
            CreditCardForm.expiryDateTextField,
            CreditCardForm.cvvTextField,
            CreditCardForm.emailTextField,
            CreditCardForm.phoneTextField,
            CreditCardForm.cardNumberError,
            CreditCardForm.cardNameError,
            CreditCardForm.expiryDateError,
            CreditCardForm.cvvError,
            CreditCardForm.emailError,
            CreditCardForm.phoneError,
            CreditCardForm.submitButton,
            CreditCardForm.addressStackView,
            PaymentMethodSelection.paymentMethodList,
            PaymentMethodSelection.paymentConfirmationView,
            Authorization.authorizationView,
            Authorization.emailTextField,
            Authorization.authorizeSubmitButton,
            Authorization.authorizationResultIndicator,
            Results.paymentSuccessIndicator,
            Results.paymentErrorIndicator,
            Results.errorMessage,
            Settings.zeroInterestSwitch
        ]
    }
}
