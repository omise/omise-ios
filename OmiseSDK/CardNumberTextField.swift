import Foundation

public class CardNumberTextField: OmiseTextField {
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
    }
    
//    override func textField(textField: OmiseTextField, textDidChanged insertedText: String) {
//        if insertedText.characters.count > maxLength {
//            cardBrand = CardNumber.brand(insertedText)
//            number = CardNumber.normalize(insertedText)
//            valid = CardNumber.validate(insertedText)
//            validationDelegate?.textField(self, didChangeValidity: valid)
//            return
//        }
//        
//        var cardNumberString = ""
//        var text = insertedText
//        text = text.stringByReplacingOccurrencesOfString(separator, withString: "", options: .LiteralSearch, range: nil)
//        while text.characters.count > 0 {
//            let index = text.startIndex.advancedBy(min(text.characters.count, splitLength))
//            let subString = text.substringToIndex(index)
//            cardNumberString += subString
//            
//            if subString.characters.count == splitLength {
//                cardNumberString += separator
//            }
//            
//            text = text.substringFromIndex(index)
//        }
//        
//        textField.text = cardNumberString
//        
//        cardBrand = CardNumber.brand(cardNumberString)
//        number = CardNumber.normalize(cardNumberString)
//        valid = CardNumber.validate(cardNumberString)
//        validationDelegate?.textField(self, didChangeValidity: valid)
//    }
    
//    override func textField(textField: OmiseTextField, textDidDeleted deletedText: String) {
//        cardBrand = CardNumber.brand(deletedText)
//        number = CardNumber.normalize(deletedText)
//        valid = CardNumber.validate(deletedText)
//        validationDelegate?.textField(self, didChangeValidity: valid)
//    }
    
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//        if string.characters.count == 0 && range.length == 1 {
//            if range.location == maxLength {
//                deleteBackward()
//            } else {
//                switch range.location {
//                case 4:
//                    deleteBackward()
//                    break
//                case 9:
//                    deleteBackward()
//                    break
//                case 14:
//                    deleteBackward()
//                    break
//                default:
//                    break
//                }
//            }
//        }
//        
//        if(range.length + range.location > maxLength) {
//            return false
//        }
//        
//        return true
//    }
}