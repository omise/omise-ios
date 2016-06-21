import Foundation
import UIKit

public class CardCVVTextField: OmiseTextField {
    private let maxLength = 3
    
    public override var isValid: Bool {
        return text?.characters.count >= maxLength
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public init() {
        super.init(frame: CGRectZero)
        setup()
    }
    
    func setup() {
        keyboardType = .NumberPad
        placeholder = "123"
        secureTextEntry = true
    }
}
