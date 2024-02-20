import Foundation

extension Source.Payment.DuitNowOBW.Bank: TableListPresentable {
    var accessoryIconName: String {
        Assets.Icon.redirect.rawValue
    }
    
    var localizedTitle: String {
        switch self {
        case .affin:
            return "Affin Bank"
        case .alliance:
            return "Alliance Bank"
        case .agro:
            return "Agrobank"
        case .ambank:
            return "AmBank"
        case .islam:
            return "Bank Islam"
        case .muamalat:
            return "Bank Muamalat"
        case .rakyat:
            return "Bank Rakyat"
        case .bsn:
            return "Bank Simpanan Nasional"
        case .cimb:
            return "CIMB Bank"
        case .hongleong:
            return "Hong Leong"
        case .hsbc:
            return "HSBC Bank"
        case .kfh:
            return "Kuwait Finance House"
        case .maybank2u:
            return "Maybank"
        case .ocbc:
            return "OCBC"
        case .publicBank:
            return "Public Bank"
        case .rhb:
            return "RHB Bank"
        case .sc:
            return "Standard Chartered"
        case .uob:
            return "United Overseas Bank"
        }
    }
    var iconName: String {
        switch self {
        case .affin:
            return "FPX/affin"
        case .alliance:
            return "FPX/alliance"
        case .agro:
            return "agrobank"
        case .ambank:
            return "FPX/ambank"
        case .islam:
            return "FPX/islam"
        case .muamalat:
            return "FPX/muamalat"
        case .rakyat:
            return "FPX/rakyat"
        case .bsn:
            return "FPX/bsn"
        case .cimb:
            return "FPX/cimb"
        case .hongleong:
            return "FPX/hong-leong"
        case .hsbc:
            return "FPX/hsbc"
        case .kfh:
            return "FPX/kfh"
        case .maybank2u:
            return "FPX/maybank"
        case .ocbc:
            return "FPX/ocbc"
        case .publicBank:
            return "FPX/public-bank"
        case .rhb:
            return "FPX/rhb"
        case .sc:
            return "FPX/sc"
        case .uob:
            return "FPX/uob"
        }
    }
}

