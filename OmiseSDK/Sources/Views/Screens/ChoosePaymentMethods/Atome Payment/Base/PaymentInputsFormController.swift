import UIKit

class PaymentInputsFormController<Field: PaymenFormtInputProtocol & CaseIterable & Hashable>: PaymentFormController {

    private var fields: [Field: String] = [:]

    init(fields: [Field: String] = [:]) {
        self.fields = fields
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    subscript(field: Field) -> String {
        get { fields[field] ?? "" }
        set { fields[field] = newValue }
    }
}
