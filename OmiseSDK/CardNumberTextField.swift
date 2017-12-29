import Foundation


/// UITextField subclass for entering the credit card number.
/// Automatically formats entered number into groups of four.
@objc public class CardNumberTextField: OmiseTextField {
    private var updatingText = false
    private let maxLength = 19
    
    /// Card brand determined from current input.
    public var cardBrand: CardBrand? {
        return CardNumber.brand(of: string)
    }
    
    /// Boolean indicating wether current input is valid or not.
    public override var isValid: Bool {
        return CardNumber.validate(string)
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
        updatingText = true
        defer { updatingText = false }

        let previousSpaceCount = previousText.split(separator: " ").count
        let previousStringCount = previousText.count
        let previousTextRange = selectedTextRange
        self.text = trim(formattedCardNumber: CardNumber.format(string))
        self.text = text
        let newSpaceCount = self.string.split(separator: " ").count
        let newStringCount = self.string.count

        if let selectedTextRange = previousTextRange {
            let isDeleting = newSpaceCount < previousSpaceCount || newStringCount < previousStringCount
            if isDeleting {
                if let newPosition = self.position(from: selectedTextRange.start, offset: 0) {
                    self.selectedTextRange = self.textRange(from: newPosition, to: newPosition)
                    return
                }
            } else {
                if let newPosition = self.position(from: selectedTextRange.start, offset: 0) {
                    self.selectedTextRange = self.textRange(from: newPosition, to: newPosition)
                }
            }
            
            if self.characterBeforeCursor() == " " {
                if let newPosition = self.position(from: selectedTextRange.start, offset: 1) {
                    self.selectedTextRange = self.textRange(from: newPosition, to: newPosition)
                }
            }
        }
    }
    
    func trim(formattedCardNumber cardNumber: String) -> String {
        if cardNumber.count <= maxLength {
            return cardNumber
        }

        let endIndex = cardNumber.index(cardNumber.startIndex, offsetBy: maxLength)
        return String(cardNumber[..<endIndex])
    }
}
