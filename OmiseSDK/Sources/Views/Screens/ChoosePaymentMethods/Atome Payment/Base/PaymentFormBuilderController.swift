import Foundation
import UIKit

class PaymentFormBuilderController: UIViewController {
    struct Style {
        var backgroundColorForDisabledNextButton = UIColor(0xE4E7ED)
        var backgroundColorForEnabledNextButton = UIColor(0x1957F0)
        var textColorForNextButton = UIColor(0xFFFFFF)
        var textColor = UIColor(0x3C414D)
        var shippingAddressLabelColor = UIColor(0x9B9B9B)
        var contentSpacing = CGFloat(18)
        var stackSpacing = CGFloat(12)
        var inputsSpacing = CGFloat(10)
        var nextButtonHeight = CGFloat(47)
    }

    var onDidTapSubmitButtonHandler: () -> Void = { }

    @ProxyProperty(\PaymentFormBuilderController.detailsLabel.text)
    var details: String?

    @ProxyProperty(\PaymentFormBuilderController.logoImageView.image)
    var logoImage: UIImage?

    var style = Style()

    var isSubmitButtonEnabled = false

    // MARK: IU Components to build the form
    lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var detailsLabel: UILabel = {
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
        button.heightAnchor.constraint(equalToConstant: style.nextButtonHeight).isActive = true
        button.titleLabel?.adjustsFontForContentSizeCategory = true

        button.defaultBackgroundColor = .omise
        button.disabledBackgroundColor = .line

        button.cornerRadius(4)
        return button
    }()

    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .white)
        indicator.color = UIColor(0x3D404C)
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

    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = style.stackSpacing
        return stackView
    }()

    lazy var inputsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = style.stackSpacing
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
}

// MARK: - To override by child or add delegate or ViewModel?
extension PaymentFormBuilderController {
    func setupViews() {
        view.backgroundColor = .background

        if #available(iOS 11, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        view.addSubviewAndFit(scrollView)
        scrollView.addSubviewAndFit(scrollContentView)
        scrollContentView.addSubviewAndFit(stackView, horizontal: style.contentSpacing)
        NSLayoutConstraint.activate([
            scrollContentView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        arrangeSubviews()

        navigationItem.titleView = activityIndicator
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }

    func arrangeSubviews() {
        stackView.addArrangedSubview(SpacerView(vertical: 12.0))
        stackView.addArrangedSubview(logoImageView)
        stackView.addArrangedSubview(detailsLabel)
        stackView.addArrangedSubview(SpacerView(vertical: 12.0))
        stackView.addArrangedSubview(inputsStackView)
        stackView.addArrangedSubview(submitButton)
    }

    func updateSubmitButtonState() {
        self.submitButton.isEnabled = false
    }

    func setupSubmitButton(title: String, color: UIColor) {
        submitButton.setTitle(title, for: UIControl.State.normal)
        submitButton.setTitleColor(color, for: .normal)
        submitButton.addTarget(self, action: #selector(onSubmitButtonTapped), for: .touchUpInside)
    }

    func removeAllInputs() {
        for view in inputsStackView.arrangedSubviews {
            inputsStackView.removeArrangedSubview(view)
        }
    }


}

// MARK: Actions
extension PaymentFormBuilderController {
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

// MARK: AtomePaymentControllerInterface
extension PaymentFormBuilderController {
    @objc func onSubmitButtonTapped() {
        guard isSubmitButtonEnabled else {
            return
        }

        hideKeyboard()
        startActivityIndicator()
        onDidTapSubmitButtonHandler()

    // TODO: Add error and stop activity processing in PaymentFormBuilderController
    }
}
