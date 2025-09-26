import UIKit

// MARK: - PhoneNumberTextField
public protocol PhoneNumberTextFieldDelegate: AnyObject {
    func phoneNumberTextField(_ textField: PhoneNumberTextField, didSelectCountry country: Country)
}

@IBDesignable
public class PhoneNumberTextField: OmiseTextField {
    
    // MARK: - Properties
    public weak var phoneDelegate: PhoneNumberTextFieldDelegate?
    
    public var selectedCountry = Country(name: "Thailand", code: "TH") {
        didSet {
            updateCountryCodeButton()
            phoneDelegate?.phoneNumberTextField(self, didSelectCountry: selectedCountry)
        }
    }
    
    public var fullPhoneNumber: String {
        return "\(selectedCountry.phonePrefix)\(text ?? "")"
    }
    
    // MARK: - UI Elements
    private lazy var countryCodeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.omisePrimary, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = .clear
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(countryCodeButtonTapped), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        return button
    }()
    
    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initializeInstance()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeInstance()
    }
    
    override init() {
        super.init(frame: CGRect.zero)
        initializeInstance()
    }
    
    private func initializeInstance() {
        keyboardType = .phonePad
        placeholder = "123 456 7890"
        textContentType = .telephoneNumber
        
        validator = try? NSRegularExpression(pattern: .phoneNumberRegexPattern, options: [])
        
        setupLeftView()
    }
    
    private func setupLeftView() {
        updateCountryCodeButton()
        leftView = countryCodeButton
        leftViewMode = .always
    }
    
    private func updateCountryCodeButton() {
        let title = selectedCountry.phonePrefix
        countryCodeButton.setTitle(title, for: .normal)
        
        // Calculate button width based on title
        let titleSize = title.size(withAttributes: [
            .font: countryCodeButton.titleLabel?.font ?? UIFont.systemFont(ofSize: 16)
        ])
        let buttonWidth = titleSize.width + 16 // Add padding
        
        countryCodeButton.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: 44)
    }
    
    // MARK: - Actions
    @objc func countryCodeButtonTapped() {
        presentCountryPicker()
    }
    
    private func presentCountryPicker() {
        guard let viewController = findViewController() else { return }
        
        let countryListVC = CountryCodePickerController(selectedCountry: selectedCountry) { [weak self] country in
            self?.selectedCountry = country
        }
        
        if let navigationController = viewController.navigationController {
            navigationController.pushViewController(countryListVC, animated: true)
        } else {
            let navController = UINavigationController(rootViewController: countryListVC)
            viewController.present(navController, animated: true)
        }
    }
    
    // MARK: - Public Methods
    public override func validate() throws {
        try super.validate()
        
        guard let text = self.text else {
            throw OmiseTextFieldValidationError.emptyText
        }
        
        guard text.count >= 7 else {
            throw OmiseTextFieldValidationError.invalidData
        }
    }
    
    public func setCountry(_ country: Country) {
        selectedCountry = country
    }
}

// MARK: - UIResponder Chain Helper
extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}
