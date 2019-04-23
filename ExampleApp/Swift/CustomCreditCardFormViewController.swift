import UIKit

protocol CustomCreditCardFormViewControllerDelegate: AnyObject {
    /// Delegate method for receiving token data when card tokenization succeeds.
    /// - parameter token: `OmiseToken` instance created from supplied credit card data.
    /// - seealso: [Tokens API](https://www.omise.co/tokens-api)
    func creditCardFormViewController(_ controller: CustomCreditCardFormViewController, didSucceedWithToken token: Token)
    
    /// Delegate method for receiving error information when card tokenization failed.
    /// This allows you to have fine-grained control over error handling when setting
    /// `handleErrors` to `false`.
    /// - parameter error: The error that occurred during tokenization.
    /// - note: This delegate method will *never* be called if `handleErrors` property is set to `true`.
    func creditCardFormViewController(_ controller: CustomCreditCardFormViewController, didFailWithError error: Error)
}


@objc(CustomCreditCardFormViewController)
@objcMembers
class CustomCreditCardFormViewController: UIViewController {
    
    let omiseClient = Client(publicKey: "pkey_test_<#Omise Public Key#>")
    
    @IBOutlet var cardNumberField: CardNumberTextField!
    @IBOutlet var cardNameField: CardNameTextField!
    @IBOutlet var cardExpiryField: CardExpiryDateTextField!
    @IBOutlet var cardCVVField: CardCVVTextField!
  
    @IBOutlet var doneButton: UIBarButtonItem!
    
    weak var delegate: CustomCreditCardFormViewControllerDelegate?
    
    override func loadView() {
        super.loadView()
        
        if storyboard == nil {
            view.backgroundColor = .white
            
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
            
            
            let stackView = UIStackView(arrangedSubviews: [cardNumberStackView, cardNameStackView, lowerRowStackView])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.distribution = .fill
            stackView.alignment = .fill
            stackView.spacing = 20

            view.addSubview(stackView)
            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
                stackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
                stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.bottomAnchor),
                ])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if storyboard == nil {
            let saveButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.proceed))
            navigationItem.rightBarButtonItem = saveButtonItem
            self.doneButton = saveButtonItem
            navigationItem.title = "Custom Credit Card Form"
        }
    }
    
    @IBAction func proceed(_ sender: UIBarButtonItem) {
        guard let name = cardNameField.text, cardNumberField.isValid,
            let expiryMonth = cardExpiryField.selectedMonth, let expiryYear = cardExpiryField.selectedYear,
            let cvv = cardCVVField.text else {
                return
        }
        let tokenRequest = Request<Token>(
            name: name, pan: cardNumberField.pan,
            expirationMonth: expiryMonth, expirationYear: expiryYear,
            securityCode: cvv
        )
        omiseClient.send(tokenRequest) { (result) in
            switch result {
            case .success(let token):
                self.delegate?.creditCardFormViewController(self, didSucceedWithToken: token)
            case .failure(let error):
                self.delegate?.creditCardFormViewController(self, didFailWithError: error)
            }
        }
    }
}
