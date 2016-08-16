import Foundation
import UIKit


/// A UITextField subclass used for inputing the card holder name.
public class CardNameTextField: OmiseTextField {
    /// A boolean value indicates that the current card number holder name is valid or not.
    public override var isValid: Bool {
        return !(text ?? "").isEmpty
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
        keyboardType = .Default
        
        // TODO: Localize place holder
        placeholder = "John Doe"
    }
}