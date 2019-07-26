import Foundation
import UIKit


/// UITextField subclass for entering card holder's name.
@objc(OMSCardNameTextField) @IBDesignable
public class CardNameTextField: OmiseTextField {
    /// Boolean indicating wether current input is valid or not.
    public override var isValid: Bool {
        return !text.isNilOrEmpty
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
