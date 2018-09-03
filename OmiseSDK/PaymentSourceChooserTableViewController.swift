import UIKit


public enum PaymentChooserCell: StaticElementIterable, Equatable {
    case creditCard
    case installment
    case internetBanking
    case tescoLotus
    case conbini
    case payEasy
    case netBanking
    case alipay
    
    public static var allCases: [PaymentChooserCell] {
        return [
            .creditCard,
            .installment,
            .internetBanking,
            .tescoLotus,
            .conbini,
            .payEasy,
            .netBanking,
            .alipay,
        ]
    }
}


@objc(OMSPaymentSourceChooserTableViewController)
public class PaymentSourceChooserTableViewController: AdaptableStaticTableViewController<PaymentChooserCell> {
   
    @objc public var showsCreditCardPayment: Bool = true
    @objc public var allowedPaymentMethods: [OMSSourceTypeValue] = PaymentSourceChooserTableViewController.defaultAvailablePaymentMethods {
        didSet {
            showingValues = PaymentChooserCell.allCases.filter({
                switch $0 {
                case .creditCard:
                    return showsCreditCardPayment
                case .installment:
                    return allowedPaymentMethods.hasInstallmentSource
                case .internetBanking:
                    return allowedPaymentMethods.hasInternetBankingSource
                case .tescoLotus:
                    return allowedPaymentMethods.hasTescoLotusSource
                case .conbini, .payEasy, .netBanking:
                    return allowedPaymentMethods.hasEContextSource
                case .alipay:
                    return allowedPaymentMethods.hasAlipaySource
                }
            })
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        showingValues = PaymentChooserCell.allCases.filter({
            switch $0 {
            case .creditCard:
                return showsCreditCardPayment
            case .installment:
                return allowedPaymentMethods.hasInstallmentSource
            case .internetBanking:
                return allowedPaymentMethods.hasInternetBankingSource
            case .tescoLotus:
                return allowedPaymentMethods.hasTescoLotusSource
            case .conbini, .payEasy, .netBanking:
                return allowedPaymentMethods.hasEContextSource
            case .alipay:
                return allowedPaymentMethods.hasAlipaySource
            }
        })
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier, segue.destination) {
        case ("GoToInternetBankingChooserSegue"?, let controller as InternetBankingSourceChooserTableViewController):
            controller.showingValues = allowedPaymentMethods.compactMap({ $0.internetBankingSource })
        case ("GoToInstallmentBrandChooserSegue"?, let controller as InstallmentBankingSourceChooserTableViewController):
            controller.showingValues = allowedPaymentMethods.compactMap({ $0.installmentBrand })
        case (_, let controller as InternetBankingSourceChooserTableViewController):
            controller.showingValues = []
            
        default:
            break
        }
        
    }
    
    public override func staticIndexPath(forValue value: PaymentChooserCell) -> IndexPath {
        switch value {
        case .creditCard:
            return IndexPath(row: 0, section: 0)
        case .installment:
            return IndexPath(row: 1, section: 0)
        case .internetBanking:
            return IndexPath(row: 2, section: 0)
        case .tescoLotus:
            return IndexPath(row: 3, section: 0)
        case .conbini:
            return IndexPath(row: 4, section: 0)
        case .payEasy:
            return IndexPath(row: 5, section: 0)
        case .netBanking:
            return IndexPath(row: 6, section: 0)
        case .alipay:
            return IndexPath(row: 7, section: 0)
        }
    }
}


extension Array where Element == OMSSourceTypeValue {
    public var hasInternetBankingSource: Bool {
        return self.contains(where: { $0.isInternetBankingSource })
    }
    
    public var hasInstallmentSource: Bool {
        return self.contains(where: { $0.isInstallmentSource })
    }
    
    public var hasTescoLotusSource: Bool {
        return self.contains(.billPaymentTescoLotus)
    }
    
    public var hasAlipaySource: Bool {
        return self.contains(.alipay)
    }
    
    public var hasEContextSource: Bool {
        return self.contains(.eContext)
    }
}


extension PaymentSourceChooserTableViewController {
    public static let defaultAvailablePaymentMethods: [OMSSourceTypeValue] = [
        .internetBankingBAY,
        .internetBankingKTB,
        .internetBankingSCB,
        .internetBankingBBL,
        .alipay,
        .billPaymentTescoLotus,
        .installmentBAY,
        .installmentFirstChoice,
        .installmentBBL,
        .installmentKTC,
        .installmentKBank,
    ]
    
    public static let internetBankingAvailablePaymentMethods: [OMSSourceTypeValue] = [
        .internetBankingBAY,
        .internetBankingKTB,
        .internetBankingSCB,
        .internetBankingBBL,
    ]
    
    public static let installmentsBankingAvailablePaymentMethods: [OMSSourceTypeValue] = [
        .installmentBAY,
        .installmentFirstChoice,
        .installmentBBL,
        .installmentKTC,
        .installmentKBank,
    ]
    
    public static let billPaymentAvailablePaymentMethods: [OMSSourceTypeValue] = [
        .billPaymentTescoLotus,
    ]
    
    public static let barcodeAvailablePaymentMethods: [OMSSourceTypeValue] = [
        .barcodeAlipay,
    ]
}


extension OMSSourceTypeValue {
    
    var installmentBrand: PaymentInformation.Installment.Brand? {
        switch self {
        case .installmentBAY:
            return .bay
        case .installmentFirstChoice:
            return .firstChoice
        case .installmentBBL:
            return .bbl
        case .installmentKTC:
            return .ktc
        case .installmentKBank:
            return .kBank
        default:
            return nil
        }
    }
    
    var isInstallmentSource: Bool {
        switch self {
        case .installmentBAY, .installmentFirstChoice, .installmentBBL, .installmentKTC, .installmentKBank:
            return true
        default:
            return false
        }

    }
    
    var internetBankingSource: PaymentInformation.InternetBanking? {
        switch self {
        case .internetBankingBAY:
            return .bay
        case .internetBankingKTB:
            return .ktb
        case .internetBankingSCB:
            return .scb
        case .internetBankingBBL:
            return .bbl
        default:
            return nil
        }
    }
    
    var isInternetBankingSource: Bool {
        switch self {
        case .internetBankingBAY, .internetBankingKTB, .internetBankingSCB, .internetBankingBBL:
            return true
        default:
            return false
        }
    }
}


