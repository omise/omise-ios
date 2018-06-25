import Foundation
import UIKit


/// UITextField subclass for entering card holder's name.
@objc public class CardNameTextField: OmiseTextField {
    /// Boolean indicating wether current input is valid or not.
    public override var isValid: Bool {
        return !text.isNilOrEmpty
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
        keyboardType = .default
        
        placeholder = "John Doe"
    }
}
