import UIKit


public enum TextFieldStyle {
    case plain
    case border(width: CGFloat)
}

public enum OmiseTextFieldValidationError: Error {
    case emptyText
    case invalidData
}


/// Base UITextField subclass for SDK's text fields.
@objc(OMSOmiseTextField) @IBDesignable
public class OmiseTextField: UITextField {
    public var style: TextFieldStyle = .plain {
        didSet {
            updateBorder()
            invalidateIntrinsicContentSize()
        }
    }
    
    @IBInspectable @objc var borderWidth: CGFloat {
        get {
            switch style {
            case .plain:
                return 0
            case .border(width: let width):
                return width
            }
        }
        set {
            switch newValue {
            case let value where value <= 0:
                style = .plain
            case let value:
                style = .border(width: value)
            }
        }
    }
    
    @IBInspectable @objc var borderColor: UIColor? {
        didSet {
            updateBorder()
        }
    }
    
    @IBInspectable @objc var cornerRadius: CGFloat = 0 {
        didSet {
            updateBorder()
        }
    }
    
    @IBInspectable @objc var errorTextColor: UIColor? {
        didSet {
            updateTextColor()
        }
    }
    
    @IBInspectable @objc var placeholderTextColor: UIColor? {
        didSet {
            updatePlaceholderTextColor()
        }
    }
    
    public override var placeholder: String? {
        didSet {
            updatePlaceholderTextColor()
        }
    }
    
    /// Boolean indicating wether current input is valid or not.
    public var isValid: Bool {
        do {
            try validate()
            return true
        } catch {
            return false
        }
    }
    
    private var normalTextColor: UIColor?
    
    public override var text: String? {
        didSet {
            // UITextField doesn't send editing changed control event when we set its text property
            textDidChange()
            updateTextColor()
        }
    }
    
    public override var textColor: UIColor? {
        get {
            return normalTextColor
        }
        set {
            normalTextColor = newValue
            updateTextColor()
        }
    }
    
    private func updateTextColor() {
        guard let errorTextColor = errorTextColor else {
            super.textColor = normalTextColor ?? .black
            return
        }
        super.textColor = isValid || isFirstResponder ? (normalTextColor ?? .black) : errorTextColor
    }
    
    func updatePlaceholderTextColor() {
        if let attributedPlaceholder = attributedPlaceholder, let placeholderColor = self.placeholderTextColor {
            let formattingAttributedText = NSMutableAttributedString(attributedString: attributedPlaceholder)

            let formattingPlaceholderString = formattingAttributedText.string
            formattingAttributedText.addAttribute(
                AttributedStringKey.foregroundColor, value: placeholderColor,
                range: NSRange(formattingPlaceholderString.startIndex..<formattingPlaceholderString.endIndex, in: formattingPlaceholderString)
            )
            super.attributedPlaceholder = (formattingAttributedText.copy() as! NSAttributedString)
        }
    }
    
    var validator: FieldValidator?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initializeInstance()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeInstance()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        initializeInstance()
    }
    
    @objc public func validate() throws {
        guard let text = self.text else {
            throw OmiseTextFieldValidationError.emptyText
        }
        if text.isEmpty {
            throw OmiseTextFieldValidationError.emptyText
        }
        
        
        if let validator = self.validator {
            try validator.validate(text)
        }
    }
    
    private func initializeInstance() {
        normalTextColor = super.textColor
        
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        addTarget(self, action: #selector(didBeginEditing), for: .editingDidBegin)
        addTarget(self, action: #selector(didEndEditing), for: .editingDidEnd)
        updateBorder()
    }
    
    @objc func didBeginEditing() {
        updateTextColor()
    }
    
    @objc func didEndEditing() {
        updateTextColor()
    }
    
    @objc func textDidChange() {}
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        #if compiler(>=5.1)
        if #available(iOS 13, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateBorder()
        }
        #endif
    }
}


extension OmiseTextField {
    private var overallInsets: UIEdgeInsets {
        let edgeInsets: UIEdgeInsets
        switch style {
        case .plain:
            edgeInsets = UIEdgeInsets.zero
        case .border(width: let width):
            edgeInsets = UIEdgeInsets(
                top: layoutMargins.top + width,
                left: layoutMargins.left + width,
                bottom: layoutMargins.bottom + width,
                right: layoutMargins.right + width
            )
        }
        
        return edgeInsets
    }
    
    public override func borderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds
    }
    
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: textAreaViewRect(forBounds: bounds))
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return super.editingRect(forBounds: textAreaViewRect(forBounds: bounds))
    }
    
    open override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        return super.clearButtonRect(forBounds: textAreaViewRect(forBounds: bounds))
    }
    
    public override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return super.rightViewRect(forBounds: textAreaViewRect(forBounds: bounds))
    }
    
    public override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return super.leftViewRect(forBounds: textAreaViewRect(forBounds: bounds))
    }
    
    func textAreaViewRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: overallInsets)
    }
    
    private func updateBorder() {
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
        layer.borderColor = borderColor?.cgColor
    }
}


protocol FieldValidator {
    func validate(_ text: String) throws
}

extension NSRegularExpression : FieldValidator {
    func validate(_ text: String) throws {
        if self.numberOfMatches(in: text, options: [], range: NSRange(text.startIndex..<text.endIndex, in: text)) == 0 {
            throw OmiseTextFieldValidationError.invalidData
        }
    }
}

