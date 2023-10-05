//
//  OMSSourceTypeValue.swift
//  OmiseSDK
//
//  Created by Andrei Solovev on 4/10/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation

public enum OMSSourceTypeValue: String {
    case internetBankingBAY = "internet_banking_bay"
    case internetBankingBBL = "internet_banking_bbl"
    case mobileBankingSCB = "mobile_banking_scb"
    case mobileBankingOCBCPAO = "mobile_banking_ocbc_pao"
    case mobileBankingOCBC = "mobile_banking_ocbc"
    case mobileBankingKBank = "mobile_banking_kbank"
    case mobileBankingBAY = "mobile_banking_bay"
    case mobileBankingBBL = "mobile_banking_bbl"
    case mobileBankingKTB = "mobile_banking_ktb"
    case alipay = "alipay"
    case alipayCN = "alipay_cn"
    case alipayHK = "alipay_hk"
    case dana = "dana"
    case gcash = "gcash"
    case kakaoPay = "kakaopay"
    case touchNGo = "touch_n_go"
    case touchNGoAlipayPlus = "touch_n_go_alipay_plus"
    case billPaymentTescoLotus = "bill_payment_tesco_lotus"
    case barcodeAlipay = "barcode_alipay"
    case installmentBAY = "installment_bay"
    case installmentFirstChoice = "installment_first_choice"
    case installmentBBL = "installment_bbl"
    case installmentMBB = "installment_mbb"
    case installmentKTC = "installment_ktc"
    case installmentKBank = "installment_kbank"
    case installmentSCB = "installment_scb"
    case installmentCiti = "installment_citi"
    case installmentTTB = "installment_ttb"
    case installmentUOB = "installment_uob"
    case eContext = "econtext"
    case promptPay = "promptpay"
    case payNow = "paynow"
    case trueMoney = "truemoney"
    case pointsCiti = "points_citi"
    case fpx = "fpx"
    case rabbitLinepay = "rabbit_linepay"
    case grabPay = "grabpay"
    case grabPayRms = "grabpay_rms"
    case boost = "boost"
    case shopeePay = "shopeepay"
    case shopeePayJumpApp = "shopeepay_jumpapp"
    case maybankQRPay = "maybank_qr"
    case duitNowQR = "duitnow_qr"
    case duitNowOBW = "duitnow_obw"
    case atome = "atome"
    case payPay = "paypay"

    public init?(_ rawValue: String) {
        if let value = OMSSourceTypeValue(rawValue: rawValue) {
            self = value
        } else {
            return nil
        }
    }
}
