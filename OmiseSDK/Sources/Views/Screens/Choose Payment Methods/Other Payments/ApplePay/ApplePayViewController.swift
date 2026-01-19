import UIKit
import PassKit

class ApplePayViewController: UIViewController {
    
    /// A button configured to initiate Apple Pay payments.
    lazy var applePayButton: PKPaymentButton = {
        let button = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
        button.addTarget(self, action: #selector(payPressed), for: .touchUpInside)
        return button
    }()
    
    /// A label displayed when Apple Pay is not available on the device.
    lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.text = "ApplePay.not.available.text".localized()
        return label
    }()
    
    /// The view model that drives the Apple Pay payment flow.
    private let viewModel: ApplePayViewModelType
    
    // MARK: - Initialization
    
    /// Initializes a new instance of ApplePayViewController with the specified view model.
    ///
    /// - Parameter viewModel: An object conforming to ApplePayViewModelType that provides input and output for the payment process.
    init(viewModel: ApplePayViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    /// This initializer is not implemented.
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    /// Called after the view has been loaded.
    /// Configures the UI, applies navigation bar styling, and sets up the Apple Pay button.
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        applyNavigationBarStyle(.shadow(color: .omiseSecondary))
        setupApplePayButton()
    }
    
    // MARK: - Actions
    
    /// Invoked when the Apple Pay button is pressed.
    /// Disables the button, starts the payment process via the view model, and re-enables the button upon completion.
    @objc func payPressed() {
        applePayButton.isEnabled = false
        viewModel.input.startPayment { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.applePayButton.isEnabled = true
            }
        }
    }
}

// MARK: - UI Setup
extension ApplePayViewController {
    
    /// Configures the base user interface.
    /// Sets the title, disables large title display, and configures the background color.
    func setupUI() {
        title = SourceType.applePay.localizedTitle
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = UIColor.omiseBackground
    }
    
    /// Sets up the Apple Pay button if Apple Pay is available, or displays an error label otherwise.
    /// The button or label is added to the view with appropriate Auto Layout constraints.
    func setupApplePayButton() {
        errorLabel.removeFromSuperview()
        applePayButton.removeFromSuperview()
        // Check if Apple Pay can be used.
        if viewModel.output.canMakeApplePayPayment {
            view.addSubview(applePayButton)
            applePayButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                applePayButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                applePayButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                applePayButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .padding),
                applePayButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.padding)
            ])
        } else {
            // Show a label indicating that Apple Pay is not available.
            view.addSubview(errorLabel)
            errorLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
    }
}

private extension CGFloat {
    /// A standard padding value used for layout constraints.
    static let padding: CGFloat = 20.0
}
