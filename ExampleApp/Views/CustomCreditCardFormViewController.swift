import UIKit
import OmiseSDK

// swiftlint:disable:next type_name
protocol CustomCreditCardPaymentControllerDelegate: AnyObject {
    /// Delegate method for receiving token data when card tokenization succeeds.
    /// - parameter token: `OmiseToken` instance created from supplied credit card data.
    /// - seealso: [Tokens API](https://www.omise.co/tokens-api)
    func creditCardFormViewController(_ controller: CustomCreditCardPaymentController, didSucceedWithToken token: Token)
    
    /// Delegate method for receiving error information when card tokenization failed.
    /// This allows you to have fine-grained control over error handling when setting
    /// `handleErrors` to `false`.
    /// - parameter error: The error that occurred during tokenization.
    /// - note: This delegate method will *never* be called if `handleErrors` property is set to `true`.
    func creditCardFormViewController(_ controller: CustomCreditCardPaymentController, didFailWithError error: Error)
}

class CustomCreditCardPaymentController: UIViewController {
    @IBOutlet private var cardNumberField: CardNumberTextField!
    @IBOutlet private var cardNameField: CardNameTextField!
    @IBOutlet private var cardExpiryField: CardExpiryDateTextField!
    @IBOutlet private var cardCVVField: CardCVVTextField!

    @IBOutlet private var billingStackView: UIStackView!

    private var countryCodeField = OmiseTextField()
    private var street1Field = OmiseTextField()
    private var street2Field = OmiseTextField()
    private var cityField = OmiseTextField()
    private var stateField = OmiseTextField()
    private var postalCodeField = OmiseTextField()

    @IBOutlet private var doneButton: UIBarButtonItem!
    
    weak var delegate: CustomCreditCardPaymentControllerDelegate?
    
    // need to refactor loadView, removing super results in crash
    // swiftlint:disable:next prohibited_super_call function_body_length
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .background

        billingStackView = UIStackView()
        billingStackView.axis = .vertical
        billingStackView.spacing = 24
        billingStackView.distribution = .equalSpacing
        billingStackView.alignment = .fill

        cardNumberField = CardNumberTextField()
        cardNumberField.translatesAutoresizingMaskIntoConstraints = false
        cardNumberField.placeholder = "1234567812345678"
        cardNameField = CardNameTextField()
        cardNameField.translatesAutoresizingMaskIntoConstraints = false
        cardNameField.placeholder = "John Appleseed"
        cardExpiryField = CardExpiryDateTextField()
        cardExpiryField.translatesAutoresizingMaskIntoConstraints = false
        cardExpiryField.placeholder = "MM/yy Date Format"
        cardCVVField = CardCVVTextField()
        cardCVVField.translatesAutoresizingMaskIntoConstraints = false
        cardCVVField.placeholder = "321"

        let cardNumberLabel = UILabel()
        cardNumberLabel.text = "Card Number"
        cardNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        let cardNumberStackView = UIStackView(arrangedSubviews: [cardNumberLabel, cardNumberField])
        let cardNameLabel = UILabel()
        cardNameLabel.text = "Card Name"
        cardNameLabel.translatesAutoresizingMaskIntoConstraints = false
        let cardNameStackView = UIStackView(arrangedSubviews: [cardNameLabel, cardNameField])
        let cardExpiryLabel = UILabel()
        cardExpiryLabel.text = "Card Expiry"
        cardExpiryLabel.translatesAutoresizingMaskIntoConstraints = false
        let cardExpiryStackView = UIStackView(arrangedSubviews: [cardExpiryLabel, cardExpiryField])
        let cardCVVLabel = UILabel()
        cardCVVLabel.text = "Card CVV"
        cardCVVLabel.translatesAutoresizingMaskIntoConstraints = false
        let cardCVVStackView = UIStackView(arrangedSubviews: [cardCVVLabel, cardCVVField])

        let lowerRowStackView = UIStackView(arrangedSubviews: [cardExpiryStackView, cardCVVStackView])

        cardNumberStackView.axis = .vertical
        cardNumberStackView.distribution = .fill
        cardNumberStackView.alignment = .fill
        cardNumberStackView.spacing = 10
        cardNameStackView.axis = .vertical
        cardNameStackView.distribution = .fill
        cardNameStackView.alignment = .fill
        cardNameStackView.spacing = 10
        cardExpiryStackView.axis = .vertical
        cardExpiryStackView.distribution = .fill
        cardExpiryStackView.alignment = .fill
        cardExpiryStackView.spacing = 10
        cardCVVStackView.axis = .vertical
        cardCVVStackView.distribution = .fill
        cardCVVStackView.alignment = .fill
        cardCVVStackView.spacing = 10
        lowerRowStackView.axis = .horizontal
        lowerRowStackView.distribution = .fillEqually
        lowerRowStackView.alignment = .fill
        lowerRowStackView.spacing = 10

        let verticalContainerStack = UIStackView(arrangedSubviews: [cardNumberStackView, cardNameStackView, lowerRowStackView])
        verticalContainerStack.translatesAutoresizingMaskIntoConstraints = false
        verticalContainerStack.axis = .vertical
        verticalContainerStack.distribution = .fill
        verticalContainerStack.alignment = .fill
        verticalContainerStack.spacing = 20

        view.addSubview(verticalContainerStack)
        NSLayoutConstraint.activate([
            verticalContainerStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            verticalContainerStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            verticalContainerStack.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
            verticalContainerStack.bottomAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.bottomAnchor)
        ])

        setupBillingAddressFields()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let saveButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.proceed))
        navigationItem.rightBarButtonItem = saveButtonItem
        self.doneButton = saveButtonItem
        navigationItem.title = "Custom Credit Card Form"
    }

    private func setupBillingAddressFields() {
        countryCodeField.placeholder = "Country Code (ex. \"TH\")"
        street1Field.placeholder = "Street"
        street2Field.placeholder = "Street 2"
        cityField.placeholder = "City"
        stateField.placeholder = "State"
        postalCodeField.placeholder = "Postal Code"

        let fields = [countryCodeField, cityField, street1Field, street2Field, stateField, postalCodeField]
        fields.forEach {
            billingStackView.addArrangedSubview($0)
        }

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }

    @objc private func hideKeyboard() {
        self.view.endEditing(true)
    }

    @IBAction private func proceed(_ sender: UIBarButtonItem) {
        guard let name = cardNameField.text, cardNumberField.isValid,
            let expiryMonth = cardExpiryField.selectedMonth, let expiryYear = cardExpiryField.selectedYear,
            let cvv = cardCVVField.text, let number = cardNumberField.text else {
                return
        }

        let card = CreateTokenPayload.Card(
            name: name,
            number: number,
            expirationMonth: expiryMonth,
            expirationYear: expiryYear,
            securityCode: cvv,
            phoneNumber: nil,
            email: nil,
            countryCode: countryCodeField.text ?? "",
            city: cityField.text ?? "",
            state: stateField.text ?? "",
            street1: street1Field.text ?? "",
            street2: street2Field.text ?? "",
            postalCode: postalCodeField.text ?? ""
        )

        let payload = CreateTokenPayload(card: card)
        doneButton.isEnabled = false
        OmiseSDK.shared.client.createToken(payload: payload) { [weak self] (result) in
            guard let self = self else { return }
            self.doneButton.isEnabled = false
            switch result {
            case .success(let token):
                self.delegate?.creditCardFormViewController(self, didSucceedWithToken: token)
            case .failure(let error):
                self.delegate?.creditCardFormViewController(self, didFailWithError: error)
            }
        }
    }
}
