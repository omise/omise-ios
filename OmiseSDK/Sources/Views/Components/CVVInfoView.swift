import UIKit

final class CVVInfoView: UIView, UIGestureRecognizerDelegate {
    
    // MARK: - Public API
    var preferredCardBrand: CardBrand? {
        didSet {
            updateUI()
        }
    }
    
    var onCloseTapped: VoidClosure = nil
    
    // MARK: - Subviews
    private let containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints(false)
            .backgroundColor(.omiseBackground)
            .cornerRadius(.cornderRadius)
            .setAccessibilityID("CVVInfoView.containerView")
        return v
    }()
    
    private let cvvImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints(false)
            .contentMode(.scaleAspectFit)
            .tintColor = .body
        return iv
    }()
    
    private let descriptionLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints(false)
            .font(.preferredFont(forTextStyle: .body))
            .textColor(.body)
            .numberOfLines(0)
            .textAlignment(.center)
            .enableDynamicType()
            .setAccessibilityID("CVVInfoView.descriptionLabel")
        return l
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints(false)
            .axis(.vertical)
            .alignment(.center)
            .spacing(.spacing)
        return stack
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    // MARK: - Setup
    private func commonInit() {
        setupViews()
        updateUI()
        setupDismissGesture()
    }
    
    private func setupViews() {
        // Center the container in self and set its width
        backgroundColor(.omisePrimary.withAlphaComponent(0.4))
        addSubviewToCenter(containerView)
        containerView.layoutConstraints(width: .preferredWidth)
        
        // Build the vertical stack
        stackView.addArrangedSubviews([cvvImageView, descriptionLabel])
        containerView.addSubviewAndFit(stackView, vertical: 2 * .padding, horizontal: .padding)
        
        // Fix the image size
        cvvImageView.layoutConstraints(width: .width, height: .height)
    }
    
    private func updateUI() {
        cvvImageView.image = UIImage(omise: preferredCardBrand == .amex ? "CVV AMEX" : "CVV")
        descriptionLabel.text = localized(preferredCardBrand == .amex
                                          ? "CreditCard.cvv.details.amex.text"
                                          : "CreditCard.cvv.details.default.text")
    }
    
    private func setupDismissGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        addGestureRecognizer(tap)
    }
    
    @objc func handleBackgroundTap() {
        onCloseTapped?()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == self
    }
}

private extension CGFloat {
    static let padding: CGFloat = 16
    static let spacing: CGFloat = 12
    static let width: CGFloat = 80
    static let height: CGFloat = 50
    static let cornderRadius: CGFloat = 10
    static let preferredWidth: CGFloat = 240
}
