import Foundation

enum TestDataHelper {
    
    enum CreditCard {
        static let validVisa = "4242424242424242"
        static let validMastercard = "5555555555554444"
        static let validAmex = "378282246310005"
        
        static let cardName = "John Doe"
        static let cardCVV = "123"
        static let futureExpiryMonth = "12"
        static let futureExpiryYear = "30"
        static let validExpiryDate = "1225"
        
        static func getExpiryDate(month: String = "12", year: String = "25") -> String {
            return month + year
        }
    }
    
    enum PersonalInfo {
        static let validEmail = "test@example.com"
        static let anotherValidEmail = "john.doe@example.org"
        static let invalidEmail = "invalid-email"
        
        static let validPhoneNumber = "+66812345678"
        static let shortPhoneNumber = "123456"
        static let longPhoneNumber = "+1234567890123456"
    }
    
    enum Payment {
        static let testAmount = 100000
        static let currencyTHB = "thb"
        static let currencyUSD = "usd"
        static let description = "Test Payment for UI Testing"
        
        static func createPaymentDescription(amount: Int64, currency: String) -> String {
            let amountInDecimal = Double(amount) / 100.0
            return "Test payment of \(amountInDecimal) \(currency.uppercased())"
        }
    }
    
    enum ComprehensivePaymentMethods {
        static let allCategories = [
            "Credit Card",
            "Mobile Banking",
            "Installment",
            "E-Wallet",
            "QR Payment",
            "Online Banking",
            "Apple Pay"
        ]
        
        static let mobileBankingApps = [
            ("SCB", "SCB Easy"),
            ("KBank", "K PLUS"),
            ("BBL", "Bualuang mBanking"),
            ("Krungsri", "KMA"),
            ("KTB", "KTB Next"),
            ("KTC", "KTC Touch"),
            ("TTB", "TTB Touch"),
            ("UOB", "TMRW"),
            ("OCBC", "OCBC Digital")
        ]
        
        static let installmentProviders = [
            ("BBL", "Bangkok Bank"),
            ("KBank", "Kasikorn Bank"),
            ("SCB", "Siam Commercial Bank"),
            ("Krungsri", "BAY"),
            ("KTC", "Krungthai Card"),
            ("MBB", "Maybank"),
            ("TTB", "TMBThanachart"),
            ("UOB", "United Overseas Bank"),
            ("First Choice", "Krungsri First Choice")
        ]
        
        static let ewalletProviders = [
            "GrabPay",
            "Alipay",
            "Alipay China",
            "TrueMoney Wallet",
            "ShopeePay",
            "ShopeePay Jump App",
            "Touch 'n Go",
            "DANA",
            "GCash",
            "KakaoPay",
            "PayPay",
            "WeChat Pay",
            "Rabbit LINE Pay",
            "DuitNow OBW"
        ]
        
        static let thaiMethods = ["PromptPay", "TrueMoney Wallet", "Mobile Banking"]
        static let malaysianMethods = ["Touch 'n Go", "FPX", "DuitNow"]
        static let singaporeMethods = ["PayNow", "GrabPay"]
        static let japaneseMethods = ["PayPay", "Alipay", "eContext"]
    }
    
    enum CapabilityValidation {
        static let minimumExpectedPaymentMethods = 10
        static let minimumExpectedMobileBanking = 3
        static let minimumExpectedInstallments = 3
        static let alwaysAvailableMethods = ["Credit Card"]
        static let expectedWithCapability = [
            "Mobile Banking",
            "Installment",
            "GrabPay",
            "Alipay"
        ]
    }
    
    static func validateCardNumber(_ cardNumber: String) -> Bool {
        let cleanedCardNumber = cardNumber.replacingOccurrences(of: "\\D", with: "")
        guard cleanedCardNumber.count >= 13 && cleanedCardNumber.count <= 19 else {
            return false
        }
        
        var sum = 0
        let reversedDigits = cleanedCardNumber.reversed().compactMap { Int(String($0)) }
        
        for (index, digit) in reversedDigits.enumerated() {
            if index % 2 == 1 {
                let doubled = digit * 2
                sum += doubled > 9 ? doubled - 9 : doubled
            } else {
                sum += digit
            }
        }
        
        return sum.isMultiple(of: 10)
    }
    
    static func validateExpiryDate(_ expiryDate: String) -> Bool {
        guard expiryDate.count == 4 else { return false }
        
        let monthStr = String(expiryDate.prefix(2))
        let yearStr = String(expiryDate.suffix(2))
        
        guard let month = Int(monthStr), let year = Int(yearStr) else { return false }
        guard month >= 1 && month <= 12 else { return false }
        
        let currentYear = Calendar.current.component(.year, from: Date()) % 100
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        if year < currentYear || (year == currentYear && month < currentMonth) {
            return false
        }
        
        return true
    }
    
    static func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    static func validateCVV(_ cvv: String) -> Bool {
        return cvv.count >= 3 && cvv.count <= 4 && cvv.allSatisfy { $0.isNumber }
    }
}
