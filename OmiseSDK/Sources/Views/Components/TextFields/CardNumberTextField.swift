import UIKit

/// UITextField subclass for entering the credit card number.
/// Automatically formats entered number into groups of four.
@IBDesignable
public class CardNumberTextField: OmiseTextField {

    /// The current PAN
    public var pan: PAN {
        return PAN(text ?? "")
    }
    
    /// Card brand determined from current input.
    public var cardBrand: CardBrand? {
        return pan.brand
    }
    
    public override var tokenizer: UITextInputTokenizer {
        return cardNumberStringTokenizer
    }
    
    public override var selectedTextRange: UITextRange? {
        didSet {
            guard let selectedTextRange = self.selectedTextRange else {
                return
            }
            
            let kerningIndexes = IndexSet(pan.suggestedSpaceFormattedIndexes.map { $0 - 1 })
            
            let kerningKey = NSAttributedString.Key.kern
            if kerningIndexes.contains(self.offset(from: beginningOfDocument, to: selectedTextRange.start)) {
                typingAttributes?[kerningKey] = 5
            } else {
                typingAttributes?.removeValue(forKey: kerningKey)
            }
        }
    }
    
    public override var delegate: UITextFieldDelegate? {
        get {
            return self
        }
        set {}
    }
    
    private lazy var cardNumberStringTokenizer = CreditCardNumberTextInputStringTokenizer(cardNumberTextField: self)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initializeInstance()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeInstance()
    }
    
    override init() {
        super.init(frame: CGRect.zero)
        initializeInstance()
    }
    
    private func initializeInstance() {
        keyboardType = .numberPad
        
        super.delegate = self
        
        updatePlaceholderTextColor()

        textContentType = .creditCardNumber
    }
    
    public override func validate() throws {
        try super.validate()
        if !pan.isValid {
            throw OmiseTextFieldValidationError.invalidData
        }
    }
    
    public override func becomeFirstResponder() -> Bool {
        let spacingIndexes = pan.suggestedSpaceFormattedIndexes
        if let attributedText = attributedText, spacingIndexes.contains(attributedText.length) {
            let formattingAttributedText = NSMutableAttributedString(attributedString: attributedText)
            let range = NSRange(location: attributedText.length - 1, length: 1)
            formattingAttributedText.addAttribute(.kern, value: 5, range: range)
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
            let range = NSRange(location: attributedText.length - 1, length: 1)
            formattingAttributedText.removeAttribute(.kern, range: range)
            self.attributedText = formattingAttributedText
        }
        
        return super.resignFirstResponder()
    }
    
    public override func paste(_ sender: Any?) {
        let pasteboard = UIPasteboard.general
        handlePaste(copiedText: pasteboard.string)
    }
    
    override func updatePlaceholderTextColor() {
        guard let attributedPlaceholder = attributedPlaceholder ?? placeholder.map(NSAttributedString.init(string:)) else {
            return
        }
        
        let formattingAttributedText = NSMutableAttributedString(attributedString: attributedPlaceholder)
        if let placeholderColor = self.placeholderTextColor {
            let formattingPlaceholderString = formattingAttributedText.string
            let range = NSRange(formattingPlaceholderString.startIndex..<formattingPlaceholderString.endIndex,
                                in: formattingPlaceholderString)
            formattingAttributedText.addAttribute(.foregroundColor, value: placeholderColor, range: range)
        }
        let kerningIndexes = IndexSet([3, 7, 11])
        kerningIndexes[kerningIndexes.indexRange(in: 0..<formattingAttributedText.length)].forEach {
            formattingAttributedText.addAttribute(NSAttributedString.Key.kern, value: 5, range: NSRange(location: $0, length: 1))
        }
        
        super.attributedPlaceholder = formattingAttributedText.copy() as? NSAttributedString
    }
    
    override func textDidChange() {
        super.textDidChange()
        
        guard let selectedTextRange = self.selectedTextRange else {
            return
        }
        
        updateTypingAttributes()
        
        if compare(selectedTextRange.start, to: endOfDocument) == ComparisonResult.orderedAscending, let attributedText = attributedText {
            let formattingAttributedText = NSMutableAttributedString(attributedString: attributedText)
            let formattingStartIndex = self.offset(from: beginningOfDocument,
                                                   to: self.position(from: selectedTextRange.start, offset: -1) ?? selectedTextRange.start)
            
            let kerningIndexes = IndexSet(pan.suggestedSpaceFormattedIndexes.map { $0 - 1 })
            
            let range = NSRange(location: formattingStartIndex, length: formattingAttributedText.length - formattingStartIndex)
            formattingAttributedText.removeAttribute(.kern, range: range)
            kerningIndexes[kerningIndexes.indexRange(in: formattingStartIndex..<formattingAttributedText.length)].forEach {
                formattingAttributedText.addAttribute(.kern, value: 5, range: NSRange(location: $0, length: 1))
            }
            
            self.attributedText = formattingAttributedText
            self.selectedTextRange = selectedTextRange
        }
    }
    
    private func updateTypingAttributes() {
        guard let selectedTextRange = self.selectedTextRange else {
            return
        }
        let kerningIndexes = IndexSet(pan.suggestedSpaceFormattedIndexes.map { $0 - 1 })
        
        let kerningKey = NSAttributedString.Key.kern
        if kerningIndexes.contains(self.offset(from: beginningOfDocument, to: selectedTextRange.start)) {
            typingAttributes?[kerningKey] = 5
        } else {
            typingAttributes?.removeValue(forKey: kerningKey)
        }

        if kerningIndexes.contains(self.offset(from: beginningOfDocument, to: selectedTextRange.start)) {
            typingAttributes?[NSAttributedString.Key.kern] = 5
        } else {
            typingAttributes?.removeValue(forKey: NSAttributedString.Key.kern)
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
            
            let directionValue = direction.rawValue
            if position == cardNumberTextField.beginningOfDocument && directionValue == UITextStorageDirection.backward.rawValue ||
                position == cardNumberTextField.endOfDocument && directionValue == UITextStorageDirection.forward.rawValue {
                return super.position(from: position, toBoundary: granularity, inDirection: direction)
            }
            
            let spacePositionIndexes = cardNumberTextField.pan.suggestedSpaceFormattedIndexes
            let currentIndex = cardNumberTextField.offset(from: cardNumberTextField.beginningOfDocument, to: position)
            
            if directionValue == UITextStorageDirection.backward.rawValue {
                return spacePositionIndexes.integerLessThan(currentIndex).flatMap {
                    cardNumberTextField.position(from: cardNumberTextField.beginningOfDocument, offset: $0)
                } ?? cardNumberTextField.beginningOfDocument
            } else if directionValue == UITextStorageDirection.forward.rawValue {
                return spacePositionIndexes.integerGreaterThan(currentIndex).flatMap {
                    cardNumberTextField.position(from: cardNumberTextField.beginningOfDocument, offset: $0)
                } ?? cardNumberTextField.endOfDocument
            } else {
                return super.position(from: position, toBoundary: granularity, inDirection: direction)
            }
        }
        
        override func isPosition(_ position: UITextPosition, atBoundary granularity: UITextGranularity, inDirection direction: UITextDirection) -> Bool {
            guard granularity == .word, let panString = cardNumberTextField.text else {
                return super.isPosition(position, atBoundary: granularity, inDirection: direction)
            }
            
            let directionValue = direction.rawValue
            if position == cardNumberTextField.beginningOfDocument && directionValue == UITextStorageDirection.backward.rawValue ||
                position == cardNumberTextField.endOfDocument && directionValue == UITextStorageDirection.forward.rawValue {
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
            
            let directionValue = direction.rawValue
            if position == cardNumberTextField.beginningOfDocument && directionValue == UITextStorageDirection.backward.rawValue ||
                position == cardNumberTextField.endOfDocument && directionValue == UITextStorageDirection.forward.rawValue {
                return super.rangeEnclosingPosition(position, with: granularity, inDirection: direction)
            }
            
            let spacePositionIndexes = cardNumberTextField.pan.suggestedSpaceFormattedIndexes.union([0, panString.count])
            let currentIndex = cardNumberTextField.offset(from: cardNumberTextField.beginningOfDocument, to: position)
            
            let beginningOfGroupTextPosition = spacePositionIndexes.integerLessThanOrEqualTo(currentIndex).flatMap {
                cardNumberTextField.position(from: cardNumberTextField.beginningOfDocument, offset: $0)
            }
            let endOfGroupTextPosition = spacePositionIndexes.integerGreaterThan(currentIndex).flatMap {
                cardNumberTextField.position(from: cardNumberTextField.beginningOfDocument, offset: $0)
            }
            
            if let beginningOfGroupTextPosition = beginningOfGroupTextPosition, let endOfGroupTextPosition = endOfGroupTextPosition {
                return cardNumberTextField.textRange(from: beginningOfGroupTextPosition, to: endOfGroupTextPosition)
            } else {
                return super.rangeEnclosingPosition(position, with: granularity, inDirection: direction)
            }
        }
    }
}

extension CardNumberTextField {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard range.length >= 0 else {
            return true
        }
        let maxLength = (pan.brand?.validLengths.upperBound ?? 19)
        
        return maxLength >= (self.text?.count ?? 0) - range.length + string.count
    }
}

extension CardNumberTextField {
    func handlePaste(copiedText: String?) {
        guard let copiedText = copiedText, let selectedTextRange = selectedTextRange else {
            return
        }
        
        let selectedTextLength = self.offset(from: selectedTextRange.start, to: selectedTextRange.end)
        let copiedPAN = copiedText.replacingOccurrences(
            of: "[^0-9]",
            with: "",
            options: .regularExpression,
            range: nil)
        
        // Using the current detected upper bound for the current brand will cause problems when swtching from
        // a brand that has an upper bound that is lower than that of the pasted detected card. (ex from visa to discover). So the upper bound will be set to the highest upper bound available for cards which is 19
        let panLength = 19 - (self.text?.count ?? 0) + selectedTextLength
        let maxPastingPANLength = min(copiedPAN.count, panLength)
        guard maxPastingPANLength > 0 else {
            return
        }
        replace(selectedTextRange,
                withText: String(copiedPAN[copiedPAN.startIndex..<copiedPAN.index(copiedPAN.startIndex, offsetBy: maxPastingPANLength)]))
        
        guard let attributedText = attributedText else {
            return
        }
        
        let formattingAttributedText = NSMutableAttributedString(attributedString: attributedText)
        let kerningIndexes = IndexSet(PAN.suggestedSpaceFormattedIndexesForPANPrefix(attributedText.string).map { $0 - 1 })
        
        let range = NSRange(location: 0, length: formattingAttributedText.length)
        formattingAttributedText.removeAttribute(.kern, range: range)
        kerningIndexes[kerningIndexes.indexRange(in: 0..<attributedText.length)].forEach {
            formattingAttributedText.addAttribute(NSAttributedString.Key.kern, value: 5, range: NSRange(location: $0, length: 1))
        }
        let previousSelectedTextRange = self.selectedTextRange
        self.attributedText = formattingAttributedText
        self.selectedTextRange = previousSelectedTextRange
    }
}
