import Foundation
import UIKit

public class CardNameTextField: OmiseTextField {
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
        placeholder = "Full name"
    }
}