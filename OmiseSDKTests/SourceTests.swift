import Foundation
import XCTest
@testable import OmiseSDK

// swiftlint:disable:next type_body_length
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
        let payload = Source.Payload.BarcodeAlipay(
            barcode: "1234567890123456",
            storeID: "1",
            storeName: "Main Store",
            terminalID: nil
        )
        XCTAssertEqual(source.id, "src_test_5cq1tilrnz7d62t8y87")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .barcodeAlipay(payload))
        XCTAssertEqual(source.flow, .offline)
        XCTAssertEqual(source.amount, 100000)
        XCTAssertEqual(source.currency, "THB")
    }

    func testDecodeBillPaymentTescoLotus() throws {
        let source = try source(type: .billPaymentTescoLotus)
        XCTAssertEqual(source.id, "src_test_59trf2nxk43b5nml8z0")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.billPaymentTescoLotus))
        XCTAssertEqual(source.flow, .offline)
        XCTAssertEqual(source.amount, 1000000)
        XCTAssertEqual(source.currency, "THB")
    }

    func testDecodeAtome() throws {
        let payload = Source.Payload.Atome(
            phoneNumber: "+12312312312",
            name: "Test Data",
            email: "test@omise.co",
            shipping: Source.Payload.Address(
                country: "TH",
                city: "Bangkok",
                postalCode: "10330",
                state: "Krung Thep Maha Nakhon",
                street1: "444 Phaya Thai Rd",
                street2: "Khwaeng Wang Mai, Pathum Wan"
            ),
            billing: Source.Payload.Address(
                country: "TH",
                city: "Bangkok",
                postalCode: "10100",
                state: "Bangkok",
                street1: "Sukhumvit",
                street2: nil
            ),
            items: [
                Source.Payload.Item(
                    sku: "3427842",
                    category: "Shoes",
                    name: "Prada shoes",
                    quantity: 1,
                    amount: 500000,
                    itemUri: "omise.co/product/shoes",
                    imageUri: "omise.co/product/shoes/image",
                    brand: "Gucci"
                ),
                Source.Payload.Item(
                    sku: "3427843",
                    category: "Shoes",
                    name: "Skate Shoes",
                    quantity: 2,
                    amount: 200000,
                    itemUri: nil,
                    imageUri: nil,
                    brand: "DC"
                )
            ]
        )

        let source = try source(type: .atome)
        XCTAssertEqual(source.id, "src_5yqiaqtbbog2pxjdg6b")
        XCTAssertTrue(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .atome(payload))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 700000)
        XCTAssertEqual(source.currency, "THB")
    }

    func testDecodeDuitNowOBW() throws {
        let source = try source(type: .duitNowOBW)
        let payload = Source.Payload.DuitNowOBW(bank: .affin)
        XCTAssertEqual(source.id, "src_5pqcjr6tu4xvqut5nh5")
        XCTAssertTrue(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .duitNowOBW(payload))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 100000)
        XCTAssertEqual(source.currency, "MYR")
    }

    func testDecodeInstallmentBay() throws {
        let sourceType: SourceType = .installmentBAY
        let source = try source(type: sourceType)
        let payload = Source.Payload.Installment(
            installmentTerm: 6,
            zeroInterestInstallments: false,
            sourceType: sourceType
        )
        XCTAssertEqual(source.id, "src_test_5cs0t6x8n0z8rcfrsfi")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .installment(payload))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 500000)
        XCTAssertEqual(source.currency, "THB")
    }

    func testDecodeInstallmentBBL() throws {
        let sourceType: SourceType = .installmentBBL
        let source = try source(type: sourceType)
        let payload = Source.Payload.Installment(
            installmentTerm: 6,
            zeroInterestInstallments: false,
            sourceType: sourceType
        )
        XCTAssertEqual(source.id, "src_test_5cs0tdinbyypg6kn1fa")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .installment(payload))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 500000)
        XCTAssertEqual(source.currency, "THB")
    }

    func testDecodeInstallmentFirstChoice() throws {
        let sourceType: SourceType = .installmentFirstChoice
        let source = try source(type: sourceType)
        let payload = Source.Payload.Installment(
            installmentTerm: 6,
            zeroInterestInstallments: false,
            sourceType: sourceType
        )

        XCTAssertEqual(source.id, "src_test_5cq1ugk8m0un1yefb2u")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .installment(payload))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 500000)
        XCTAssertEqual(source.currency, "THB")
    }

    func testDecodeInstallmentKBank() throws {
        let sourceType: SourceType = .installmentKBank
        let source = try source(type: sourceType)
        let payload = Source.Payload.Installment(
            installmentTerm: 6,
            zeroInterestInstallments: false,
            sourceType: sourceType
        )
        XCTAssertEqual(source.id, "src_test_5cs0totfv87k1i6y45l")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .installment(payload))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 500000)
        XCTAssertEqual(source.currency, "THB")
    }

    func testDecodeInstallmentKTC() throws {
        let sourceType: SourceType = .installmentKTC
        let source = try source(type: sourceType)
        let payload = Source.Payload.Installment(
            installmentTerm: 6,
            zeroInterestInstallments: false,
            sourceType: sourceType
        )
        XCTAssertEqual(source.id, "src_test_5cs0tk7m2e5ivctrq30")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .installment(payload))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 500000)
        XCTAssertEqual(source.currency, "THB")
    }

    func testDecodeInstallmentMBB() throws {
        let sourceType: SourceType = .installmentMBB
        let source = try source(type: sourceType)
        let payload = Source.Payload.Installment(
            installmentTerm: 6,
            zeroInterestInstallments: false,
            sourceType: sourceType
        )
        XCTAssertEqual(source.id, "src_test_5obr9opqz5huc6tefw8")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .installment(payload))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 500000)
        XCTAssertEqual(source.currency, "MYR")
    }

    func testDecodeInstallmentTTB() throws {
        let sourceType: SourceType = .installmentTTB
        let source = try source(type: sourceType)
        let payload = Source.Payload.Installment(
            installmentTerm: 6,
            zeroInterestInstallments: false,
            sourceType: sourceType
        )
        XCTAssertEqual(source.id, "src_test_5obr9opd7ej5c6tefw8")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .installment(payload))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 500000)
        XCTAssertEqual(source.currency, "THB")
    }

    func testDecodeInstallmentUOB() throws {
        let sourceType: SourceType = .installmentUOB
        let source = try source(type: sourceType)
        let payload = Source.Payload.Installment(
            installmentTerm: 6,
            zeroInterestInstallments: false,
            sourceType: sourceType
        )
        XCTAssertEqual(source.id, "src_test_5oe7fj1qz5huc6tefw8")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .installment(payload))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 500000)
        XCTAssertEqual(source.currency, "THB")
    }

    func testDecodeTrueMoneyWallet() throws {
        let source = try source(type: .trueMoneyWallet)
        let payload = Source.Payload.TrueMoneyWallet(phoneNumber: "0123456789")
        XCTAssertEqual(source.id, "src_test_5jhmesi7s4at1qctloy")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .trueMoneyWallet(payload))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 100000)
        XCTAssertEqual(source.currency, "THB")
    }

    func testDecodeInternetBankingBay() throws {
        let sourceType: SourceType = .internetBankingBAY
        let source = try source(type: sourceType)
        XCTAssertEqual(source.id, "src_test_5cs0sm8u8h8nqo5hwcs")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(sourceType))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 100000)
        XCTAssertEqual(source.currency, "THB")
    }

    func testDecodeInternetBankingBBL() throws {
        let sourceType: SourceType = .internetBankingBBL
        let source = try source(type: sourceType)
        XCTAssertEqual(source.id, "src_test_5cs0sfy7phu06yhyz5c")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(sourceType))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 100000)
        XCTAssertEqual(source.currency, "THB")
    }

    func testDecodeMobileBankingBAY() throws {
        let sourceType: SourceType = .mobileBankingBAY
        let source = try source(type: sourceType)
        XCTAssertEqual(source.id, "src_test_5cs0sm8u8h8nqo5zasd")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(sourceType))
        XCTAssertEqual(source.flow, .appRedirect)
        XCTAssertEqual(source.amount, 1000000)
        XCTAssertEqual(source.currency, "THB")
    }

    func testDecodeMobileBankingBBL() throws {
        let sourceType: SourceType = .mobileBankingBBL
        let source = try source(type: sourceType)
        XCTAssertEqual(source.id, "src_test_5cs0sm8u8h8nqo5zasd")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(sourceType))
        XCTAssertEqual(source.flow, .appRedirect)
        XCTAssertEqual(source.amount, 1000000)
        XCTAssertEqual(source.currency, "THB")
    }

    func testDecodeMobileBankingKBank() throws {
        let sourceType: SourceType = .mobileBankingKBank
        let source = try source(type: sourceType)
        XCTAssertEqual(source.id, "src_test_5cs0sm8u8h8nqo5zasd")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(sourceType))
        XCTAssertEqual(source.flow, .appRedirect)
        XCTAssertEqual(source.amount, 1000000)
        XCTAssertEqual(source.currency, "THB")
    }
    func testDecodeMobileBankingTKB() throws {
        let sourceType: SourceType = .mobileBankingKTB
        let source = try source(type: sourceType)
        XCTAssertEqual(source.id, "src_test_5cs0sm8u8h8nqo5zasd")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(sourceType))
        XCTAssertEqual(source.flow, .appRedirect)
        XCTAssertEqual(source.amount, 1000000)
        XCTAssertEqual(source.currency, "THB")
    }

    func testDecodeMobileBankingSCB() throws {
        let sourceType: SourceType = .mobileBankingSCB
        let source = try source(type: sourceType)
        XCTAssertEqual(source.id, "src_test_5cs0sm8u8h8nqo5zasd")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(sourceType))
        XCTAssertEqual(source.flow, .appRedirect)
        XCTAssertEqual(source.amount, 1000000)
        XCTAssertEqual(source.currency, "THB")
    }
}

private extension SourceTests {
    func source(type: SourceType) throws -> Source {
        do {
            let sourceData = try sampleData.jsonData(for: .source(sourceType: type))
            let source = try decoder.decode(Source.self, from: sourceData)
            return source
        } catch {
            XCTFail("Cannot decode the source \(error)")
            throw error
        }
    }
}
