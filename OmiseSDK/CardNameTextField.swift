import Foundation
import UIKit


/// UITextField subclass for entering card holder's name.
@objc(OMSCardNameTextField) @IBDesignable
public class CardNameTextField: OmiseTextField {
    public override func validate() throws {
        try super.validate()
        
        guard let nameText = self.text, !nameText.isEmpty else {
            throw OmiseTextFieldValidationError.emptyText
        }
        
        let decimalString = nameText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let pan = PAN(decimalString)
        
        if (pan.isValid || (nameText.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil)) {
            throw OmiseTextFieldValidationError.invalidData
        }
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
        keyboardType = .default
        if #available(iOSApplicationExtension 10.0, *) {
            textContentType = .name
        }
    }
}
