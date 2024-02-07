//
//  PaymentChooserViewControllerTests.swift
//  OmiseSDKTests
//
//  Created by Andrei Solovev on 5/12/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import XCTest
@testable import OmiseSDK

class PaymentChooserViewControllerTests: XCTestCase {
    let allSourceTypes: [SourceTypeValue] = [
        .internetBankingBAY,
        .internetBankingBBL,
        .mobileBankingSCB,
        .mobileBankingOCBC,
        .mobileBankingBAY,
        .mobileBankingBBL,
        .mobileBankingKTB,
        .alipay,
        .alipayCN,
        .alipayHK,
        .billPaymentTescoLotus,
        .barcodeAlipay,
        .dana,
        .gcash,
        .installmentBAY,
        .installmentFirstChoice,
        .installmentBBL,
        .installmentMBB,
        .installmentKTC,
        .installmentKBank,
        .installmentSCB,
        .installmentTTB,
        .installmentUOB,
        .kakaoPay,
        .eContext,
        .promptPay,
        .payNow,
        .touchNGo,
        .touchNGoAlipayPlus,
        .trueMoney,
        .trueMoneyJumpApp,
        .pointsCiti,
        .fpx,
        .mobileBankingKBank,
        .rabbitLinepay,
        .grabPay,
        .grabPayRms,
        .boost,
        .shopeePay,
        .shopeePayJumpApp,
        .maybankQRPay,
        .duitNowQR,
        .duitNowOBW,
        .atome,
        .payPay,
        .weChat
    ]

    func testTrueMoveFiltering() {
        let trueMoneyWalletOnly = allSourceTypes.filter { $0 != .trueMoneyJumpApp }
        let trueMoneyJumpAppOnly = allSourceTypes.filter { $0 != .trueMoney }
        let trueMoneyAndJumpApp = allSourceTypes
        let noTrueMoneyAndJumpApp = allSourceTypes.filter {
            ($0 != .trueMoney) && ($0 != .trueMoneyJumpApp)
        }

        let vc = PaymentChooserViewController()
        vc.loadView()

        vc.allowedPaymentMethods = trueMoneyWalletOnly
        XCTAssertTrue(vc.showingValues.contains(.truemoney))
        XCTAssertFalse(vc.showingValues.contains(.truemoneyJumpApp))

        vc.allowedPaymentMethods = trueMoneyJumpAppOnly
        XCTAssertTrue(vc.showingValues.contains(.truemoneyJumpApp))
        XCTAssertFalse(vc.showingValues.contains(.truemoney))

        vc.allowedPaymentMethods = trueMoneyAndJumpApp
        XCTAssertTrue(vc.showingValues.contains(.truemoneyJumpApp))
        XCTAssertFalse(vc.showingValues.contains(.truemoney))

        vc.allowedPaymentMethods = noTrueMoneyAndJumpApp
        XCTAssertFalse(vc.showingValues.contains(.truemoneyJumpApp))
        XCTAssertFalse(vc.showingValues.contains(.truemoney))
    }

    func testShopeePayFiltering() {
        let shopeePayOnly = allSourceTypes.filter { $0 != .shopeePayJumpApp }
        let shopeePayJumpAppOnly = allSourceTypes.filter { $0 != .shopeePay }
        let shopeePayAndJumpApp = allSourceTypes
        let noShopeePayandJumpApp = allSourceTypes.filter {
            ($0 != .shopeePay) && ($0 != .shopeePayJumpApp)
        }

        let vc = PaymentChooserViewController()
        vc.loadView()

        vc.allowedPaymentMethods = shopeePayOnly
        XCTAssertTrue(vc.showingValues.contains(.shopeePay))
        XCTAssertFalse(vc.showingValues.contains(.shopeePayJumpApp))

        vc.allowedPaymentMethods = shopeePayJumpAppOnly
        XCTAssertTrue(vc.showingValues.contains(.shopeePayJumpApp))
        XCTAssertFalse(vc.showingValues.contains(.shopeePay))

        vc.allowedPaymentMethods = shopeePayAndJumpApp
        XCTAssertTrue(vc.showingValues.contains(.shopeePayJumpApp))
        XCTAssertFalse(vc.showingValues.contains(.shopeePay))

        vc.allowedPaymentMethods = noShopeePayandJumpApp
        XCTAssertFalse(vc.showingValues.contains(.shopeePayJumpApp))
        XCTAssertFalse(vc.showingValues.contains(.shopeePay))
    }
    
    func testAlphabetSorting() {
        let vc = PaymentChooserViewController()
        vc.loadView()

        let sorted: [PaymentChooserOption] = [
            .alipay,
            .alipayCN,
            .alipayHK,
            .atome,
            .boost,
            .citiPoints,
            .conbini,
            .creditCard,
            .dana,
            .duitNowOBW,
            .duitNowQR,
            .fpx,
            .gcash,
            .grabPay,
            .grabPayRms,
            .installment,
            .internetBanking,
            .kakaoPay,
            .maybankQRPay,
            .mobileBanking,
            .netBanking,
            .ocbcDigital,
            .payEasy,
            .paynow,
            .payPay,
            .promptpay,
            .rabbitLinepay,
            .shopeePay,
            .shopeePayJumpApp,
            .tescoLotus,
            .touchNGoAlipayPlus,  // TNG eWallet
            .touchNGo,
            .truemoneyJumpApp, // TrueMoney
            .truemoney, // TrueMoney Wallet
            .weChat
        ]

        XCTAssertEqual(PaymentChooserOption.alphabetical, sorted)
    }

    func testFilteringAndSorting() {
        let filteredAndSorted: [PaymentChooserOption] = [
            .creditCard,
            .paynow,
            .promptpay,
            .truemoneyJumpApp, // TrueMoney
            .mobileBanking,
            .internetBanking,
            .alipay,
            .installment,
            .ocbcDigital,
            .rabbitLinepay,
            .shopeePayJumpApp,
            .alipayCN,
            .alipayHK,
            .atome,
            .boost,
            .citiPoints,
            .conbini,
            .dana,
            .duitNowOBW,
            .duitNowQR,
            .fpx,
            .gcash,
            .grabPay,
            .grabPayRms,
            .kakaoPay,
            .maybankQRPay,
            .netBanking,
            .payEasy,
            .payPay,
            .tescoLotus,
            .touchNGoAlipayPlus, // TNG eWallet
            .touchNGo,
            .weChat
        ]

        let vc = PaymentChooserViewController()
        vc.loadView()

        vc.allowedPaymentMethods = allSourceTypes
        XCTAssertEqual(vc.showingValues, filteredAndSorted)
    }

    func testShowsCreditCardPayment() {
        let availableTypes: [SourceTypeValue] = [
            .alipay,
            .alipayCN,
            .alipayHK,
            .atome
        ]

        let vc = PaymentChooserViewController()
        vc.loadView()

        vc.showsCreditCardPayment = false
        vc.allowedPaymentMethods = availableTypes
        XCTAssertEqual(vc.showingValues.count, availableTypes.count)

        vc.showsCreditCardPayment = true
        XCTAssertEqual(vc.showingValues.count, availableTypes.count + 1)
    }

    func testAllowedPaymentMethods() {
        let set1: [SourceTypeValue] = [ .alipay, .alipayCN ]
        let result1: [PaymentChooserOption] = [.alipay, .alipayCN]

        let set2: [SourceTypeValue] = [ .atome, .payPay, .weChat ]
        let result2: [PaymentChooserOption] = [ .atome, .payPay, .weChat ]

        let vc = PaymentChooserViewController()
        vc.loadView()

        vc.showsCreditCardPayment = false
        vc.allowedPaymentMethods = set1
        XCTAssertEqual(vc.showingValues, result1)

        vc.allowedPaymentMethods = set2
        XCTAssertEqual(vc.showingValues, result2)

        vc.showsCreditCardPayment = true
        XCTAssertEqual(vc.showingValues, [PaymentChooserOption.creditCard] + result2)
    }
}
