import UIKit
import OmiseSDK

final class MainViewController: ViewModelViewController<MainViewModel> {
    private let dependencies: ExampleAppDependencies
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let summaryStack = UIStackView()
    private let amountLabel = SummaryItemView(title: "Amount")
    private let currencyLabel = SummaryItemView(title: "Currency")
    private let paymentMethodsLabel = SummaryItemView(title: "Payment Methods")
    private let capabilityLabel = SummaryItemView(title: "Mode")
    private let publicKeyLabel = SummaryItemView(title: "PKey")
    private let buttonContainer = UIView()
    private let buttonStack = UIStackView()
    
    private lazy var choosePaymentButton = PrimaryActionButton(title: "Choose how to pay") { [weak self] in
        self?.presentChoosePayment()
    }
    private lazy var creditCardButton = PrimaryActionButton(title: "Credit Card Payment") { [weak self] in
        self?.presentCreditCardPayment()
    }
    private lazy var authorizeButton = PrimaryActionButton(title: "Authorize Payment") { [weak self] in
        self?.showAuthorizeFlow()
    }
    
    init(viewModel: MainViewModel, dependencies: ExampleAppDependencies) {
        self.dependencies = dependencies
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Omise SDK Example"
        view.backgroundColor = .systemBackground
        configureLayout()
        bindViewModel()
        setupAccessibilityIdentifiers()
        navigationItem.rightBarButtonItem = makeSetupButton()
    }
    
    private func configureLayout() {
        configureButtonSection()
        configureScrollView()
        configureContentStack()
    }
    
    private func configureButtonSection() {
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.backgroundColor = .systemBackground
        buttonContainer.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        buttonContainer.layer.shadowOpacity = 1.0
        buttonContainer.layer.shadowOffset = CGSize(width: 0, height: -2)
        buttonContainer.layer.shadowRadius = 4
        buttonContainer.layoutMargins = UIEdgeInsets(top: 8, left: 20, bottom: 0, right: 20)
        view.addSubview(buttonContainer)
        
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .vertical
        buttonStack.spacing = 8
        buttonContainer.addSubview(buttonStack)
        buttonStack.addArrangedSubview(choosePaymentButton)
        buttonStack.addArrangedSubview(creditCardButton)
        buttonStack.addArrangedSubview(authorizeButton)
        
        NSLayoutConstraint.activate([
            buttonContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: buttonContainer.layoutMarginsGuide.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: buttonContainer.layoutMarginsGuide.trailingAnchor),
            buttonStack.topAnchor.constraint(equalTo: buttonContainer.layoutMarginsGuide.topAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: buttonContainer.layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    private func configureScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonContainer.topAnchor)
        ])
    }
    
    private func configureContentStack() {
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Explore how to integrate OmiseSDK using ready-made flows for payments and authorization."
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .body)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        
        configureSummaryStack()
        contentStack.addArrangedSubview(descriptionLabel)
        contentStack.addArrangedSubview(summaryStack)
    }
    
    private func configureSummaryStack() {
        summaryStack.axis = .vertical
        summaryStack.spacing = 8
        summaryStack.alignment = .fill
        summaryStack.distribution = .fill
        [amountLabel, currencyLabel, publicKeyLabel, capabilityLabel, paymentMethodsLabel].forEach { summaryStack.addArrangedSubview($0) }
        
        paymentMethodsLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        paymentMethodsLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
    
    private func bindViewModel() {
        viewModel.onChange = { [weak self] summary in
            self?.apply(summary: summary)
        }
    }
    
    private func apply(summary: ExampleSummary) {
        amountLabel.value = summary.amountText
        currencyLabel.value = summary.currencyText
        capabilityLabel.value = summary.capabilityText
        paymentMethodsLabel.value = summary.paymentMethodText
        publicKeyLabel.value = summary.maskedPublicKeyText
    }
    
    private func presentChoosePayment() {
        let parameters = viewModel.paymentParameters()
        let isUITesting = SimpleTestHarness.isUITesting
        let isMockMode = SimpleTestHarness.isMockMode

        // Skip capability validation only when both UI testing and mock mode are enabled
        let skipCapabilityValidation = isUITesting && isMockMode

        // In UI testing mode with mock enabled, use comprehensive payment methods to showcase all available options
        // This ensures we have access to all payment methods for testing regardless of capability restrictions
        let allowedMethods: [SourceType]? = skipCapabilityValidation ?
            Array(SourceType.allAvailablePaymentMethods) : parameters.allowedMethods

        OmiseSDK.shared.presentChoosePaymentMethod(
            from: self,
            amount: parameters.amount,
            currency: parameters.currencyCode,
            allowedPaymentMethods: allowedMethods,
            skipCapabilityValidation: skipCapabilityValidation,
            isCardPaymentAllowed: true,
            handleErrors: true,
            collect3DSData: .all,
            delegate: self
        )
    }
    
    private func presentCreditCardPayment() {
        let parameters = viewModel.paymentParameters()
        OmiseSDK.shared.presentCreditCardPayment(
            from: self,
            countryCode: parameters.currencyCode,
            handleErrors: true,
            collect3DSData: .all,
            delegate: self
        )
    }
    
    private func showAuthorizeFlow() {
        let authorizeViewModel = AuthorizeViewModel(
            settingsStore: dependencies.settingsStore,
            config: dependencies.config
        )
        let controller = AuthorizeViewController(viewModel: authorizeViewModel)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func makeSetupButton() -> UIBarButtonItem {
        if let gearImage = UIImage(systemName: "gearshape") {
            let button = UIBarButtonItem(image: gearImage, style: .plain, target: self, action: #selector(showSetup))
            button.accessibilityLabel = "Setup"
            return button
        } else {
            return UIBarButtonItem(title: "Setup", style: .plain, target: self, action: #selector(showSetup))
        }
    }
    
    @objc private func showSetup() {
        let setupViewModel = SettingsViewModel(settingsStore: dependencies.settingsStore)
        let controller = SettingsViewController(viewModel: setupViewModel)
        navigationController?.pushViewController(controller, animated: true)
    }

    private func copyToPasteboard(_ string: String) {
        UIPasteboard.general.string = string
    }

    private func presentPaymentResult(_ result: PaymentResult) {
        copyToPasteboard(result.pasteboardValue)
        OmiseSDK.shared.dismiss { [weak self] in
            self?.showAlert(title: result.title, message: result.message)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - UI Testing Support

    private func setupAccessibilityIdentifiers() {
        guard SimpleTestHarness.isUITesting else { return }

        // Main view identifier
        view.accessibilityIdentifier = "mainView"

        // Button identifiers
        choosePaymentButton.accessibilityIdentifier = "choosePaymentButton"
        creditCardButton.accessibilityIdentifier = "creditCardPaymentButton"
        authorizeButton.accessibilityIdentifier = "authorizeButton"

        // Summary view identifiers
        amountLabel.accessibilityIdentifier = "amountLabel"
        currencyLabel.accessibilityIdentifier = "currencyLabel"
        paymentMethodsLabel.accessibilityIdentifier = "paymentMethodsLabel"
        capabilityLabel.accessibilityIdentifier = "capabilityLabel"
        publicKeyLabel.accessibilityIdentifier = "publicKeyLabel"

    }
}

extension MainViewController: ChoosePaymentMethodDelegate {
    func choosePaymentMethodDidComplete(with source: Source) {
        let result = viewModel.paymentResult(for: source)
        presentPaymentResult(result)
    }

    func choosePaymentMethodDidComplete(with token: Token) {
        let result = viewModel.paymentResult(for: token)
        presentPaymentResult(result)
    }
    
    func choosePaymentMethodDidComplete(with error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        let presenter = OmiseSDK.shared.presentedViewController ?? self
        presenter.present(alert, animated: true)
    }
    
    func choosePaymentMethodDidCancel() {
        OmiseSDK.shared.dismiss()
    }
    
    func choosePaymentMethodDidComplete(with source: Source, token: Token) {
        let result = viewModel.paymentResult(for: source, token: token)
        presentPaymentResult(result)
    }
}

extension MainViewController: AuthorizingPaymentDelegate {
    func authorizingPaymentDidComplete(with redirectedURL: URL?) {
        OmiseSDK.shared.dismiss()
        showAlert(title: "Authorized", message: "Payment authorized with redirect url `\(redirectedURL?.absoluteString ?? "none")`.")
    }
    
    func authorizingPaymentDidCancel() {
        OmiseSDK.shared.dismiss()
        showAlert(title: "Authorization Cancelled", message: "Payment was not authorized.")
    }
}
