import Foundation


/// UITextField subclass for entering the credit card number.
/// Automatically formats entered number into groups of four.
@objc public class CardNumberTextField: OmiseTextField {

    lazy private var cardNumberStringTokenizer: CardNumberTextField.CreditCardNumberTextInputStringTokenizer = CreditCardNumberTextInputStringTokenizer.init(cardNumberTextField: self)
    
    public override var tokenizer: UITextInputTokenizer {
        return cardNumberStringTokenizer
    }
    
    override public var selectedTextRange: UITextRange? {
        didSet {
            guard let selectedTextRange = self.selectedTextRange else {
                return
            }
            
            let kerningIndexes = IndexSet(pan.suggestedSpaceFormattedIndexes.map({ $0 - 1 }))
            
            if kerningIndexes.contains(self.offset(from: beginningOfDocument, to: selectedTextRange.start)) {
                typingAttributes?[NSAttributedStringKey.kern.rawValue] = 5
            } else {
                typingAttributes?.removeValue(forKey: NSAttributedStringKey.kern.rawValue)
            }
        }
    }
    
    public var pan: PAN {
        return PAN(text ?? "")
    }
    
    /// Card brand determined from current input.
    public var cardBrand: CardBrand? {
        return pan.brand
    }
    
    /// Boolean indicating wether current input is valid or not.
    public override var isValid: Bool {
        return pan.isValid
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initializeInstance()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeInstance()
    }
    
    override init() {
        super.init(frame: CGRect.zero)
        initializeInstance()
    }
    
    private func initializeInstance() {
        keyboardType = .numberPad
        
        if #available(iOS 10.0, *) {
            textContentType = .creditCardNumber
        }
        
        placeholder = "1234567890123456"
        
        guard let attributedPlaceholder = attributedPlaceholder else {
            placeholder = "1234 5678 9012 3456"
            return
        }
        let formattingAttributedText = NSMutableAttributedString(attributedString: attributedPlaceholder)
        
        let kerningIndexes = IndexSet([3, 7, 11])
        kerningIndexes.forEach({
            formattingAttributedText.addAttribute(NSAttributedStringKey.kern, value: 5, range: NSRange(location: $0, length: 1))
        })
        self.attributedPlaceholder = formattingAttributedText
    }
    
    override func textDidChange() {
        super.textDidChange()
        
        guard let selectedTextRange = self.selectedTextRange else {
            return
        }
        
        updateTypingAttributes()
        
        if compare(selectedTextRange.start, to: endOfDocument) == ComparisonResult.orderedAscending, let attributedText = attributedText {
            let formattingAttributedText = NSMutableAttributedString(attributedString: attributedText)
            let formattingStartIndex = self.offset(from: beginningOfDocument, to: self.position(from: selectedTextRange.start, offset: -1) ?? selectedTextRange.start)
            
            let kerningIndexes = IndexSet(pan.suggestedSpaceFormattedIndexes.map({ $0 - 1 }))
            
            formattingAttributedText.removeAttribute(NSAttributedStringKey.kern, range: NSRange(location: formattingStartIndex, length: formattingAttributedText.length - formattingStartIndex))
            kerningIndexes[kerningIndexes.indexRange(in: formattingStartIndex..<formattingAttributedText.length)].forEach({
                formattingAttributedText.addAttribute(NSAttributedStringKey.kern, value: 5, range: NSRange(location: $0, length: 1))
            })
            
            self.attributedText = formattingAttributedText
            self.selectedTextRange = selectedTextRange
        }
    }
    
    public override func becomeFirstResponder() -> Bool {
        let spacingIndexes = pan.suggestedSpaceFormattedIndexes
        if let attributedText = attributedText, spacingIndexes.contains(attributedText.length) {
            let formattingAttributedText = NSMutableAttributedString(attributedString: attributedText)
            formattingAttributedText.addAttribute(NSAttributedStringKey.kern, value: 5, range: NSRange(location: attributedText.length - 1, length: 1))
            self.attributedText = formattingAttributedText
        }
        
        defer {
            updateTypingAttributes()
        }
        
        return super.becomeFirstResponder()
    }
    
    public override func resignFirstResponder() -> Bool {
        let spacingIndexes = pan.suggestedSpaceFormattedIndexes
        if let attributedText = attributedText, spacingIndexes.contains(attributedText.length) {
            let formattingAttributedText = NSMutableAttributedString(attributedString: attributedText)
            formattingAttributedText.removeAttribute(NSAttributedStringKey.kern, range: NSRange(location: attributedText.length - 1, length: 1))
            self.attributedText = formattingAttributedText
        }
        
        return super.resignFirstResponder()
    }
    
    public override func replace(_ range: UITextRange, withText text: String) {
        super.replace(range, withText: text)
    }
    
    public override func paste(_ sender: Any?) {
        let pasteboard = UIPasteboard.general
        
        guard let copiedText = pasteboard.string, let selectedTextRange = selectedTextRange else {
            return
        }
        let pan = copiedText.replacingOccurrences(
            of: "[^0-9]",
            with: "",
            options: .regularExpression,
            range: nil)
        
        replace(selectedTextRange, withText: pan)
        
        guard let attributedText = attributedText else {
            return
        }
        
        let formattingAttributedText = NSMutableAttributedString(attributedString: attributedText)
        let kerningIndexes = IndexSet(PAN.suggestedSpaceFormattedIndexesForPANPrefix(attributedText.string).map({ $0 - 1 }))
        
        formattingAttributedText.removeAttribute(NSAttributedStringKey.kern, range: NSRange(location: 0, length: formattingAttributedText.length))
        kerningIndexes.forEach({
            formattingAttributedText.addAttribute(NSAttributedStringKey.kern, value: 5, range: NSRange(location: $0, length: 1))
        })
        let previousSelectedTextRange = self.selectedTextRange
        self.attributedText = formattingAttributedText
        self.selectedTextRange = previousSelectedTextRange
    }
    
    private func updateTypingAttributes() {
        guard let selectedTextRange = self.selectedTextRange else {
            return
        }
        let kerningIndexes = IndexSet(pan.suggestedSpaceFormattedIndexes.map({ $0 - 1 }))
        if kerningIndexes.contains(self.offset(from: beginningOfDocument, to: selectedTextRange.start)) {
            typingAttributes?[NSAttributedStringKey.kern.rawValue] = 5
        } else {
            typingAttributes?.removeValue(forKey: NSAttributedStringKey.kern.rawValue)
        }
    }
    
    class CreditCardNumberTextInputStringTokenizer: UITextInputStringTokenizer {
        
        unowned let cardNumberTextField: CardNumberTextField
        
        init(cardNumberTextField: CardNumberTextField) {
            self.cardNumberTextField = cardNumberTextField
            super.init(textInput: cardNumberTextField)
        }
        
        override func position(from position: UITextPosition, toBoundary granularity: UITextGranularity, inDirection direction: UITextDirection) -> UITextPosition? {
            guard granularity == .word else {
                return super.position(from: position, toBoundary: granularity, inDirection: direction)
            }
            
            if position == cardNumberTextField.beginningOfDocument && direction == UITextStorageDirection.backward.rawValue ||
                position == cardNumberTextField.endOfDocument && direction == UITextStorageDirection.forward.rawValue {
                return super.position(from: position, toBoundary: granularity, inDirection: direction)
            }
            
            let spacePositionIndexes = cardNumberTextField.pan.suggestedSpaceFormattedIndexes
            let currentIndex = cardNumberTextField.offset(from: cardNumberTextField.beginningOfDocument, to: position)
            
            if direction == UITextStorageDirection.backward.rawValue {
                return spacePositionIndexes.integerLessThan(currentIndex).flatMap({ cardNumberTextField.position(from: cardNumberTextField.beginningOfDocument, offset: $0) }) ?? cardNumberTextField.beginningOfDocument
            } else if direction == UITextStorageDirection.forward.rawValue {
                return spacePositionIndexes.integerGreaterThan(currentIndex).flatMap({ cardNumberTextField.position(from: cardNumberTextField.beginningOfDocument, offset: $0) }) ?? cardNumberTextField.endOfDocument
            } else {
                return super.position(from: position, toBoundary: granularity, inDirection: direction)
            }
        }
        
        override func isPosition(_ position: UITextPosition, atBoundary granularity: UITextGranularity, inDirection direction: UITextDirection) -> Bool {
            guard granularity == .word, let panString = cardNumberTextField.text else {
                return super.isPosition(position, atBoundary: granularity, inDirection: direction)
            }
            
            if position == cardNumberTextField.beginningOfDocument && direction == UITextStorageDirection.backward.rawValue ||
                position == cardNumberTextField.endOfDocument && direction == UITextStorageDirection.forward.rawValue {
                return super.isPosition(position, atBoundary: granularity, inDirection: direction)
            }
            
            let spacePositionIndexes = PAN.suggestedSpaceFormattedIndexesForPANPrefix(panString).union([0, panString.count])
            let currentIndex = cardNumberTextField.offset(from: cardNumberTextField.beginningOfDocument, to: position)
            
            return spacePositionIndexes.contains(currentIndex)
        }
        
        override func isPosition(_ position: UITextPosition, withinTextUnit granularity: UITextGranularity, inDirection direction: UITextDirection) -> Bool {
            guard granularity == .word else {
                return super.isPosition(position, atBoundary: granularity, inDirection: direction)
            }
            
            return true
        }
        
        override func rangeEnclosingPosition(_ position: UITextPosition, with granularity: UITextGranularity, inDirection direction: UITextDirection) -> UITextRange? {
            guard granularity == .word, let panString = cardNumberTextField.text else {
                return super.rangeEnclosingPosition(position, with: granularity, inDirection: direction)
            }
            
            if position == cardNumberTextField.beginningOfDocument && direction == UITextStorageDirection.backward.rawValue ||
                position == cardNumberTextField.endOfDocument && direction == UITextStorageDirection.forward.rawValue {
                return super.rangeEnclosingPosition(position, with: granularity, inDirection: direction)
            }
            
            let spacePositionIndexes = cardNumberTextField.pan.suggestedSpaceFormattedIndexes.union([0, panString.count])
            let currentIndex = cardNumberTextField.offset(from: cardNumberTextField.beginningOfDocument, to: position)
            
            if let beginningOfGroupTextPosition =
                spacePositionIndexes.integerLessThanOrEqualTo(currentIndex).flatMap({ cardNumberTextField.position(from: cardNumberTextField.beginningOfDocument, offset: $0) }),
                let endOfGroupTextPosition =
                spacePositionIndexes.integerGreaterThan(currentIndex).flatMap({ cardNumberTextField.position(from: cardNumberTextField.beginningOfDocument, offset: $0) }) {
                return cardNumberTextField.textRange(from: beginningOfGroupTextPosition, to: endOfGroupTextPosition)
            } else {
                return super.rangeEnclosingPosition(position, with: granularity, inDirection: direction)
            }
        }
    }
}

