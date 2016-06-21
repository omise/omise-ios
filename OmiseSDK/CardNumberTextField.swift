import Foundation

public class CardNumberTextField: OmiseTextField {
    private var updatingText = false
    
    private let separator = " "
    private let splitLength = 4
    private let maxLength = 18
    
    public var cardBrand: CardBrand? {
        return CardNumber.brand(text ?? "")
    }
    
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
        super.init(frame: CGRectZero)
        setup()
    }
    
    func setup() {
        keyboardType = .NumberPad
        placeholder = "0123 4567 8910 2345"
    }
    
    override func textDidChange() {
        super.textDidChange()
        guard !updatingText else { return }
        
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
