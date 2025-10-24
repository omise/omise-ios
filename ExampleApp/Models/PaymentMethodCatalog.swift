import OmiseSDK

enum PaymentMethodCatalog {
    enum Group: CaseIterable {
        case installments
        case bankAndQR
        case digitalWallets
        case otherMethods
        
        var title: String {
            switch self {
            case .installments:
                return "Installments"
            case .bankAndQR:
                return "Bank & QR"
            case .digitalWallets:
                return "Digital Wallets"
            case .otherMethods:
                return "Other Methods"
            }
        }
    }
    
    struct Entry {
        let sourceType: SourceType
        let displayName: String
        let group: Group
    }
    
    private static let entries: [Entry] = [
        // Installments
        Entry(sourceType: .installmentBAY, displayName: "Installment - BAY", group: .installments),
        Entry(sourceType: .installmentFirstChoice, displayName: "Installment - First Choice", group: .installments),
        Entry(sourceType: .installmentBBL, displayName: "Installment - BBL", group: .installments),
        Entry(sourceType: .installmentMBB, displayName: "Installment - MBB", group: .installments),
        Entry(sourceType: .installmentKTC, displayName: "Installment - KTC", group: .installments),
        Entry(sourceType: .installmentKBank, displayName: "Installment - KBank", group: .installments),
        Entry(sourceType: .installmentSCB, displayName: "Installment - SCB", group: .installments),
        Entry(sourceType: .installmentTTB, displayName: "Installment - TTB", group: .installments),
        Entry(sourceType: .installmentUOB, displayName: "Installment - UOB", group: .installments),
        
        // Bank & QR
        Entry(sourceType: .internetBankingBAY, displayName: "Internet Banking - BAY", group: .bankAndQR),
        Entry(sourceType: .internetBankingBBL, displayName: "Internet Banking - BBL", group: .bankAndQR),
        Entry(sourceType: .mobileBankingBAY, displayName: "Mobile Banking - BAY", group: .bankAndQR),
        Entry(sourceType: .mobileBankingBBL, displayName: "Mobile Banking - BBL", group: .bankAndQR),
        Entry(sourceType: .mobileBankingKBank, displayName: "Mobile Banking - KBank", group: .bankAndQR),
        Entry(sourceType: .mobileBankingSCB, displayName: "Mobile Banking - SCB", group: .bankAndQR),
        Entry(sourceType: .mobileBankingKTB, displayName: "Mobile Banking - KTB", group: .bankAndQR),
        Entry(sourceType: .promptPay, displayName: "PromptPay", group: .bankAndQR),
        Entry(sourceType: .payNow, displayName: "PayNow", group: .bankAndQR),
        Entry(sourceType: .fpx, displayName: "FPX", group: .bankAndQR),
        Entry(sourceType: .maybankQRPay, displayName: "Maybank QRPay", group: .bankAndQR),
        Entry(sourceType: .duitNowQR, displayName: "DuitNow QR", group: .bankAndQR),
        Entry(sourceType: .duitNowOBW, displayName: "DuitNow Online Banking", group: .bankAndQR),
        
        // Digital Wallets
        Entry(sourceType: .alipay, displayName: "Alipay", group: .digitalWallets),
        Entry(sourceType: .alipayCN, displayName: "Alipay CN", group: .digitalWallets),
        Entry(sourceType: .alipayHK, displayName: "Alipay HK", group: .digitalWallets),
        Entry(sourceType: .payPay, displayName: "PayPay", group: .digitalWallets),
        Entry(sourceType: .atome, displayName: "Atome", group: .digitalWallets),
        Entry(sourceType: .dana, displayName: "DANA", group: .digitalWallets),
        Entry(sourceType: .gcash, displayName: "GCash", group: .digitalWallets),
        Entry(sourceType: .kakaoPay, displayName: "Kakao Pay", group: .digitalWallets),
        Entry(sourceType: .touchNGo, displayName: "Touch 'n Go", group: .digitalWallets),
        Entry(sourceType: .rabbitLinepay, displayName: "Rabbit LINE Pay", group: .digitalWallets),
        Entry(sourceType: .grabPay, displayName: "GrabPay", group: .digitalWallets),
        Entry(sourceType: .boost, displayName: "Boost", group: .digitalWallets),
        Entry(sourceType: .shopeePay, displayName: "ShopeePay", group: .digitalWallets),
        Entry(sourceType: .shopeePayJumpApp, displayName: "ShopeePay (Jump App)", group: .digitalWallets),
        Entry(sourceType: .trueMoneyWallet, displayName: "TrueMoney Wallet", group: .digitalWallets),
        Entry(sourceType: .trueMoneyJumpApp, displayName: "TrueMoney (Jump App)", group: .digitalWallets),
        Entry(sourceType: .weChat, displayName: "WeChat Pay", group: .digitalWallets),
        
        // Other Methods
        Entry(sourceType: .billPaymentTescoLotus, displayName: "Bill Payment - Tesco Lotus", group: .otherMethods),
        Entry(sourceType: .eContext, displayName: "eContext", group: .otherMethods),
        Entry(sourceType: .applePay, displayName: "Apple Pay", group: .otherMethods)
    ]
    
    private static let descriptorLookup: [SourceType: Entry] = {
        entries.reduce(into: [SourceType: Entry]()) { lookup, entry in
            lookup[entry.sourceType] = entry
        }
    }()
    
    private static let groupedEntries: [Group: [Entry]] = {
        Dictionary(grouping: entries, by: \.group)
            .mapValues { $0.sorted { $0.displayName < $1.displayName } }
    }()
    
    static func entries(in group: Group) -> [Entry] {
        groupedEntries[group] ?? []
    }
    
    static func displayName(for sourceType: SourceType) -> String {
        if let descriptor = descriptorLookup[sourceType] {
            return descriptor.displayName
        }
        
        let formatted = sourceType.rawValue.replacingOccurrences(of: "_", with: " ")
        return formatted.capitalized
    }
}

extension SourceType {
    var displayName: String { PaymentMethodCatalog.displayName(for: self) }
}
