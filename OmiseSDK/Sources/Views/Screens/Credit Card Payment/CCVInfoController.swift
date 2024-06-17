import UIKit

class CCVInfoController: UIViewController {
    static let preferredWidth: CGFloat = 240
    
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var cvvLocationImageView: UIImageView!
    @IBOutlet private var cvvLocationDescriptionLabel: UILabel!

    var preferredCardBrand: CardBrand? {
        didSet {
            guard isViewLoaded else {
                return
            }
            updateUI()
        }
    }

    var onCloseTapped: () -> Void = { /* Non-optional default empty implementation */ }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layer = containerView.layer
        layer.cornerRadius = 10

        containerView.backgroundColor = UIColor.omiseBackground
        cvvLocationDescriptionLabel.textColor = .body
        cvvLocationImageView.tintColor = .body
        updateUI()

        let tapGesture = TapGestureHandler { [weak self] in
            self?.onCloseTapped()
        }

        view.addGestureRecognizer(tapGesture)
    }
    
    private func updateUI() {
        switch preferredCardBrand {
        case .amex?:
            cvvLocationImageView.image = UIImage(omise: "CVV AMEX")
            cvvLocationDescriptionLabel.text = localized("CreditCard.ccv.details.amex.text")
        default:
            cvvLocationImageView.image = UIImage(omise: "CVV")
            cvvLocationDescriptionLabel.text = localized("CreditCard.ccv.details.default.text")
        }
    }
}

class ExpandedHitAreaButton: UIButton {
    var hitAreaSize = CGSize(width: 44, height: 44)
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let horizontalInset = max(0, (hitAreaSize.width - bounds.width)) / 2
        let verticalInset = max(0, (hitAreaSize.height - bounds.height)) / 2
        return bounds.insetBy(dx: -horizontalInset, dy: -verticalInset).contains(point)
    }
}
