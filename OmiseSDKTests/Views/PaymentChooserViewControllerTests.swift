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
    let allSourceTypes: [OMSSourceTypeValue] = [
        .internetBankingBAY,
        .internetBankingBBL,
        .mobileBankingSCB,
        .mobileBankingOCBCPAO,
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
        .installmentCiti,
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

    func testTruemoveFiltering() {
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
            .ocbcPao,
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
            .ocbcPao,
            .rabbitLinepay,
            .shopeePay,
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
}
