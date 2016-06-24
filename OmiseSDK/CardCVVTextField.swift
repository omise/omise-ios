import Foundation
import UIKit

public class CardCVVTextField: OmiseTextField {
    private let validLengths = 3...4
    
    public override var isValid: Bool {
        return validLengths ~= text?.characters.count ?? 0
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
    
    override func textDidChange() {
        super.textDidChange()
        if text?.characters.count == 5 {
            guard let text = text else { return }
            self.text = String(text.characters.dropLast())
        }
    }
}
