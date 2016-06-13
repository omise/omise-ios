import Foundation

public protocol OmiseFormValidatorDelegate {
    func textFieldDidValidated(textField: OmiseTextField)
}

public class OmiseFormValidator {
    class func validateForms(fields: [OmiseTextField]) -> Bool {
        var valid = true
        for field in fields {
            if !(field.valid) {
                valid = false
                break
            }
        }
        
        return valid
    }
}