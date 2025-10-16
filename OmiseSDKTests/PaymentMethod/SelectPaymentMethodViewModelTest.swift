import Foundation
import XCTest
@testable import OmiseSDK

class SelectPaymentMethodViewModelTest: XCTestCase {
    
    var sut: SelectPaymentMethodViewModel!
    var mockClient: MockClient!
    var mockselectPaymentMethodDelegate: MockSelectPaymentMethodDelegate!
    
    private let expectedIconNames: [SourceType: String] = [
        .alipay: "Alipay",
        .alipayCN: "AlipayCN",
        .alipayHK: "AlipayHK",
        .atome: "Atome",
        .applePay: "ApplePay",
        .barcodeAlipay: "Alipay",
        .billPaymentTescoLotus: "Tesco",
        .boost: "Boost",
        .dana: "dana",
        .duitNowOBW: "Duitnow-OBW",
        .duitNowQR: "DuitNow-QR",
        .eContext: "",
        .fpx: "FPX",
        .gcash: "gcash",
        .grabPay: "Grab",
        .grabPayRms: "Grab",
        .installmentBAY: "BAY",
        .installmentWhiteLabelBAY: "BAY",
        .installmentBBL: "BBL",
        .installmentWhiteLabelBBL: "BBL",
        .installmentFirstChoice: "First Choice",
        .installmentWhiteLabelFirstChoice: "First Choice",
        .installmentKBank: "KBANK",
        .installmentWhiteLabelKBank: "KBANK",
        .installmentKTC: "KTC",
        .installmentWhiteLabelKTC: "KTC",
        .installmentMBB: "FPX/maybank",
        .installmentSCB: "SCB",
        .installmentWhiteLabelSCB: "SCB",
        .installmentTTB: "ttb",
        .installmentWhiteLabelTTB: "ttb",
        .installmentUOB: "uob",
        .installmentWhiteLabelUOB: "uob",
        .kakaoPay: "kakaopay",
        .maybankQRPay: "MAE-maybank",
        .mobileBankingBAY: "KMA",
        .mobileBankingBBL: "BBL M",
        .mobileBankingKBank: "KPlus",
        .mobileBankingKTB: "KTB Next",
        .mobileBankingSCB: "SCB",
        .ocbcDigital: "ocbc-digital",
        .payNow: "PayNow",
        .payPay: "PayPay",
        .promptPay: "PromptPay",
        .rabbitLinepay: "RabbitLinePay",
        .shopeePay: "Shopeepay",
        .shopeePayJumpApp: "Shopeepay",
        .touchNGo: "touch-n-go",
        .touchNGoAlipayPlus: "touch-n-go",
        .trueMoneyWallet: "TrueMoney",
        .trueMoneyJumpApp: "TrueMoney",
        .weChat: "wechat_pay"
    ]
    
    override func setUp() {
        super.setUp()
        mockClient = MockClient()
        mockselectPaymentMethodDelegate = MockSelectPaymentMethodDelegate()
        sut = SelectPaymentMethodViewModel(client: mockClient,
                                           filter: .init(sourceTypes: [], isCardPaymentAllowed: true, isForced: false),
                                           delegate: mockselectPaymentMethodDelegate)
    }
    
    override func tearDown() {
        super.tearDown()
        mockClient = nil
        sut = nil
        mockselectPaymentMethodDelegate = nil
    }
    
    func test_viewDidSelectCell_callsDelegate() {
        sut.viewDidSelectCell(at: 0) { }
        XCTAssertEqual(mockselectPaymentMethodDelegate.calls.count, 1)
        XCTAssertEqual(mockselectPaymentMethodDelegate.calls[0], .didSelectPaymentMethod)
    }
    
    func test_viewDidTapClose() {
        sut.viewDidTapClose()
        XCTAssertEqual(mockselectPaymentMethodDelegate.calls.count, 1)
        XCTAssertEqual(mockselectPaymentMethodDelegate.calls[0], .didCancelPayment)
    }
    
    func test_sourcetype_viewpresentable() throws {
        let cell = sut.viewContext(at: 1)
        
        XCTAssertEqual(cell?.title, SourceType.trueMoneyJumpApp.localizedTitle)
        XCTAssertEqual(cell?.subtitle, SourceType.trueMoneyJumpApp.localizedSubtitle)
        XCTAssertNotNil(cell?.icon)
    }
    
    func test_localizedTitleAndDescription() {
        for source in SourceType.allCases {
            let expectedTitle = localized("SourceType.\(source.rawValue)")
            XCTAssertEqual(source.localizedTitle, expectedTitle)
            XCTAssertEqual(source.description, source.localizedTitle)
        }
    }
    
    func test_iconName() {
        for source in SourceType.allCases {
            if let expectedIcon = expectedIconNames[source] {
                XCTAssertEqual(source.iconName, expectedIcon)
            } else {
                XCTFail("No expected icon found for SourceType case: \(source)")
            }
        }
    }
    
    func test_localizedSubtitle() {
        for source in SourceType.allCases {
            switch source {
            case .alipayCN, .alipayHK, .dana, .gcash, .kakaoPay, .touchNGo:
                let expected = localized("SourceType.alipay.footnote")
                XCTAssertEqual(source.localizedSubtitle, expected)
            case .grabPay:
                let expected = localized("SourceType.grabpay.footnote")
                XCTAssertEqual(source.localizedSubtitle, expected)
            default:
                XCTAssertNil(source.localizedSubtitle, "Localized subtitle for \(source) should be nil")
            }
        }
    }
    
    func test_accessoryIcon() {
        for source in SourceType.allCases {
            if source.requiresAdditionalDetails {
                XCTAssertEqual(source.accessoryIcon, Assets.Icon.next)
            } else {
                XCTAssertEqual(source.accessoryIcon, Assets.Icon.redirect)
            }
        }
    }
    
    func test() {
        sut.viewDidTapClose()
        XCTAssertEqual(mockselectPaymentMethodDelegate.calls.count, 1)
        XCTAssertEqual(mockselectPaymentMethodDelegate.calls[0], .didCancelPayment)
    }
}
