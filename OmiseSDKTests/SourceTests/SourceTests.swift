import Foundation
import XCTest
@testable import OmiseSDK

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class SourceTests: XCTestCase {

    let sampleData = SampleData()
    var jsonDecoder = JSONDecoder()

    /// Test Source.Payload's Codable protocol
    func validatePayloadCodable(_ payload: Source.Payload) throws {
        let encodedPayload = try JSONEncoder().encode(payload)
        let encodedPayloadJson = String(data: encodedPayload, encoding: .utf8) ?? ""
        if payload.sourceType == .duitNowOBW {
            print(encodedPayloadJson)
            print("")
        }

        let decodedPayload = try parsePayload(jsonString: encodedPayloadJson)
        XCTAssertEqual(payload, decodedPayload)
    }

    func testAlipayCN() throws {
        let source = try sourceFromSampleJSONFileBy(type: .alipayCN)
        XCTAssertEqual(source.id, "src_test_5owftw9kjhjisssm0n2")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.alipayCN))
        XCTAssertEqual(source.flow, .appRedirect)
        XCTAssertEqual(source.currency, "THB")
        XCTAssertEqual(source.amount, 500000)
        try validatePayloadCodable(source.paymentInformation)
    }
    func testDecodeAlipayHK() throws {
        let source = try sourceFromSampleJSONFileBy(type: .alipayHK)
        XCTAssertEqual(source.id, "src_test_5oxesy9ovpgawobhf6n")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.alipayHK))
        XCTAssertEqual(source.flow, .appRedirect)
        XCTAssertEqual(source.currency, "HKD")
        XCTAssertEqual(source.amount, 500000)
        try validatePayloadCodable(source.paymentInformation)
    }
    func testDecodeAlipay() throws {
        let source = try sourceFromSampleJSONFileBy(type: .alipay)
        XCTAssertEqual(source.id, "src_test_5avnfnqxzzj2yu7a34e")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.alipay))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.currency, "THB")
        XCTAssertEqual(source.amount, 1000000)
        try validatePayloadCodable(source.paymentInformation)
    }
    func testDecodeBoost() throws {
        let source = try sourceFromSampleJSONFileBy(type: .boost)
        XCTAssertEqual(source.id, "src_5pqcjr6tu4xvqut5nh5")
        XCTAssertTrue(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.boost))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.currency, "MYR")
        XCTAssertEqual(source.amount, 100000)
        try validatePayloadCodable(source.paymentInformation)
    }
    func testDecodeDana() throws {
        let source = try sourceFromSampleJSONFileBy(type: .dana)
        XCTAssertEqual(source.id, "src_test_5oxew5l8jxhss03ybfb")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.dana))
        XCTAssertEqual(source.flow, .appRedirect)
        XCTAssertEqual(source.currency, "JPY")
        XCTAssertEqual(source.amount, 500000)
        try validatePayloadCodable(source.paymentInformation)
    }
    func testDecodeDuitNowQR() throws {
        let source = try sourceFromSampleJSONFileBy(type: .duitNowQR)
        XCTAssertEqual(source.id, "src_5pqcjr6tu4xvqut5nh5")
        XCTAssertTrue(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.duitNowQR))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.currency, "MYR")
        XCTAssertEqual(source.amount, 100000)
        try validatePayloadCodable(source.paymentInformation)
    }
    func testDecodeGcash() throws {
        let source = try sourceFromSampleJSONFileBy(type: .gcash)
        XCTAssertEqual(source.id, "src_test_5oxesgzoekdn5nukcdf")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.gcash))
        XCTAssertEqual(source.flow, .appRedirect)
        XCTAssertEqual(source.amount, 500000)
        XCTAssertEqual(source.currency, "USD")
        try validatePayloadCodable(source.paymentInformation)
    }
    func testDecodeGrabPay() throws {
        let source = try sourceFromSampleJSONFileBy(type: .grabPay)
        XCTAssertEqual(source.id, "src_test_5pqcjr6tu4xvqut5nh5")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.grabPay))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 100000)
        XCTAssertEqual(source.currency, "SGD")
        try validatePayloadCodable(source.paymentInformation)
    }
    func testDecodeKakaoPay() throws {
        let source = try sourceFromSampleJSONFileBy(type: .kakaoPay)
        XCTAssertEqual(source.id, "src_test_5oxetau2owhu0rbzg7y")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.kakaoPay))
        XCTAssertEqual(source.flow, .appRedirect)
        XCTAssertEqual(source.amount, 500000)
        XCTAssertEqual(source.currency, "USD")
        try validatePayloadCodable(source.paymentInformation)
    }
    func testDecodeMaybankQRPay() throws {
        let source = try sourceFromSampleJSONFileBy(type: .maybankQRPay)
        XCTAssertEqual(source.id, "src_5pqcjr6tu4xvqut5nh5")
        XCTAssertTrue(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.maybankQRPay))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 100000)
        XCTAssertEqual(source.currency, "MYR")
        try validatePayloadCodable(source.paymentInformation)
    }
    func testDecodePayNow() throws {
        let source = try sourceFromSampleJSONFileBy(type: .payNow)
        XCTAssertEqual(source.id, "src_test_5iso4taobco8j5jehx5")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.payNow))
        XCTAssertEqual(source.flow, .offline)
        XCTAssertEqual(source.amount, 100000)
        XCTAssertEqual(source.currency, "SGD")
        try validatePayloadCodable(source.paymentInformation)
    }
    func testDecodePayPay() throws {
        let source = try sourceFromSampleJSONFileBy(type: .payPay)
        XCTAssertEqual(source.id, "src_5pqcjr6tu4xvqut5nh5")
        XCTAssertTrue(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.payPay))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 100000)
        XCTAssertEqual(source.currency, "JPY")
        try validatePayloadCodable(source.paymentInformation)
    }
    func testDecodePromptPay() throws {
        let source = try sourceFromSampleJSONFileBy(type: .promptPay)
        XCTAssertEqual(source.id, "src_test_5jb2cjjyjea25nps3ya")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.promptPay))
        XCTAssertEqual(source.flow, .offline)
        XCTAssertEqual(source.amount, 100000)
        XCTAssertEqual(source.currency, "THB")
        try validatePayloadCodable(source.paymentInformation)
    }
    func testDecodeRabbitLinepay() throws {
        let source = try sourceFromSampleJSONFileBy(type: .rabbitLinepay)
        XCTAssertEqual(source.id, "src_test_5owftw9kjhjisssm0n2")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.rabbitLinepay))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 500000)
        XCTAssertEqual(source.currency, "THB")
        try validatePayloadCodable(source.paymentInformation)
    }
    func testDecodeShopeePayJumpApp() throws {
        let source = try sourceFromSampleJSONFileBy(type: .shopeePayJumpApp)
        XCTAssertEqual(source.id, "src_5pqcjr6tu4xvqut5nh5")
        XCTAssertTrue(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.shopeePayJumpApp))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 100000)
        XCTAssertEqual(source.currency, "MYR")
        try validatePayloadCodable(source.paymentInformation)
    }
    func testDecodeShopeePay() throws {
        let source = try sourceFromSampleJSONFileBy(type: .shopeePay)
        XCTAssertEqual(source.id, "src_5pqcjr6tu4xvqut5nh5")
        XCTAssertTrue(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.shopeePay))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 110000)
        XCTAssertEqual(source.currency, "MYR")
        try validatePayloadCodable(source.paymentInformation)
    }
    func testDecodeTouchNGo() throws {
        let source = try sourceFromSampleJSONFileBy(type: .touchNGo)
        XCTAssertEqual(source.id, "src_test_5oxet335rx3xzdyn06g")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.touchNGo))
        XCTAssertEqual(source.flow, .appRedirect)
        XCTAssertEqual(source.amount, 500000)
        XCTAssertEqual(source.currency, "SGD")
        try validatePayloadCodable(source.paymentInformation)
    }

    func testDecodeTrueMoneyJumpApp() throws {
        let source = try sourceFromSampleJSONFileBy(type: .trueMoneyJumpApp)
        XCTAssertEqual(source.id, "src_5yqlbf5w206mcfybj8v")
        XCTAssertTrue(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.trueMoneyJumpApp))
        XCTAssertEqual(source.flow, .appRedirect)
        XCTAssertEqual(source.amount, 500000)
        XCTAssertEqual(source.currency, "THB")
        try validatePayloadCodable(source.paymentInformation)
    }

    func testDecodeBarcodeAlipay() throws {
        let source = try sourceFromSampleJSONFileBy(type: .barcodeAlipay)
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
        try validatePayloadCodable(source.paymentInformation)
    }

    func testDecodeBillPaymentTescoLotus() throws {
        let source = try sourceFromSampleJSONFileBy(type: .billPaymentTescoLotus)
        XCTAssertEqual(source.id, "src_test_59trf2nxk43b5nml8z0")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(.billPaymentTescoLotus))
        XCTAssertEqual(source.flow, .offline)
        XCTAssertEqual(source.amount, 1000000)
        XCTAssertEqual(source.currency, "THB")
        try validatePayloadCodable(source.paymentInformation)
    }
    //  swiftlint:disable:next function_body_length
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

        let source = try sourceFromSampleJSONFileBy(type: .atome)
        XCTAssertEqual(source.id, "src_5yqiaqtbbog2pxjdg6b")
        XCTAssertTrue(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .atome(payload))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 700000)
        XCTAssertEqual(source.currency, "THB")
        try validatePayloadCodable(source.paymentInformation)
    }

    func testDecodeDuitNowOBW() throws {
        let source = try sourceFromSampleJSONFileBy(type: .duitNowOBW)
        let payload = Source.Payload.DuitNowOBW(bank: .affin)
        XCTAssertEqual(source.id, "src_5pqcjr6tu4xvqut5nh5")
        XCTAssertTrue(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .duitNowOBW(payload))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 100000)
        XCTAssertEqual(source.currency, "MYR")
        try validatePayloadCodable(source.paymentInformation)
    }

    func testDecodeInstallmentBay() throws {
        let sourceType: SourceType = .installmentBAY
        let source = try sourceFromSampleJSONFileBy(type: sourceType)
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
        try validatePayloadCodable(source.paymentInformation)
    }

    func testDecodeInstallmentBBL() throws {
        let sourceType: SourceType = .installmentBBL
        let source = try sourceFromSampleJSONFileBy(type: sourceType)
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
        try validatePayloadCodable(source.paymentInformation)
    }

    func testDecodeInstallmentFirstChoice() throws {
        let sourceType: SourceType = .installmentFirstChoice
        let source = try sourceFromSampleJSONFileBy(type: sourceType)
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
        try validatePayloadCodable(source.paymentInformation)
    }

    func testDecodeInstallmentKBank() throws {
        let sourceType: SourceType = .installmentKBank
        let source = try sourceFromSampleJSONFileBy(type: sourceType)
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
        try validatePayloadCodable(source.paymentInformation)
    }

    func testDecodeInstallmentKTC() throws {
        let sourceType: SourceType = .installmentKTC
        let source = try sourceFromSampleJSONFileBy(type: sourceType)
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
        try validatePayloadCodable(source.paymentInformation)
    }

    func testDecodeInstallmentMBB() throws {
        let sourceType: SourceType = .installmentMBB
        let source = try sourceFromSampleJSONFileBy(type: sourceType)
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
        try validatePayloadCodable(source.paymentInformation)
    }

    func testDecodeInstallmentTTB() throws {
        let sourceType: SourceType = .installmentTTB
        let source = try sourceFromSampleJSONFileBy(type: sourceType)
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
        try validatePayloadCodable(source.paymentInformation)
    }

    func testDecodeInstallmentUOB() throws {
        let sourceType: SourceType = .installmentUOB
        let source = try sourceFromSampleJSONFileBy(type: sourceType)
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
        try validatePayloadCodable(source.paymentInformation)
    }

    func testDecodeTrueMoneyWallet() throws {
        let source = try sourceFromSampleJSONFileBy(type: .trueMoneyWallet)
        let payload = Source.Payload.TrueMoneyWallet(phoneNumber: "0123456789")
        XCTAssertEqual(source.id, "src_test_5jhmesi7s4at1qctloy")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .trueMoneyWallet(payload))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 100000)
        XCTAssertEqual(source.currency, "THB")
        try validatePayloadCodable(source.paymentInformation)
    }

    func testDecodeInternetBankingBay() throws {
        let sourceType: SourceType = .internetBankingBAY
        let source = try sourceFromSampleJSONFileBy(type: sourceType)
        XCTAssertEqual(source.id, "src_test_5cs0sm8u8h8nqo5hwcs")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(sourceType))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 100000)
        XCTAssertEqual(source.currency, "THB")
        try validatePayloadCodable(source.paymentInformation)
    }

    func testDecodeInternetBankingBBL() throws {
        let sourceType: SourceType = .internetBankingBBL
        let source = try sourceFromSampleJSONFileBy(type: sourceType)
        XCTAssertEqual(source.id, "src_test_5cs0sfy7phu06yhyz5c")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(sourceType))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 100000)
        XCTAssertEqual(source.currency, "THB")
        try validatePayloadCodable(source.paymentInformation)
    }

    func testDecodeMobileBankingBAY() throws {
        let sourceType: SourceType = .mobileBankingBAY
        let source = try sourceFromSampleJSONFileBy(type: sourceType)
        XCTAssertEqual(source.id, "src_test_5cs0sm8u8h8nqo5zasd")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(sourceType))
        XCTAssertEqual(source.flow, .appRedirect)
        XCTAssertEqual(source.amount, 1000000)
        XCTAssertEqual(source.currency, "THB")
        try validatePayloadCodable(source.paymentInformation)
    }

    func testDecodeMobileBankingBBL() throws {
        let sourceType: SourceType = .mobileBankingBBL
        let source = try sourceFromSampleJSONFileBy(type: sourceType)
        XCTAssertEqual(source.id, "src_test_5cs0sm8u8h8nqo5zasd")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(sourceType))
        XCTAssertEqual(source.flow, .appRedirect)
        XCTAssertEqual(source.amount, 1000000)
        XCTAssertEqual(source.currency, "THB")
        try validatePayloadCodable(source.paymentInformation)
    }

    func testDecodeMobileBankingKBank() throws {
        let sourceType: SourceType = .mobileBankingKBank
        let source = try sourceFromSampleJSONFileBy(type: sourceType)
        XCTAssertEqual(source.id, "src_test_5cs0sm8u8h8nqo5zasd")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(sourceType))
        XCTAssertEqual(source.flow, .appRedirect)
        XCTAssertEqual(source.amount, 1000000)
        XCTAssertEqual(source.currency, "THB")
        try validatePayloadCodable(source.paymentInformation)
    }
    func testDecodeMobileBankingTKB() throws {
        let sourceType: SourceType = .mobileBankingKTB
        let source = try sourceFromSampleJSONFileBy(type: sourceType)
        XCTAssertEqual(source.id, "src_test_5cs0sm8u8h8nqo5zasd")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(sourceType))
        XCTAssertEqual(source.flow, .appRedirect)
        XCTAssertEqual(source.amount, 1000000)
        XCTAssertEqual(source.currency, "THB")
        try validatePayloadCodable(source.paymentInformation)
    }

    func testDecodeMobileBankingSCB() throws {
        let sourceType: SourceType = .mobileBankingSCB
        let source = try sourceFromSampleJSONFileBy(type: sourceType)
        XCTAssertEqual(source.id, "src_test_5cs0sm8u8h8nqo5zasd")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .other(sourceType))
        XCTAssertEqual(source.flow, .appRedirect)
        XCTAssertEqual(source.amount, 1000000)
        XCTAssertEqual(source.currency, "THB")
        try validatePayloadCodable(source.paymentInformation)
    }

    func testDecodeEContext() throws {
        let sourceType: SourceType = .eContext
        let source = try sourceFromSampleJSONFileBy(type: sourceType)
        let payload = Source.Payload.EContext(
            name: "ヤマダタロウ",
            email: "test@opn.com",
            phoneNumber: "01234567891"
        )
        XCTAssertEqual(source.id, "src_test_5xsjw8qafayihquj3k9")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .eContext(payload))
        XCTAssertEqual(source.flow, .offline)
        XCTAssertEqual(source.amount, 300)
        XCTAssertEqual(source.currency, "JPY")
        try validatePayloadCodable(source.paymentInformation)
    }

    func testDecodeFPX() throws {
        let sourceType: SourceType = .fpx
        let source = try sourceFromSampleJSONFileBy(type: sourceType)
        let payload = Source.Payload.FPX(
            bank: .uob,
            email: "support@omise.co"
        )
        XCTAssertEqual(source.id, "src_test_5jhmesi7s4at1qctloz")
        XCTAssertFalse(source.isLiveMode)
        XCTAssertEqual(source.paymentInformation, .fpx(payload))
        XCTAssertEqual(source.flow, .redirect)
        XCTAssertEqual(source.amount, 100000)
        XCTAssertEqual(source.currency, "MYR")
        try validatePayloadCodable(source.paymentInformation)
    }
}
