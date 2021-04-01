import Foundation
import UIKit

/// UITextField subclass for entering card's CVV number.
@IBDesignable
@objc(OMSCardCVVTextField) public class CardCVVTextField: OmiseTextField {
    private let validLengths = 3...4
    
    @available(iOS, unavailable)
    public override var delegate: UITextFieldDelegate? {
        get {
            return self
        }
        set {} // swiftlint:disable:this unused_setter_value
    }
    
    public override var keyboardType: UIKeyboardType {
        didSet {
            super.keyboardType = .numberPad
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initializeInstance()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeInstance()
    }
    
    public override init() {
        super.init(frame: CGRect.zero)
        initializeInstance()
    }
    
    private func initializeInstance() {
        super.keyboardType = .numberPad
        super.delegate = self
        
        validator = try? NSRegularExpression(pattern: "\\d{3,4}", options: [])
    }
    
    public override func validate() throws {
        try super.validate()
        
        guard let text = self.text else {
            throw OmiseTextFieldValidationError.emptyText
        }
        if !(validLengths ~= text.count) {
            throw OmiseTextFieldValidationError.invalidData
        }
    }
}

extension CardCVVTextField: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard range.length >= 0 else {
            return true
        }
        let maxLength = 4
        
        return maxLength >= (self.text?.count ?? 0) - range.length + string.count
    }
}
