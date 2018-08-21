import Foundation
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
@objc @IBDesignable public class OmiseTextField: UITextField {
    public var style: TextFieldStyle = .plain {
        didSet {
            setNeedsLayout()
        }
    }
    
    @objc @IBInspectable var borderWidth: CGFloat {
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
            case 0:
                style = .plain
            case let value:
                style = .border(width: value)
            }
        }
    }
    
    @objc @IBInspectable var borderColor: UIColor? {
        didSet {
            updateBorder()
        }
    }
    
    @objc @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            updateBorder()
        }
    }
    
    @IBInspectable @objc var errorTextColor: UIColor? {
        didSet {
            updateTextColor()
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
        super.textColor = isValid || isFirstResponder ? normalTextColor ?? .black : errorTextColor
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
        if text.isNilOrEmpty {
            throw OmiseTextFieldValidationError.emptyText
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
}

extension OmiseTextField {
    private var overallInsets: UIEdgeInsets {
        let edgeInsets: UIEdgeInsets
        switch style {
        case .plain:
            edgeInsets = UIEdgeInsets.zero
        case .border(width: let width):
            edgeInsets = UIEdgeInsetsMake(
                layoutMargins.top + width,
                layoutMargins.left + width,
                layoutMargins.bottom + width,
                layoutMargins.right + width
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
        return UIEdgeInsetsInsetRect(bounds, overallInsets)
    }
    
    private func updateBorder() {
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
        layer.borderColor = borderColor?.cgColor
    }
}

