import UIKit

final class OmiseBannerView: UIView {
    // MARK: - Public
    var onClose: (() -> Void)?
    
    var title: String? {
        didSet { titleLabel.text = title }
    }
    
    var subtitle: String? {
        didSet { detailLabel.text = subtitle }
    }
    
    private var heightConstraint: NSLayoutConstraint!
    
    // MARK: - Subviews
    private let iconImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "Alert", in: .omiseSDK, compatibleWith: .none))
        iv.contentMode(.scaleAspectFit)
            .translatesAutoresizingMaskIntoConstraints(false)
        iv.tintColor = .white
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints(false)
            .font(.preferredFont(forTextStyle: .headline))
            .textColor(.white)
            .numberOfLines(0)
            .enableDynamicType()
            .setAccessibilityID(id: "OmiseBannerView.titleLabel")
        return lbl
    }()
    
    private let detailLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints(false)
            .font(.preferredFont(forTextStyle: .body))
            .textColor(.white.withAlphaComponent(0.85))
            .numberOfLines(0)
            .enableDynamicType()
            .setAccessibilityID(id: "OmiseBannerView.subtitleLabel")
        return lbl
    }()
    
    private let closeButton: UIButton = {
        let btn = UIButton(type: .custom)
            .translatesAutoresizingMaskIntoConstraints(false)
        btn.setImage(UIImage(named: "Close Mini", in: .omiseSDK, compatibleWith: .none), for: .normal)
        btn.tintColor = .white
        return btn
    }()
    
    private lazy var textStack: UIStackView = {
        let sv = UIStackView()
        sv.axis(.vertical)
            .alignment(.leading)
            .spacing(.smallSpacing)
            .translatesAutoresizingMaskIntoConstraints(false)
        return sv
    }()
    
    private lazy var hStack: UIStackView = {
        let sv = UIStackView()
        sv.axis(.horizontal)
            .alignment(.top)
            .spacing(.spacing)
            .translatesAutoresizingMaskIntoConstraints(false)
        sv.layoutMargins = UIEdgeInsets(top: .spacing, left: .horizontalSpacing, bottom: .spacing, right: .horizontalSpacing)
        sv.isLayoutMarginsRelativeArrangement = true
        return sv
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    /// Convenience initializesr.
    convenience init() {
        self.init(frame: .zero)
        self.title = ""
        self.subtitle = ""
    }
    
    // MARK: - Setup
    private func commonInit() {
        backgroundColor(.error)
        
        textStack.addArrangedSubviews([titleLabel, detailLabel])
        hStack.addArrangedSubviews([
            iconImageView,
            textStack,
            UIView(),
            closeButton
        ])
        addSubviewAndFit(hStack)
        
        iconImageView.layoutConstraints(width: .iconSize, height: .iconSize)
        closeButton.layoutConstraints(width: .iconSize, height: .iconSize)
        
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc func closeTapped() {
        onClose?()
    }
}

private extension CGFloat {
    static let iconSize: CGFloat = 24
    static let spacing: CGFloat = 12
    static let smallSpacing: CGFloat = 4
    static let horizontalSpacing: CGFloat = 16
}
