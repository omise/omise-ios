import UIKit

// MARK: - EmailTextField
@IBDesignable
public class EmailTextField: OmiseTextField {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initializeInstance()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeInstance()
    }
    
    override init() {
        super.init(frame: CGRect.zero)
        initializeInstance()
    }
    
    private func initializeInstance() {
        keyboardType = .emailAddress
        autocapitalizationType = .none
        autocorrectionType = .no
        textContentType = .emailAddress
        placeholder = "email@example.com"
        
        validator = try? NSRegularExpression(pattern: "\\A[\\w\\-\\.]+@[\\w\\-\\.]+\\.[a-zA-Z]{2,}\\s?\\z", options: [])
    }
    
    public override func validate() throws {
        try super.validate()
        
        guard let _ = self.text else {
            throw OmiseTextFieldValidationError.emptyText
        }
    }
}
