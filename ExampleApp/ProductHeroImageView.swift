import UIKit

@IBDesignable class ProductHeroImageView: UIView {
    
    @IBInspectable var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    private let imageView = UIImageView()
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            if cornerRadius > 0 {
                maskingPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
            } else {
                maskingPath = nil
            }
        }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        didSet {
            updateHeroShadow()
        }
    }
    
    private let shadowLayer = CALayer()
    
    private var maskingPath: UIBezierPath? {
        didSet {
            maskingLayer.path = maskingPath?.cgPath
            if self.maskingPath != nil {
                imageView.layer.mask = maskingLayer
            } else {
                imageView.layer.mask = nil
            }
        }
    }
    private let maskingLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeInstance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeInstance()
    }
    
    private func initializeInstance() {
        addSubview(imageView)
        
        maskingLayer.path = maskingPath?.cgPath
        if maskingPath != nil {
            imageView.layer.mask = maskingLayer
        }
        
        updateHeroShadow()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
        
        maskingPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        maskingLayer.frame = bounds
        shadowLayer.frame = bounds
        shadowLayer.shadowPath = maskingPath?.cgPath
    }
    
    private func updateHeroShadow() {
        if let shadowColor = self.shadowColor {
            layer.insertSublayer(shadowLayer, at: 0)
            shadowLayer.shadowOpacity = 0.3
            shadowLayer.shadowColor = shadowColor.cgColor
            shadowLayer.shadowOffset = CGSize(width: 0, height: 12)
            shadowLayer.shadowRadius = 5
            shadowLayer.shadowPath = maskingPath?.cgPath
        } else {
            shadowLayer.removeFromSuperlayer()
        }
    }
}
