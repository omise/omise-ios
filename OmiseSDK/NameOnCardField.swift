import Foundation
import UIKit

public class NameOnCardTextField: OmiseTextField {
    var name: String = ""
    
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
        keyboardType = .Default
        placeholder = "Full name"
    }
    
    override func textField(textField: OmiseTextField, textDidChanged insertedText: String) {
        name = insertedText
        valid = !insertedText.isEmpty
    }
    
    override func textField(textField: OmiseTextField, textDidDeleted deletedText: String) {
        valid = !deletedText.isEmpty
    }
}