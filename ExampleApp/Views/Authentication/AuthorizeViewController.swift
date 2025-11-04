import UIKit
import OmiseSDK

final class AuthorizeViewController: ViewModelViewController<AuthorizeViewModel> {
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.text = "Paste the authorize URL returned from your charge API to complete the 3DS or PASSKEY flow."
        return label
    }()
    private let publicKeyLabel = SummaryItemView(title: "PKey")
    private let urlContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.separator.cgColor
        if #available(iOS 13.0, *) {
            view.layer.cornerCurve = .continuous
        }
        view.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 12)
        return view
    }()
    private lazy var urlTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.keyboardType = .URL
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.returnKeyType = .go
        textView.inputAccessoryView = accessoryToolbar
        textView.textContentType = .URL
        textView.delegate = self
        textView.textContainer.lineBreakMode = .byCharWrapping
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 28)
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = false
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textView.accessibilityLabel = "Authorize URL"
        return textView
    }()
    private let urlPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = .placeholderText
        label.text = "https://example.com/authorize"
        return label
    }()
    private lazy var pasteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Paste", for: .normal)
        button.setImage(UIImage(systemName: "doc.on.clipboard"), for: .normal)
        button.tintColor = view.tintColor
        button.backgroundColor = .tertiarySystemFill
        button.layer.cornerRadius = 8
        if #available(iOS 13.0, *) {
            button.layer.cornerCurve = .continuous
        }
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -3, bottom: 0, right: 3)
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 12)
        button.addTarget(self, action: #selector(pasteFromClipboard), for: .touchUpInside)
        return button
    }()
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .tertiaryLabel
        button.isHidden = true
        button.addTarget(self, action: #selector(clearURL), for: .touchUpInside)
        button.accessibilityLabel = "Clear URL"
        return button
    }()
    private lazy var accessoryToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        ]
        return toolbar
    }()
    
    private lazy var authorizeButton = PrimaryActionButton(title: "Authorize Payment") { [weak self] in
        self?.authorizeTapped()
    }
    
    override init(viewModel: AuthorizeViewModel) {
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Authorize"
        view.backgroundColor = .systemBackground
        configureLayout()
        bindViewModel()

        // Set accessibility identifier for UI testing
        if SimpleTestHarness.isUITesting {
            view.accessibilityIdentifier = "authorizationView"
        }
    }
    
    private func configureLayout() {
        configureURLField()
        let pasteRow = makePasteRow()
        let stack = makeStackView(with: pasteRow)
        layoutStack(stack)
        configureSizeConstraints()
        updatePlaceholderVisibility()
    }
    
    private func configureURLField() {
        guard urlTextView.superview == nil else { return }
        urlContainerView.addSubview(urlTextView)
        urlContainerView.addSubview(clearButton)
        urlTextView.addSubview(urlPlaceholderLabel)
        NSLayoutConstraint.activate([
            urlTextView.leadingAnchor.constraint(equalTo: urlContainerView.layoutMarginsGuide.leadingAnchor),
            urlTextView.trailingAnchor.constraint(equalTo: urlContainerView.layoutMarginsGuide.trailingAnchor),
            urlTextView.topAnchor.constraint(equalTo: urlContainerView.layoutMarginsGuide.topAnchor),
            urlTextView.bottomAnchor.constraint(equalTo: urlContainerView.layoutMarginsGuide.bottomAnchor),
            urlPlaceholderLabel.leadingAnchor.constraint(equalTo: urlTextView.leadingAnchor, constant: 4),
            urlPlaceholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: urlTextView.trailingAnchor),
            urlPlaceholderLabel.topAnchor.constraint(equalTo: urlTextView.topAnchor, constant: 2),
            clearButton.topAnchor.constraint(equalTo: urlContainerView.layoutMarginsGuide.topAnchor),
            clearButton.trailingAnchor.constraint(equalTo: urlContainerView.layoutMarginsGuide.trailingAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 22),
            clearButton.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    private func makePasteRow() -> UIStackView {
        let spacer = UIView()
        let row = UIStackView(arrangedSubviews: [spacer, pasteButton])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8
        row.translatesAutoresizingMaskIntoConstraints = false
        pasteButton.setContentHuggingPriority(.required, for: .horizontal)
        pasteButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        return row
    }
    
    private func makeStackView(with pasteRow: UIStackView) -> UIStackView {
        authorizeButton.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(infoLabel)
        stack.addArrangedSubview(publicKeyLabel)
        stack.addArrangedSubview(pasteRow)
        stack.addArrangedSubview(urlContainerView)
        stack.addArrangedSubview(authorizeButton)
        return stack
    }
    
    private func layoutStack(_ stack: UIStackView) {
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24)
        ])
    }
    
    private func configureSizeConstraints() {
        NSLayoutConstraint.activate([
            urlContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 52),
            urlTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
    }
    
    private func bindViewModel() {
        viewModel.onChange = { [weak self] summary in
            self?.publicKeyLabel.value = summary.maskedPublicKeyText
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
        updatePlaceholderVisibility()
    }
    
    private func authorizeTapped() {
        let result = viewModel.handleAuthorize(urlText: urlTextView.text, from: self, delegate: self)
        urlTextView.text = result.trimmedText
        updatePlaceholderVisibility()
        if let alert = result.alert {
            showAlert(title: alert.title, message: alert.message)
        }
    }
    
    @objc private func pasteFromClipboard() {
        guard let clipboardValue = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines),
              !clipboardValue.isEmpty else {
            showAlert(title: "Nothing to Paste", message: "Your clipboard doesn't contain a URL.")
            return
        }
        
        urlTextView.text = clipboardValue
        urlTextView.becomeFirstResponder()
        updatePlaceholderVisibility()
    }
    
    @objc private func clearURL() {
        urlTextView.text = ""
        urlTextView.becomeFirstResponder()
        updatePlaceholderVisibility()
    }
    
    private func updatePlaceholderVisibility() {
        let isEmpty = urlTextView.text.isEmpty
        urlPlaceholderLabel.isHidden = !isEmpty
        clearButton.isHidden = isEmpty || !urlTextView.isFirstResponder
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.present(alert, animated: true)
        }
    }
}

extension AuthorizeViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            authorizeTapped()
            return false
        }
        return true
    }
}

extension AuthorizeViewController: AuthorizingPaymentDelegate {
    func authorizingPaymentDidComplete(with redirectedURL: URL?) {
        OmiseSDK.shared.dismiss()
        showAlert(title: "Authorized", message: "Payment authorized with redirect url `\(redirectedURL?.absoluteString ?? "none")`.")
    }
    
    func authorizingPaymentDidCancel() {
        OmiseSDK.shared.dismiss()
        showAlert(title: "Authorization Cancelled", message: "Payment was not authorized.")
    }
}
