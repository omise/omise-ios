import Foundation


/// UITextField subclass for entering the credit card number.
/// Automatically formats entered number into groups of four.
@objc public class CardNumberTextField: OmiseTextField {
    private var updatingText = false
    private let maxLength = 19
    
    /// Card brand determined from current input.
    public var cardBrand: CardBrand? {
        return CardNumber.brand(of: text ?? "")
    }
    
    /// Boolean indicating wether current input is valid or not.
    public override var isValid: Bool {
        return CardNumber.validate(text ?? "")
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    func setup() {
        keyboardType = .numberPad
        placeholder = "0123 4567 8910 2345"
    }
    
    override func textDidChange() {
        super.textDidChange()
        guard !updatingText else { return }
        
        if (text?.characters.count ?? 0) > maxLength {
            updatingText = true
            defer { updatingText = false }
            
            text = previousText
            text = text // overwrite previousText, since it now contains invalid text.
            return
        }
        
        // TODO: Maintain caret position correctly, esp. when in the middle of the text.
        let prevLength = previousText?.characters.count ?? 0
        let newLength = text?.characters.count ?? 0
        
        if prevLength != newLength {
            if let text = self.text {
                updatingText = true
                defer { updatingText = false }
                self.text = CardNumber.format(text)
            }
        }
    }
}
