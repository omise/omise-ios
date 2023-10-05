import UIKit

@IBDesignable
class MainActionButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    private var backgroundColors: [ControlState: UIColor] = [:]
    
    @IBInspectable var defaultBackgroundColor: UIColor? {
        didSet {
            setBackgroundColor(defaultBackgroundColor, for: .normal)
        }
    }
    
    @IBInspectable var highlightedBackgroundColor: UIColor? {
        didSet {
            setBackgroundColor(highlightedBackgroundColor, for: .highlighted)
        }
    }
    
    @IBInspectable var selectedBackgroundColor: UIColor? {
        didSet {
            setBackgroundColor(selectedBackgroundColor, for: .selected)
        }
    }
    
    @IBInspectable var disabledBackgroundColor: UIColor? {
        didSet {
            setBackgroundColor(disabledBackgroundColor, for: .disabled)
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
    
    override var backgroundColor: UIColor? {
        get {
            return backgroundColors[state] ?? backgroundColors[.normal] ?? self.defaultBackgroundColor
        }
        set {
            defaultBackgroundColor = newValue
            updateBackgroundColor()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateBackgroundColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateBackgroundColor()
    }
    
    func setBackgroundColor(_ color: UIColor?, for state: ControlState) {
        backgroundColors[state] = color
        updateBackgroundColor()
    }
    
    override func prepareForInterfaceBuilder() {
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
    
    func backgroundColor(for state: ControlState) -> UIColor? {
        return backgroundColors[state]
    }
    
}
