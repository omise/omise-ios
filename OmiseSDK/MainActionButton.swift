import UIKit


@IBDesignable @objc(OMSMainActionButton)
class MainActionButton: UIButton {
    
    @IBInspectable public var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    private var backgroundColors: [ControlState: UIColor] = [:]
    
    @IBInspectable public var defaultBackgroundColor: UIColor? {
        didSet {
            setBackgroundColor(defaultBackgroundColor, for: .normal)
        }
    }
    
    @IBInspectable public var highlightedBackgroundColor: UIColor? {
        didSet {
            setBackgroundColor(highlightedBackgroundColor, for: .highlighted)
        }
    }
    
    @IBInspectable public var selectedBackgroundColor: UIColor? {
        didSet {
            setBackgroundColor(selectedBackgroundColor, for: .selected)
        }
    }
    
    @IBInspectable public var disabledBackgroundColor: UIColor? {
        didSet {
            setBackgroundColor(disabledBackgroundColor, for: .disabled)
        }
    }
    
    public override var isEnabled: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
    
    public override var isSelected: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
    
    public override var isHighlighted: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
    
    public override var backgroundColor: UIColor? {
        get {
            return backgroundColors[state] ?? backgroundColors[.normal] ?? self.defaultBackgroundColor
        }
        set {
            defaultBackgroundColor = newValue
            updateBackgroundColor()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        updateBackgroundColor()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateBackgroundColor()
    }
    
    public func setBackgroundColor(_ color: UIColor?, for state: ControlState) {
        backgroundColors[state] = color
        updateBackgroundColor()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        if backgroundColor(for: .disabled) == nil {
            setBackgroundColor(.gray, for: .disabled)
        }
        if backgroundColor(for: .highlighted) == nil {
            setBackgroundColor(.magenta, for: .highlighted)
        }
        if backgroundColor(for: .selected) == nil {
            setBackgroundColor(.orange, for: .selected)
        }
        if backgroundColor(for: [.selected, .highlighted]) == nil {
            setBackgroundColor(.purple, for: [.selected, .highlighted])
        }
    }
    
    private func updateBackgroundColor() {
        super.backgroundColor = self.backgroundColor
    }
    
    public func backgroundColor(for state: ControlState) -> UIColor? {
        return backgroundColors[state]
    }
    
}

