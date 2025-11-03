import Foundation
import PassKit
@testable import OmiseSDK

// MARK: - PKPayment
class MockPKPayment: PKPayment {
    override var token: PKPaymentToken {
        return MockPKPaymentToken()
    }
    
    override var billingContact: PKContact? {
        
        let postalAddress = CNMutablePostalAddress()
        postalAddress.street = "123 Main St"
        postalAddress.city = "Springfield"
        postalAddress.state = "IL"
        postalAddress.postalCode = "62704"
        postalAddress.country = "USA"
        
        var name = PersonNameComponents()
        name.familyName = "Doe"
        name.givenName = "John"
        name.namePrefix = "Mr."
        
        let contact = PKContact()
        contact.name = name
        contact.phoneNumber = CNPhoneNumber(stringValue: "0943443434")
        contact.emailAddress = "johndoe@example.com"
        contact.postalAddress = postalAddress
        return contact
    }
}

// MARK: - PKPaymentToken
class MockPKPaymentToken: PKPaymentToken {
    
    // Provide a dummy paymentData
    override var paymentData: Data {
        Data("mock_payment_data".utf8)
    }
    
    override var paymentMethod: PKPaymentMethod {
        MockPKPaymentMethod()
    }
    
    override var transactionIdentifier: String {
        "mock_tx_id"
    }
}

// MARK: - PKPaymentMethod
class MockPKPaymentMethod: PKPaymentMethod {
    override var network: PKPaymentNetwork? {
        return .visa
    }
}

// MARK: - PaymentAuthorizationController
class MockPaymentAuthorizationController: PaymentAuthorizationControllerProtocol {
    var delegate: PKPaymentAuthorizationControllerDelegate?
    var presentSheetCalled = false
    var dismissSheetCalled = false
    var shouldMakePresentFail: Bool = false
    
    // Allow overriding presentation behavior
    var presentSheet: ((@escaping (Bool) -> Void) -> Void)?
    
    func presentSheet(completion: ((Bool) -> Void)?) {
        if shouldMakePresentFail {
            presentSheetCalled = false
            completion?(false)
            return
        }
        presentSheetCalled = true
        if let presentSheet = presentSheet {
            presentSheet { success in
                completion?(success)
            }
        } else {
            // Default successful presentation
            completion?(true)
        }
    }
    
    func dismissSheet(completion: (() -> Void)?) {
        dismissSheetCalled = true
        completion?()
    }
}
