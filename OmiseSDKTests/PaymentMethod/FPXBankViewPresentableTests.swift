import XCTest
@testable import OmiseSDK

final class FPXBankViewPresentableTests: XCTestCase {
    /// Bundles up the expected values for each bank case.
    private struct Expected {
        let title: String
        let iconName: String
    }
    
    /// All of the FPX banks paired with their expected localizedTitle and iconName.
    private let expectations: [Source.Payment.FPX.Bank: Expected] = [
        .affin: Expected(title: "Affin Bank", iconName: "FPX/affin"),
        .alliance: Expected(title: "Alliance Bank", iconName: "FPX/alliance"),
        .agro: Expected(title: "Agrobank", iconName: "agrobank"),
        .ambank: Expected(title: "AmBank", iconName: "FPX/ambank"),
        .islam: Expected(title: "Bank Islam", iconName: "FPX/islam"),
        .muamalat: Expected(title: "Bank Muamalat", iconName: "FPX/muamalat"),
        .rakyat: Expected(title: "Bank Rakyat", iconName: "FPX/rakyat"),
        .bsn: Expected(title: "Bank Simpanan Nasional", iconName: "FPX/bsn"),
        .cimb: Expected(title: "CIMB Bank", iconName: "FPX/cimb"),
        .hongleong: Expected(title: "Hong Leong", iconName: "FPX/hong-leong"),
        .hsbc: Expected(title: "HSBC Bank", iconName: "FPX/hsbc"),
        .kfh: Expected(title: "Kuwait Finance House", iconName: "FPX/kfh"),
        .maybank2u: Expected(title: "Maybank2U", iconName: "FPX/maybank"),
        .ocbc: Expected(title: "OCBC", iconName: "FPX/ocbc"),
        .publicBank: Expected(title: "Public Bank", iconName: "FPX/public-bank"),
        .rhb: Expected(title: "RHB Bank", iconName: "FPX/rhb"),
        .sc: Expected(title: "Standard Chartered", iconName: "FPX/sc"),
        .uob: Expected(title: "United Overseas Bank", iconName: "FPX/uob"),
        .bocm: Expected(title: "Bank Of China", iconName: "FPX/bocm"),
        .maybank2e: Expected(title: "Maybank2E", iconName: "FPX/unknown")
    ]
    
    func testAllBanksProduceCorrectViewPresentableValues() {
        for (bank, expected) in expectations {
            // localizedTitle
            XCTAssertEqual(bank.localizedTitle,
                           expected.title,
                           "Bank \(bank) should have title “\(expected.title)”")
            
            // iconName
            XCTAssertEqual(bank.iconName,
                           expected.iconName,
                           "Bank \(bank) should have iconName “\(expected.iconName)”")
            
            // accessoryIcon is always .redirect
            XCTAssertEqual(bank.accessoryIcon,
                           Assets.Icon.redirect,
                           "Bank \(bank) should always use the `.redirect` accessory icon")
            
            // default subtitle is nil
            XCTAssertNil(bank.localizedSubtitle,
                         "Bank \(bank) should have no subtitle by default")
        }
    }
}
