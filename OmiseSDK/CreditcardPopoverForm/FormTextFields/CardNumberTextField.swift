import Foundation

public class CardNumberTextField: OmiseTextField {
    var number: String = ""
    var cardBrand: CardBrand?
    private let separator = " "
    private let splitLength = 4
    private let maxLength = 18
    
    // MARK: Initial
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init() {
        super.init(frame: CGRectZero)
        setup()
    }
    
    // MARK: Setup
    func setup() {
        keyboardType = .NumberPad
        placeholder = "0123 4567 8910 2345"
    }
    
    override func textField(textField: OmiseTextField, textDidChanged insertedText: String) {
        if insertedText.characters.count > maxLength {
            cardBrand = PANUtils.brand(insertedText)
            number = PANUtils.normalize(insertedText)
            valid = PANUtils.validate(insertedText)
            omiseValidatorDelegate?.textFieldDidValidated(self)
            return
        }
        
        var cardNumberString = ""
        var text = insertedText
        text = text.stringByReplacingOccurrencesOfString(separator, withString: "", options: .LiteralSearch, range: nil)
        while text.characters.count > 0 {
            let index = text.startIndex.advancedBy(min(text.characters.count, splitLength))
            let subString = text.substringToIndex(index)
            cardNumberString += subString
            
            if subString.characters.count == splitLength {
                cardNumberString += separator
            }
            
            text = text.substringFromIndex(index)
        }
        
        textField.text = cardNumberString
        
        cardBrand = PANUtils.brand(cardNumberString)
        number = PANUtils.normalize(cardNumberString)
        valid = PANUtils.validate(cardNumberString)
        omiseValidatorDelegate?.textFieldDidValidated(self)
    }
    
    override func textField(textField: OmiseTextField, textDidDeleted deletedText: String) {
        cardBrand = PANUtils.brand(deletedText)
        number = PANUtils.normalize(deletedText)
        valid = PANUtils.validate(deletedText)
        omiseValidatorDelegate?.textFieldDidValidated(self)
    }
    
    // MARK: UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string.characters.count == 0 && range.length == 1 {
            if range.location == maxLength {
                deleteBackward()
            } else {
                switch range.location {
                case 4:
                    deleteBackward()
                    break
                case 9:
                    deleteBackward()
                    break
                case 14:
                    deleteBackward()
                    break
                default:
                    break
                }
            }
        }
        
        if(range.length + range.location > maxLength) {
            return false
        }
        
        return true
    }
}