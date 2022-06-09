// swiftlint:disable file_length
import XCTest
@testable import OmiseSDK

// swiftlint:disable type_body_length function_body_length
class ModelTestCase: XCTestCase {

    func testDecodeToken() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Token>?.none)
        let tokenData = try XCTestCase.fixturesData(forFilename: "token_object")
        let token = try decoder.decode(Token.self, from: tokenData)

        XCTAssertEqual("tokn_test_5086xl7c9k5rnx35qba", token.id)
        XCTAssertEqual("/tokens/tokn_test_5086xl7c9k5rnx35qba", token.location)
        XCTAssertFalse(token.isLiveMode)
        XCTAssertEqual(XCTestCase.dateFromJSONString("2019-07-26T05:45:20Z"), token.createdDate)
        XCTAssertFalse(token.isUsed)
        XCTAssertEqual("card_test_5086xl7amxfysl0ac5l", token.card?.id)
        XCTAssertEqual(ChargeStatus.unknown, token.chargeStatus)
    }

    func testDecodeTokenWithoutCard() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Token>?.none)
        let tokenData = try XCTestCase.fixturesData(forFilename: "token_with_empty_card_object")
        let token = try decoder.decode(Token.self, from: tokenData)

        XCTAssertEqual("tokn_test_5086xl7c9k5rnx35qba", token.id)
        XCTAssertEqual("/tokens/tokn_test_5086xl7c9k5rnx35qba", token.location)
        XCTAssertFalse(token.isLiveMode)
        XCTAssertEqual(XCTestCase.dateFromJSONString("2019-07-26T05:45:20Z"), token.createdDate)
        XCTAssertFalse(token.isUsed)
        XCTAssertEqual(ChargeStatus.pending, token.chargeStatus)
        XCTAssertNil(token.card)
    }

    func testDecodeCard() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Token>?.none)
        let cardData = try XCTestCase.fixturesData(forFilename: "card_object")
        let card = try decoder.decode(Card.self, from: cardData)

        XCTAssertEqual("card_test_5086xl7amxfysl0ac5l", card.id)
        XCTAssertEqual("4242", card.lastDigits)
        XCTAssertTrue(card.securityCodeCheck)
        XCTAssertEqual(12, card.expirationMonth)
        XCTAssertEqual(2020, card.expirationYear)
        XCTAssertEqual("John Doe", card.name)
        XCTAssertEqual("mKleiBfwp+PoJWB/ipngANuECUmRKjyxROwFW5IO7TM=", card.fingerprint)
        XCTAssertEqual(XCTestCase.dateFromJSONString("2019-07-26T05:45:20Z"), card.createdDate)
        XCTAssertEqual("gb", card.countryCode)
    }

    func testDecodeSource() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Source>?.none)

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_alipay_object")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5avnfnqxzzj2yu7a34e", source.id)
            XCTAssertEqual(Currency.thb, source.currency)
            XCTAssertEqual(1000000, source.amount)
            XCTAssertEqual(PaymentInformation.alipay, source.paymentInformation)
            XCTAssertEqual(Flow.redirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }

    func testBillPaymentSource() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Source>?.none)

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_bill_payment/tesco_lotus")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_59trf2nxk43b5nml8z0", source.id)
            XCTAssertEqual(Currency.thb, source.currency)
            XCTAssertEqual(1000000, source.amount)
            XCTAssertEqual(PaymentInformation.billPayment(.tescoLotus), source.paymentInformation)
            XCTAssertEqual(Flow.offline, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }

    func testDecodeBarcodeSource() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Source>?.none)

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_barcode/alipay")
            let source = try decoder.decode(Source.self, from: sourceData)

            let expectedBarcode = PaymentInformation.Barcode.AlipayBarcode(barcode: "1234567890123456",
                                                                           storeID: "1",
                                                                           storeName: "Main Store",
                                                                           terminalID: nil)

            XCTAssertEqual("src_test_5cq1tilrnz7d62t8y87", source.id)
            XCTAssertEqual(Currency.thb, source.currency)
            XCTAssertEqual(100000, source.amount)
            XCTAssertEqual(.barcode(.alipay(expectedBarcode)), source.paymentInformation)
            XCTAssertEqual(Flow.offline, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }

    func testDecodeInstallmentsSource() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Source>?.none)

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_installments/first_choice")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5cq1ugk8m0un1yefb2u", source.id)
            XCTAssertEqual(Currency.thb, source.currency)
            XCTAssertEqual(5000_00, source.amount)
            XCTAssertEqual(.installment(.init(brand: .firstChoice, numberOfTerms: 6)), source.paymentInformation)
            XCTAssertEqual(Flow.redirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_installments/bay")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5cs0t6x8n0z8rcfrsfi", source.id)
            XCTAssertEqual(Currency.thb, source.currency)
            XCTAssertEqual(5000_00, source.amount)
            XCTAssertEqual(.installment(.init(brand: .bay, numberOfTerms: 6)), source.paymentInformation)
            XCTAssertEqual(Flow.redirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_installments/bbl")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5cs0tdinbyypg6kn1fa", source.id)
            XCTAssertEqual(Currency.thb, source.currency)
            XCTAssertEqual(5000_00, source.amount)
            XCTAssertEqual(.installment(.init(brand: .bbl, numberOfTerms: 6)), source.paymentInformation)
            XCTAssertEqual(Flow.redirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_installments/ezypay")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5obr9opqz5huc6tefw8", source.id)
            XCTAssertEqual(Currency.myr, source.currency)
            XCTAssertEqual(5000_00, source.amount)
            XCTAssertEqual(.installment(.init(brand: .ezypay, numberOfTerms: 6)), source.paymentInformation)
            XCTAssertEqual(Flow.redirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_installments/ktc")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5cs0tk7m2e5ivctrq30", source.id)
            XCTAssertEqual(Currency.thb, source.currency)
            XCTAssertEqual(5000_00, source.amount)
            XCTAssertEqual(.installment(.init(brand: .ktc, numberOfTerms: 6)), source.paymentInformation)
            XCTAssertEqual(Flow.redirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_installments/kbank")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5cs0totfv87k1i6y45l", source.id)
            XCTAssertEqual(Currency.thb, source.currency)
            XCTAssertEqual(5000_00, source.amount)
            XCTAssertEqual(.installment(.init(brand: .kBank, numberOfTerms: 6)), source.paymentInformation)
            XCTAssertEqual(Flow.redirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_installments/citi")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5obr9ossd5huc93kd71", source.id)
            XCTAssertEqual(Currency.thb, source.currency)
            XCTAssertEqual(5000_00, source.amount)
            XCTAssertEqual(.installment(.init(brand: .citi, numberOfTerms: 6)), source.paymentInformation)
            XCTAssertEqual(Flow.redirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_installments/ttb")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5obr9opd7ej5c6tefw8", source.id)
            XCTAssertEqual(Currency.thb, source.currency)
            XCTAssertEqual(5000_00, source.amount)
            XCTAssertEqual(.installment(.init(brand: .ttb, numberOfTerms: 6)), source.paymentInformation)
            XCTAssertEqual(Flow.redirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_installments/uob")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5oe7fj1qz5huc6tefw8", source.id)
            XCTAssertEqual(Currency.thb, source.currency)
            XCTAssertEqual(5000_00, source.amount)
            XCTAssertEqual(.installment(.init(brand: .uob, numberOfTerms: 6)), source.paymentInformation)
            XCTAssertEqual(Flow.redirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }

    func testDecodeInternetBankingSource() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Source>?.none)

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_internet_banking/bay")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5cs0sm8u8h8nqo5hwcs", source.id)
            XCTAssertEqual(Currency.thb, source.currency)
            XCTAssertEqual(1000_00, source.amount)
            XCTAssertEqual(PaymentInformation.internetBanking(.bay), source.paymentInformation)
            XCTAssertEqual(Flow.redirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_internet_banking/bbl")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5cs0sfy7phu06yhyz5c", source.id)
            XCTAssertEqual(Currency.thb, source.currency)
            XCTAssertEqual(1000_00, source.amount)
            XCTAssertEqual(PaymentInformation.internetBanking(.bbl), source.paymentInformation)
            XCTAssertEqual(Flow.redirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_internet_banking/ktb")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5cs0swjx9zguxt0kd0z", source.id)
            XCTAssertEqual(Currency.thb, source.currency)
            XCTAssertEqual(1000_00, source.amount)
            XCTAssertEqual(PaymentInformation.internetBanking(.ktb), source.paymentInformation)
            XCTAssertEqual(Flow.redirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_internet_banking/scb")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5avnh1p1dt3hkh161ac", source.id)
            XCTAssertEqual(Currency.thb, source.currency)
            XCTAssertEqual(1000000, source.amount)
            XCTAssertEqual(PaymentInformation.internetBanking(.scb), source.paymentInformation)
            XCTAssertEqual(Flow.redirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }

    func testDecodeMobileBankingSource() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Source>?.none)

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_mobile_banking/scb")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5cs0sm8u8h8nqo5zasd", source.id)
            XCTAssertEqual(Currency.thb, source.currency)
            XCTAssertEqual(1000000, source.amount)
            XCTAssertEqual(PaymentInformation.mobileBanking(.scb), source.paymentInformation)
            XCTAssertEqual(Flow.appRedirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
        
        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_mobile_banking/kbank")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5cs0sm8u8h8nqo5zasd", source.id)
            XCTAssertEqual(Currency.thb, source.currency)
            XCTAssertEqual(1000000, source.amount)
            XCTAssertEqual(PaymentInformation.mobileBanking(.kbank), source.paymentInformation)
            XCTAssertEqual(Flow.appRedirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
        
        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_mobile_banking/bay")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5cs0sm8u8h8nqo5zasd", source.id)
            XCTAssertEqual(Currency.thb, source.currency)
            XCTAssertEqual(1000000, source.amount)
            XCTAssertEqual(PaymentInformation.mobileBanking(.bay), source.paymentInformation)
            XCTAssertEqual(Flow.appRedirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_mobile_banking/bbl")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5cs0sm8u8h8nqo5zasd", source.id)
            XCTAssertEqual(Currency.thb, source.currency)
            XCTAssertEqual(1000000, source.amount)
            XCTAssertEqual(PaymentInformation.mobileBanking(.bbl), source.paymentInformation)
            XCTAssertEqual(Flow.appRedirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }

    func testDecodeAlipayCNSource() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Source>?.none)

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_alipay_plus/alipay_cn")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5owftw9kjhjisssm0n2", source.id)
            XCTAssertEqual(Currency.thb, source.currency)
            XCTAssertEqual(5000_00, source.amount)
            XCTAssertEqual(PaymentInformation.alipayCN, source.paymentInformation)
            XCTAssertEqual(Flow.appRedirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }

    func testDecodeAlipayHKSource() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Source>?.none)

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_alipay_plus/alipay_hk")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5oxesy9ovpgawobhf6n", source.id)
            XCTAssertEqual(Currency.hkd, source.currency)
            XCTAssertEqual(5000_00, source.amount)
            XCTAssertEqual(PaymentInformation.alipayHK, source.paymentInformation)
            XCTAssertEqual(Flow.appRedirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }

    func testDecodeDANASource() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Source>?.none)

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_alipay_plus/dana")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5oxew5l8jxhss03ybfb", source.id)
            XCTAssertEqual(Currency.jpy, source.currency)
            XCTAssertEqual(5000_00, source.amount)
            XCTAssertEqual(PaymentInformation.dana, source.paymentInformation)
            XCTAssertEqual(Flow.appRedirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }

    func testDecodeGCashSource() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Source>?.none)

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_alipay_plus/gcash")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5oxesgzoekdn5nukcdf", source.id)
            XCTAssertEqual(Currency.usd, source.currency)
            XCTAssertEqual(5000_00, source.amount)
            XCTAssertEqual(PaymentInformation.gcash, source.paymentInformation)
            XCTAssertEqual(Flow.appRedirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }

    func testDecodeKakaoPaySource() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Source>?.none)

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_alipay_plus/kakaopay")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5oxetau2owhu0rbzg7y", source.id)
            XCTAssertEqual(Currency.usd, source.currency)
            XCTAssertEqual(5000_00, source.amount)
            XCTAssertEqual(PaymentInformation.kakaoPay, source.paymentInformation)
            XCTAssertEqual(Flow.appRedirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }

    func testDecodeTouchNGoSource() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Source>?.none)

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_alipay_plus/touch_n_go")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5oxet335rx3xzdyn06g", source.id)
            XCTAssertEqual(Currency.sgd, source.currency)
            XCTAssertEqual(5000_00, source.amount)
            XCTAssertEqual(PaymentInformation.touchNGo, source.paymentInformation)
            XCTAssertEqual(Flow.appRedirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }

    func testDecodePromptPayQRSource() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Source>?.none)

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_qr_payment/promptpay")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5jb2cjjyjea25nps3ya", source.id)
            XCTAssertEqual(100000, source.amount)
            XCTAssertEqual(Currency.thb, source.currency)
            XCTAssertEqual(PaymentInformation.promptpay, source.paymentInformation)
            XCTAssertEqual(Flow.offline, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }

    func testDecodePayNowQRSource() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Source>?.none)

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_qr_payment/paynow")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5iso4taobco8j5jehx5", source.id)
            XCTAssertEqual(100000, source.amount)
            XCTAssertEqual(Currency.sgd, source.currency)
            XCTAssertEqual(PaymentInformation.paynow, source.paymentInformation)
            XCTAssertEqual(Flow.offline, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }

    func testDecodeTrueMoneySource() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Source>?.none)

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_truemoney_object")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5jhmesi7s4at1qctloy", source.id)
            XCTAssertEqual(100000, source.amount)
            XCTAssertEqual(Currency.thb, source.currency)
            XCTAssertEqual(PaymentInformation.truemoney(.init(phoneNumber: "0123456789")), source.paymentInformation)
            XCTAssertEqual(Flow.redirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }
    
    func testDecodeRabbitLinePaySource() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Source>?.none)

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_rabbit_linepay")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5owftw9kjhjisssm0n2", source.id)
            XCTAssertEqual(500000, source.amount)
            XCTAssertEqual(Currency.thb, source.currency)
            XCTAssertEqual(PaymentInformation.rabbitLinepay, source.paymentInformation)
            XCTAssertEqual(Flow.redirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }
    
    func testDecodeOcbcPaoSource() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Source>?.none)

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_ocbc_pao")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5pqcjr6tu4xvqut5nh5", source.id)
            XCTAssertEqual(1000000, source.amount)
            XCTAssertEqual(Currency.sgd, source.currency)
            XCTAssertEqual(PaymentInformation.ocbcPao, source.paymentInformation)
            XCTAssertEqual(Flow.appRedirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }
    
    func testDecodePointsSource() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Source>?.none)

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_points/city_points")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5ji0d5y5w8xd9ll3loh", source.id)
            XCTAssertEqual(100000, source.amount)
            XCTAssertEqual(Currency.thb, source.currency)
            XCTAssertEqual(PaymentInformation.points(.citiPoints), source.paymentInformation)
            XCTAssertEqual(Flow.redirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }

    func testDecodeFPXSource() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Source>?.none)

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_fpx")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_test_5jhmesi7s4at1qctloz", source.id)
            XCTAssertEqual(100000, source.amount)
            XCTAssertEqual(Currency.myr, source.currency)
            XCTAssertEqual(PaymentInformation.fpx(.init(bank: "uob", email: "support@omise.co")), source.paymentInformation)
            XCTAssertEqual(Flow.redirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }

    func testDecodeBoostSource() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Source>?.none)

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_boost")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_5pqcjr6tu4xvqut5nh5", source.id)
            XCTAssertEqual(100000, source.amount)
            XCTAssertEqual(Currency.myr, source.currency)
            XCTAssertEqual(PaymentInformation.boost, source.paymentInformation)
            XCTAssertEqual(Flow.redirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }
    
    func testDecodeShopeePaySource() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Source>?.none)

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_shopeepay")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_5pqcjr6tu4xvqut5nh5", source.id)
            XCTAssertEqual(100000, source.amount)
            XCTAssertEqual(Currency.myr, source.currency)
            XCTAssertEqual(PaymentInformation.shopeePay, source.paymentInformation)
            XCTAssertEqual(Flow.redirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }
    
    func testDecodeMaybankQRPaySource() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Source>?.none)

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_maybank_qrpay")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_5pqcjr6tu4xvqut5nh5", source.id)
            XCTAssertEqual(100000, source.amount)
            XCTAssertEqual(Currency.myr, source.currency)
            XCTAssertEqual(PaymentInformation.maybankQRPay, source.paymentInformation)
            XCTAssertEqual(Flow.redirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }
    
    func testDecodeDuitNowQRSource() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Source>?.none)

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_duitnow_qr")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_5pqcjr6tu4xvqut5nh5", source.id)
            XCTAssertEqual(100000, source.amount)
            XCTAssertEqual(Currency.myr, source.currency)
            XCTAssertEqual(PaymentInformation.duitNowQR, source.paymentInformation)
            XCTAssertEqual(Flow.redirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }
    
    func testDecodeDuitNowOBWSource() throws {
        let decoder = Client.makeJSONDecoder(for: Request<Source>?.none)

        do {
            let sourceData = try XCTestCase.fixturesData(forFilename: "source_duitnow_obw")
            let source = try decoder.decode(Source.self, from: sourceData)

            XCTAssertEqual("src_5pqcjr6tu4xvqut5nh5", source.id)
            XCTAssertEqual(100000, source.amount)
            XCTAssertEqual(Currency.myr, source.currency)
            XCTAssertEqual(PaymentInformation.duitNowOBW(.init(bank: "affin")), source.paymentInformation)
            XCTAssertEqual(Flow.redirect, source.flow)
        } catch {
            XCTFail("Cannot decode the source \(error)")
        }
    }
    
    func testEncodeTokenParams() throws {
        let encoder = Client.makeJSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]

        do {
            let tokenParameter = Token.CreateParameter(name: "John Appleseed",
                                                       number: "4242424242424242",
                                                       expirationMonth: 6,
                                                       expirationYear: 2018,
                                                       securityCode: "123")
            let encodedJSONString = String(data: try encoder.encode(tokenParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "card" : {
                    "expiration_month" : 6,
                    "expiration_year" : 2018,
                    "name" : "John Appleseed",
                    "number" : "4242424242424242",
                    "security_code" : "123"
                  }
                }
                """, encodedJSONString)
        }

        do {
            let tokenParameter = Token.CreateParameter(name: "John Appleseed",
                                                       number: "4242424242424242",
                                                       expirationMonth: 6,
                                                       expirationYear: 2018,
                                                       securityCode: "123",
                                                       city: "Bangkok",
                                                       postalCode: "12345")
            let encodedJSONString = String(data: try encoder.encode(tokenParameter), encoding: .utf8)

            XCTAssertEqual(
                """
                {
                  "card" : {
                    "city" : "Bangkok",
                    "expiration_month" : 6,
                    "expiration_year" : 2018,
                    "name" : "John Appleseed",
                    "number" : "4242424242424242",
                    "postal_code" : "12345",
                    "security_code" : "123"
                  }
                }
                """, encodedJSONString)
        }
    }
}
