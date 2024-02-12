import Foundation
import XCTest
@testable import OmiseSDK

class SourceTests: XCTestCase {

    let sampleData = SampleData()
    let decoder = JSONDecoder()

    func testDecodeAlipayCN() throws {
        let source = try source(type: .alipayCN)
        XCTAssertEqual(source.id, "src_test_5owftw9kjhjisssm0n2")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.alipayCN))
        XCTAssertEqual(source.flow, .appRedirect)
        XCTAssertEqual(source.currency, "THB")
        XCTAssertEqual(source.amount, 500000)
    }
    func testDecodeAlipayHK() throws {
        let source = try source(type: .alipayHK)
        XCTAssertEqual(source.id, "src_test_5oxesy9ovpgawobhf6n")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.alipayHK))
        XCTAssertEqual(source.flow, .appRedirect)
        XCTAssertEqual(source.currency, "HKD")
        XCTAssertEqual(source.amount, 500000)
    }
    func testDecodeAlipay() throws {
        let source = try source(type: .alipay)
        XCTAssertEqual(source.id, "src_test_5avnfnqxzzj2yu7a34e")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.alipay))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.currency, "THB")
        XCTAssertEqual(source.amount, 1000000)
    }
    func testDecodeBoost() throws {
        let source = try source(type: .boost)
        XCTAssertEqual(source.id, "src_5pqcjr6tu4xvqut5nh5")
        XCTAssertTrue(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.boost))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.currency, "MYR")
        XCTAssertEqual(source.amount, 100000)
    }
    func testDecodeDana() throws {
        let source = try source(type: .dana)
        XCTAssertEqual(source.id, "src_test_5oxew5l8jxhss03ybfb")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.dana))
        XCTAssertEqual(source.flow, .appRedirect)
        XCTAssertEqual(source.currency, "JPY")
        XCTAssertEqual(source.amount, 500000)
    }
    func testDecodeDuitNowQR() throws {
        let source = try source(type: .duitNowQR)
        XCTAssertEqual(source.id, "src_5pqcjr6tu4xvqut5nh5")
        XCTAssertTrue(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.duitNowQR))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.currency, "MYR")
        XCTAssertEqual(source.amount, 100000)
    }
    func testDecodeGcash() throws {
        let source = try source(type: .gcash)
        XCTAssertEqual(source.id, "src_test_5oxesgzoekdn5nukcdf")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.gcash))
        XCTAssertEqual(source.flow, .appRedirect)
        XCTAssertEqual(source.amount, 500000)
        XCTAssertEqual(source.currency, "USD")
    }
    func testDecodeGrabPay() throws {
        let source = try source(type: .grabPay)
        XCTAssertEqual(source.id, "src_test_5pqcjr6tu4xvqut5nh5")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.grabPay))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 100000)
        XCTAssertEqual(source.currency, "SGD")
    }
    func testDecodeKakaoPay() throws {
        let source = try source(type: .kakaoPay)
        XCTAssertEqual(source.id, "src_test_5oxetau2owhu0rbzg7y")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.kakaoPay))
        XCTAssertEqual(source.flow, .appRedirect)
        XCTAssertEqual(source.amount, 500000)
        XCTAssertEqual(source.currency, "USD")
    }
    func testDecodeMaybankQRPay() throws {
        let source = try source(type: .maybankQRPay)
        XCTAssertEqual(source.id, "src_5pqcjr6tu4xvqut5nh5")
        XCTAssertTrue(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.maybankQRPay))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 100000)
        XCTAssertEqual(source.currency, "MYR")
    }
    func testDecodePayNow() throws {
        let source = try source(type: .payNow)
        XCTAssertEqual(source.id, "src_test_5iso4taobco8j5jehx5")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.payNow))
        XCTAssertEqual(source.flow, .offline)
        XCTAssertEqual(source.amount, 100000)
        XCTAssertEqual(source.currency, "SGD")
    }
    func testDecodePayPay() throws {
        let source = try source(type: .payPay)
        XCTAssertEqual(source.id, "src_5pqcjr6tu4xvqut5nh5")
        XCTAssertTrue(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.payPay))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 100000)
        XCTAssertEqual(source.currency, "JPY")
    }
    func testDecodePromptPay() throws {
        let source = try source(type: .promptPay)
        XCTAssertEqual(source.id, "src_test_5jb2cjjyjea25nps3ya")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.promptPay))
        XCTAssertEqual(source.flow, .offline)
        XCTAssertEqual(source.amount, 100000)
        XCTAssertEqual(source.currency, "THB")
    }
    func testDecodeRabbitLinepay() throws {
        let source = try source(type: .rabbitLinepay)
        XCTAssertEqual(source.id, "src_test_5owftw9kjhjisssm0n2")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.rabbitLinepay))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 500000)
        XCTAssertEqual(source.currency, "THB")
    }
    func testDecodeShopeePayJumpApp() throws {
        let source = try source(type: .shopeePayJumpApp)
        XCTAssertEqual(source.id, "src_5pqcjr6tu4xvqut5nh5")
        XCTAssertTrue(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.shopeePayJumpApp))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 100000)
        XCTAssertEqual(source.currency, "MYR")
    }
    func testDecodeShopeePay() throws {
        let source = try source(type: .shopeePay)
        XCTAssertEqual(source.id, "src_5pqcjr6tu4xvqut5nh5")
        XCTAssertTrue(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.shopeePay))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 110000)
        XCTAssertEqual(source.currency, "MYR")
    }
    func testDecodeTouchNGo() throws {
        let source = try source(type: .touchNGo)
        XCTAssertEqual(source.id, "src_test_5oxet335rx3xzdyn06g")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.touchNGo))
        XCTAssertEqual(source.flow, .appRedirect)
        XCTAssertEqual(source.amount, 500000)
        XCTAssertEqual(source.currency, "SGD")
    }

    func testDecodeTrueMoneyJumpApp() throws {
        let source = try source(type: .trueMoneyJumpApp)
        XCTAssertEqual(source.id, "src_5yqlbf5w206mcfybj8v")
        XCTAssertTrue(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.trueMoneyJumpApp))
        XCTAssertEqual(source.flow, .appRedirect)
        XCTAssertEqual(source.amount, 500000)
        XCTAssertEqual(source.currency, "THB")
    }

        func testDecodeBarcodeAlipay() throws {
            let source = try source(type: .barcodeAlipay)
            XCTAssertEqual(source.id, "src_test_5cq1tilrnz7d62t8y87")
            XCTAssertFalse(source.isLiveMode)
            XCTAssertEqual(source.paymentInformation, .barcode(.alipay(payload)))
            XCTAssertEqual(source.flow, .<#flow#>)
            XCTAssertEqual(source.amount, <#amount#>)
            XCTAssertEqual(source.currency, "<#currency#>")
        }

    //    func testDecode<#Type#>() throws {
    //        let source = try source(type: .<#type#>)
    //        XCTAssertEqual(source.id, "<#id#>")
    //        XCTAssert<#Bool#>(source.isLiveMode)
    //        XCTAssertEqual(source.paymentInformation, .other(.<#type#>))
    //        XCTAssertEqual(source.flow, .<#flow#>)
    //        XCTAssertEqual(source.amount, <#amount#>)
    //        XCTAssertEqual(source.currency, "<#currency#>")
    //    }

    //    func testDecode<#Type#>() throws {
    //        let source = try source(type: .<#type#>)
    //        XCTAssertEqual(source.id, "<#id#>")
    //        XCTAssert<#Bool#>(source.isLiveMode)
    //        XCTAssertEqual(source.paymentInformation, .other(.<#type#>))
    //        XCTAssertEqual(source.flow, .<#flow#>)
    //        XCTAssertEqual(source.amount, <#amount#>)
    //        XCTAssertEqual(source.currency, "<#currency#>")
    //    }

    //    func testDecode<#Type#>() throws {
    //        let source = try source(type: .<#type#>)
    //        XCTAssertEqual(source.id, "<#id#>")
    //        XCTAssert<#Bool#>(source.isLiveMode)
    //        XCTAssertEqual(source.paymentInformation, .other(.<#type#>))
    //        XCTAssertEqual(source.flow, .<#flow#>)
    //        XCTAssertEqual(source.amount, <#amount#>)
    //        XCTAssertEqual(source.currency, "<#currency#>")
    //    }

    //    func testDecode<#Type#>() throws {
    //        let source = try source(type: .<#type#>)
    //        XCTAssertEqual(source.id, "<#id#>")
    //        XCTAssert<#Bool#>(source.isLiveMode)
    //        XCTAssertEqual(source.paymentInformation, .other(.<#type#>))
    //        XCTAssertEqual(source.flow, .<#flow#>)
    //        XCTAssertEqual(source.amount, <#amount#>)
    //        XCTAssertEqual(source.currency, "<#currency#>")
    //    }

    //    func testDecode<#Type#>() throws {
    //        let source = try source(type: .<#type#>)
    //        XCTAssertEqual(source.id, "<#id#>")
    //        XCTAssert<#Bool#>(source.isLiveMode)
    //        XCTAssertEqual(source.paymentInformation, .other(.<#type#>))
    //        XCTAssertEqual(source.flow, .<#flow#>)
    //        XCTAssertEqual(source.amount, <#amount#>)
    //        XCTAssertEqual(source.currency, "<#currency#>")
    //    }

    //    func testDecodeTruemoney() throws {
    //        let source = try source(type: .trueMoney)
    //        XCTAssertEqual(source.id, "src_test_5jhmesi7s4at1qctloy")
    //        XCTAssert<#Bool#>(source.isLiveMode)
    //        XCTAssertEqual(source.paymentInformation, .other(.trueMoney))
    //        XCTAssertEqual(source.flow, .<#flow#>)
    //        XCTAssertEqual(source.amount, <#amount#>)
    //        XCTAssertEqual(source.currency, "<#currency#>")
    //    }

}

private extension SourceTests {
    func source(type: SourceType) throws -> SourceNew {
        do {
            let sourceData = try sampleData.jsonData(for: .source(type: type))
            let source = try decoder.decode(SourceNew.self, from: sourceData)
            return source
        } catch {
            XCTFail("Cannot decode the source \(error)")
            throw error
        }
    }
}
