import XCTest
import UIKit
@testable import OmiseSDK

class PaymentMethodTests: XCTestCase {
    var anyInstallment: SourceType!
    var anyMobile: SourceType!
    let eContext       = SourceType.eContext
    let barcodeAlipay  = SourceType.barcodeAlipay
    let defaultSource  = SourceType.alipay
    private let decoder = JSONDecoder()
    
    override func setUp() {
        super.setUp()
        
        guard let inst = SourceType.allCases.first(where: { $0.isInstallment }) else {
            XCTFail("No installment SourceType found")
            return
        }
        anyInstallment = inst
        
        guard let mobile = SourceType.allCases.first(where: { $0.isMobileBanking }) else {
            XCTFail("No installment SourceType found")
            return
        }
        anyMobile = mobile
    }
    
    func testSourceTypeComputedProperty() {
        let pm = PaymentMethod.sourceType(.payNow)
        XCTAssertEqual(pm.sourceType, .payNow)
        XCTAssertNil(PaymentMethod.creditCard.sourceType)
    }
    
    func testPaymentMethodsForSourceTypeVariants() {
        XCTAssertEqual(PaymentMethod.paymentMethods(for: anyInstallment), [.installment])
        XCTAssertEqual(PaymentMethod.paymentMethods(for: anyMobile), [.mobileBanking])
        XCTAssertEqual(PaymentMethod.paymentMethods(for: eContext),
                       [.eContextConbini, .eContextNetBanking, .eContextPayEasy])
        XCTAssertEqual(PaymentMethod.paymentMethods(for: barcodeAlipay), [])
        XCTAssertEqual(PaymentMethod.paymentMethods(for: defaultSource),
                       [.sourceType(defaultSource)])
    }
    
    func testFromDeduplicates() {
        let list = PaymentMethod.from(sourceTypes:
                                        [defaultSource, defaultSource, anyInstallment])
        XCTAssertEqual(Set(list), Set([.sourceType(defaultSource), .installment]))
    }
    
    func testAlphabeticalSort() {
        let input: [PaymentMethod] = [.mobileBanking, .creditCard, .installment]
        let sorted = PaymentMethod.alphabetical(from: input)
        XCTAssertEqual(sorted, [.creditCard, .installment, .mobileBanking])
    }
    
    func testTopListedKeepsGlobalOrderAndAppendsRest() {
        let input: [PaymentMethod] = [.mobileBanking, .sourceType(.payNow), .creditCard]
        let top = PaymentMethod.topListed(from: input)
        XCTAssertEqual(top, [.creditCard, .sourceType(.payNow), .mobileBanking])
    }
    
    func testSortedCombinesAlphabeticalAndTopListed() {
        let input: [PaymentMethod] = [.mobileBanking, .creditCard]
        let sorted = PaymentMethod.sorted(from: input)
        XCTAssertEqual(sorted, [.creditCard, .mobileBanking])
    }
    
    func testCreatePaymentMethodsFrom_showsCreditCard() {
        let srcs: [SourceType] = [defaultSource]
        let methods = PaymentMethod.createPaymentMethods(from: srcs,
                                                         showsCreditCard: true)
        XCTAssertTrue(methods.contains(.creditCard))
        XCTAssertTrue(methods.contains(.sourceType(defaultSource)))
    }
    
    func testCreatePaymentMethodsRemovesTrueMoneyWalletIfJumpAppPresent() {
        let srcs: [SourceType] = [.trueMoneyWallet, .trueMoneyJumpApp]
        let methods = PaymentMethod.createPaymentMethods(from: srcs, showsCreditCard: false)
        XCTAssertFalse(methods.contains(.sourceType(.trueMoneyWallet)))
        XCTAssertTrue(methods.contains(.sourceType(.trueMoneyJumpApp)))
    }
    
    func testCreatePaymentMethodsRemovesShopeePayIfJumpAppPresent() {
        let srcs: [SourceType] = [.shopeePay, .shopeePayJumpApp]
        let methods = PaymentMethod.createPaymentMethods(
            from: srcs, showsCreditCard: false)
        XCTAssertFalse(methods.contains(.sourceType(.shopeePay)))
        XCTAssertTrue(methods.contains(.sourceType(.shopeePayJumpApp)))
    }
    
    func testCreateViewContextsProducesCorrectTitlesAndIcons() {
        let methods: [PaymentMethod] = [
            .creditCard,
            .sourceType(defaultSource)
        ]
        let contexts = PaymentMethod.createViewContexts(from: methods)
        XCTAssertEqual(contexts.count, methods.count)
        for (idx, pm) in methods.enumerated() {
            let ctx = contexts[idx]
            XCTAssertEqual(ctx.title, pm.localizedTitle)
            XCTAssertNil(ctx.subtitle)
            XCTAssertNotNil(ctx.icon)
            XCTAssertNotNil(ctx.accessoryIcon)
        }
    }
    
    func testRequiresAdditionalDetails() {
        XCTAssertTrue(PaymentMethod.creditCard.requiresAdditionalDetails)
        XCTAssertTrue(PaymentMethod.installment.requiresAdditionalDetails)      // was previously asserted false
        XCTAssertTrue(PaymentMethod.sourceType(.fpx).requiresAdditionalDetails)
        
        // these really should be false:
        XCTAssertFalse(PaymentMethod.sourceType(.alipay).requiresAdditionalDetails)
        XCTAssertFalse(PaymentMethod.sourceType(.rabbitLinepay).requiresAdditionalDetails)
    }
    
    func testSampleCapabilityLoadsCorrectly() throws {
        let cap: Capability = try sampleFromJSONBy(.capability)
        
        // Your fixture’s country code
        XCTAssertEqual(cap.countryCode, "TH")
        
        let names = cap.paymentMethods.map(\.name)
        XCTAssertTrue(names.contains("card"), "Expected “card” in the payment methods")
        XCTAssertTrue(names.contains("fpx"), "Expected “fpx” in the payment methods")
        
        // cardPaymentMethod should find the “card” entry
        XCTAssertEqual(cap.cardPaymentMethod?.name, "card")
    }
    
    /// Given that sample `Capability`, `createPaymentMethods(with:)`
    /// should return at least FPX and credit-card entries, in the right order.
    func testCreatePaymentMethodsFromSampleCapability() throws {
        let cap: Capability = try sampleFromJSONBy(.capability)
        let methods = PaymentMethod.createPaymentMethods(with: cap)
        
        // It must include an FPX-based entry:
        XCTAssertTrue(
            methods.contains(.sourceType(.fpx)),
            "FPX should be present when `fpx` is in `cap.paymentMethods`"
        )
        
        XCTAssertTrue(methods.contains(.creditCard))
        
        // And ordering: creditCard should appear *before* the FPX entry in `methods`
        let fpIndex = try XCTUnwrap(methods.firstIndex(of: .sourceType(.fpx)))
        let ccIndex = try XCTUnwrap(methods.firstIndex(of: .creditCard))
        XCTAssertTrue(fpIndex > ccIndex)
    }
}
