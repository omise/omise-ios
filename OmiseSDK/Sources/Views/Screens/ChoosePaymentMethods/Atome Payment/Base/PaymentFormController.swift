import Foundation
import UIKit

class PaymentFormController: UIViewController {
    var onSubmitButtonTappedClosure: () -> Void = { }

    @ProxyProperty(\PaymentFormController.headerTextLabel.text)
    var details: String?
    @ProxyProperty(\PaymentFormController.logoImageView.image)
    var logoImage: UIImage?

    var style = DefaultPaymentFormStyle()

    var isSubmitButtonEnabled = false {
        didSet {
            submitButton.isEnabled = isSubmitButtonEnabled
        }
    }

    // MARK: UI components of the form
    lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var headerTextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = style.textColor
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()

    lazy var submitButton: UIButton = {
        let button = MainActionButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: style.buttonHeight).isActive = true
        button.titleLabel?.adjustsFontForContentSizeCategory = true

        button.defaultBackgroundColor = style.buttonBackgroundColor
        button.disabledBackgroundColor = style.buttonDisabledBackgroundColor
        button.cornerRadius(style.buttonCornerRadius)
        return button
    }()

    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .white)
        indicator.color = style.activityIndicatorColor
        indicator.hidesWhenStopped = true
        return indicator
    }()

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.adjustContentInsetOnKeyboardAppear()
        return scrollView
    }()

    lazy var scrollContentView: UIView = {
        let view = UIView()
        return view
    }()

    lazy var verticalContainerStack: UIStackView = {
        let verticalContainerStack = UIStackView()
        verticalContainerStack.axis = .vertical
        verticalContainerStack.distribution = .equalSpacing
        verticalContainerStack.alignment = .fill
        verticalContainerStack.spacing = style.verticalContainerStackSpacer
        return verticalContainerStack
    }()

    lazy var inputsStackView: UIStackView = {
        let verticalContainerStack = UIStackView()
        verticalContainerStack.axis = .vertical
        verticalContainerStack.distribution = .equalSpacing
        verticalContainerStack.alignment = .fill
        verticalContainerStack.spacing = style.verticalInputsStackSpacer
        return verticalContainerStack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    func updateSubmitButtonState() {
        self.submitButton.isEnabled = false
    }
}

// MARK: - To override by child or add delegate or ViewModel?
extension PaymentFormController {
    func setupViews() {
        view.backgroundColor = .background

        if #available(iOS 11, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        view.addSubviewAndFit(scrollView)
        scrollView.addSubviewAndFit(scrollContentView)
        scrollContentView.addSubviewAndFit(verticalContainerStack, horizontal: style.containerStackSideSpacer)
        NSLayoutConstraint.activate([
            scrollContentView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        arrangeSubviews()

        navigationItem.titleView = activityIndicator
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }

    func arrangeSubviews() {
        verticalContainerStack.addArrangedSubview(SpacerView(vertical: style.verticalContainerStackSpacer))
        verticalContainerStack.addArrangedSubview(logoImageView)
        verticalContainerStack.addArrangedSubview(headerTextLabel)
        verticalContainerStack.addArrangedSubview(SpacerView(vertical: style.verticalContainerStackSpacer))
        verticalContainerStack.addArrangedSubview(inputsStackView)
        verticalContainerStack.addArrangedSubview(submitButton)
    }

    func setupSubmitButton(title: String, color: UIColor? = nil) {
        submitButton.setTitle(title, for: UIControl.State.normal)
        submitButton.setTitleColor(color ?? style.buttonTextColor, for: .normal)
        submitButton.addTarget(self, action: #selector(onSubmitButtonTapped), for: .touchUpInside)
    }

    func removeAllInputs() {
        for view in inputsStackView.arrangedSubviews {
            inputsStackView.removeArrangedSubview(view)
        }
    }
}

// MARK: Activities
extension PaymentFormController {
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }

    func startActivityIndicator() {
        activityIndicator.startAnimating()
        scrollContentView.isUserInteractionEnabled = false
        submitButton.isEnabled = false
        view.tintAdjustmentMode = .dimmed
    }

    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
        scrollContentView.isUserInteractionEnabled = true
        updateSubmitButtonState()
        view.tintAdjustmentMode = .automatic
    }
}

// MARK: User Interaction
extension PaymentFormController {
    @objc func onSubmitButtonTapped() {
        guard isSubmitButtonEnabled else {
            return
        }

        hideKeyboard()
        startActivityIndicator()
        submitButtonTapped()
    }

    func submitButtonTapped() {
        onSubmitButtonTappedClosure()
    }
}
