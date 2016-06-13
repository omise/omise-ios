import Foundation
import UIKit

public class NameOnCardTextField: OmiseTextField {
    var name: String = ""
    
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