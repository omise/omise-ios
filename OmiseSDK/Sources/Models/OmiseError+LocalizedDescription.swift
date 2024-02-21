//
//  OmiseError+LocalizedDescription.swift
//  OmiseSDK
//
//  Created by Andrei Solovev on 14/2/24.
//  Copyright © 2024 Omise. All rights reserved.
//

import Foundation

// swiftlint:disable line_length file_length
extension OmiseError {
    var localizedDescription: String {
        switch self {
        case .api(code: let code, message: _, location: _):
            switch code {
            case .invalidCard(let invalidCardReasons):
                switch invalidCardReasons.first {
                case .invalidCardNumber?:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.invalid-card-number.message",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: "Invalid card number",
                        comment: "The displaying message showing in the error banner in the built-in Payment Creator when there is the `invalid-card-number` API error occured"
                    )
                case .invalidExpirationDate?:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.invalid-expiration-date.message",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: "Invalid card expiration date",
                        comment: "The displaying message showing in the error banner in the built-in Payment Creator when there is the `invalid-expiration-date` API error occured"
                    )
                case .emptyCardHolderName?:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.empty-card-holder-name.message",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: "Invalid card holder name",
                        comment: "The displaying message showing in the error banner in the built-in Payment Creator when there is the `empty-card-holder-name` API error occured"
                    )
                case .unsupportedBrand?:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.unsupported-brand.message",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: "Unsupported card brand",
                        comment: "The displaying message showing in the error banner in the built-in Payment Creator when there is the `unsupported-brand` API error occured"
                    )
                case .other?, nil:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.other.message",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: "An unknown error occured",
                        comment: "The displaying message showing in the error banner in the built-in Payment Creator when there is the `other` API error occured"
                    )
                }
            case .badRequest(let badRequestReasons):
                switch badRequestReasons.first {
                case .amountIsLessThanValidAmount(validAmount: let validAmount, currency: let currency)?:
                    if let validAmount = validAmount, let currency = currency {
                        let preferredErrorDescriptionFormat = NSLocalizedString(
                            "payment-creator.error.api.bad_request.amount-is-less-than-valid-amount.with-valid-amount.message",
                            tableName: "Error",
                            bundle: .omiseSDK,
                            value: "Amount is less than the valid amount of %@",
                            comment: "The displaying message showing in the error banner an `Bad request` error with `amount-is-less-than-valid-amount.with-valid-amount` from the backend has occurred"
                        )
                        let formatter = NumberFormatter.makeAmountFormatter(for: currency)
                        return String.localizedStringWithFormat(
                            preferredErrorDescriptionFormat,
                            formatter.string(from: NSNumber(value: currency.convert(fromSubunit: validAmount))) ?? "\(currency.convert(fromSubunit: validAmount))")
                    } else {
                        return NSLocalizedString(
                            "payment-creator.error.api.bad_request.amount-is-less-than-valid-amount.without-valid-amount.message",
                            tableName: "Error",
                            bundle: .omiseSDK,
                            value: "Amount is less than the valid amount",
                            comment: "The displaying message showing in the error banner an `Bad request` error with `amount-is-less-than-valid-amount.without-valid-amount` from the backend has occurred"
                        )
                    }
                case .amountIsGreaterThanValidAmount(validAmount: let validAmount, currency: let currency)?:
                    if let validAmount = validAmount, let currency = currency {
                        let preferredErrorDescriptionFormat = NSLocalizedString(
                            "payment-creator.error.api.bad_request.amount-is-greater-than-valid-amount.with-valid-amount.message",
                            tableName: "Error",
                            bundle: .omiseSDK,
                            value: "Amount is greater than the valid amount of %@",
                            comment: "The displaying message showing in the error banner an `Bad request` error with `amount-is-greater-than-valid-amount.with-valid-amount` from the backend has occurred"
                        )
                        let formatter = NumberFormatter.makeAmountFormatter(for: currency)
                        return String.localizedStringWithFormat(
                            preferredErrorDescriptionFormat,
                            formatter.string(from: NSNumber(value: currency.convert(fromSubunit: validAmount))) ?? "\(currency.convert(fromSubunit: validAmount))")
                    } else {
                        return NSLocalizedString(
                            "payment-creator.error.api.bad_request.amount-is-greater-than-valid-amount.without-valid-amount.message",
                            tableName: "Error",
                            bundle: .omiseSDK,
                            value: "Amount is greater than the valid amount",
                            comment: "The displaying message showing in the error banner an `Bad request` error with `amount-is-greater-than-valid-amount.without-valid-amount` from the backend has occurred"
                        )
                    }
                case .invalidCurrency?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.invalid-currency.message",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: "The currency is invalid",
                        comment: "The displaying message showing in the error banner an `Bad request` error with `invalid-currency` from the backend has occurred"
                    )

                case .emptyName?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.empty-name.message",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: "The customer name is empty",
                        comment: "The displaying message showing in the error banner an `Bad request` error with `empty-name` from the backend has occurred"
                    )

                case .nameIsTooLong(maximum: let maximumLength)?:
                    if let maximumLength = maximumLength {
                        let preferredErrorDescriptionFormat = NSLocalizedString(
                            "payment-creator.error.api.bad_request.name-is-too-long.with-valid-length.message",
                            tableName: "Error",
                            bundle: .omiseSDK,
                            value: "The customer name exceeds %d characters",
                            comment: "The displaying message showing in the error banner an `Bad request` error with `name-is-too-long.with-valid-length` from the backend has occurred"
                        )
                        return String.localizedStringWithFormat(preferredErrorDescriptionFormat, maximumLength)
                    } else {
                        return NSLocalizedString(
                            "payment-creator.error.api.bad_request.name-is-too-long.without-valid-length.message",
                            tableName: "Error",
                            bundle: .omiseSDK,
                            value: "The customer name is too long",
                            comment: "The displaying message showing in the error banner an `Bad request` error with `name-is-too-long.without-valid-length` from the backend has occurred"
                        )
                    }
                case .invalidName?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.invalid-name.message",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: "The customer name is invalid",
                        comment: "The displaying message showing in the error banner an `Bad request` error with `invalid-name` from the backend has occurred"
                    )

                case .invalidEmail?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.invalid-email.message",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: "The customer email is invalid",
                        comment: "The displaying message showing in the error banner an `Bad request` error with `invalid-email` from the backend has occurred"
                    )

                case .invalidPhoneNumber?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.invalid-phone-number.message",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: "The customer phone number is invalid",
                        comment: "The displaying message showing in the error banner an `Bad request` error with `invalid-phone-number` from the backend has occurred"
                    )

                case .typeNotSupported?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.type-not-supported.message",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: "The source type is not supported by this account",
                        comment: "The displaying message showing in the error banner an `Bad request` error with `type-not-supported` from the backend has occurred"
                    )

                case .currencyNotSupported?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.currency-not-supported.message",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: "The currency is not supported for this account",
                        comment: "The displaying message showing in the error banner an `Bad request` error with `currency-not-supported` from the backend has occurred"
                    )
                case .other?, nil:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.other.message",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: "Unknown error occurred",
                        comment: "The displaying message showing in the error banner an `Bad request` error with `other` from the backend has occurred"
                    )
                }
            case .authenticationFailure, .serviceNotFound:
                return NSLocalizedString(
                    "payment-creator.error.api.unexpected.message",
                    tableName: "Error",
                    bundle: .omiseSDK,
                    value: "An unexpected error occured",
                    comment: "The displaying message showing in the error banner in the built-in Payment Creator when there is the `unexpected` API error occured"
                )
            case .other:
                return NSLocalizedString(
                    "payment-creator.error.api.unknown.message",
                    tableName: "Error",
                    bundle: .omiseSDK,
                    value: "An unknown error occured",
                    comment: "The displaying message showing in the error banner when there is an `unknown` API error occured"
                )
            }
        case .unexpected:
            return NSLocalizedString(
                "payment-creator.error.unexpected.message",
                tableName: "Error",
                bundle: .omiseSDK,
                value: "An unexpected error occurred",
                comment: "The displaying message showing in the error banner when there is the `unexpected` error occured"
            )
        }
    }

    var localizedRecoverySuggestion: String {

        enum CommonStrings: String {
            case tryAgainLater = "Please try again later"
        }

        switch self {
        case .api(code: let code, message: _, location: _):
            switch code {
            case .invalidCard(let invalidCardReasons):
                switch invalidCardReasons.first {
                case .invalidCardNumber?:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.invalid-card-number.recovery-suggestion",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: "Please review the card number",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator in the built-in Payment Creator when there is the `invalid-card-number` API error occured"
                    )
                case .invalidExpirationDate?:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.invalid-expiration-date.recovery-suggestion",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: "Please review the card expiration date again.",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator in the built-in Payment Creator when there is the `invalid-expiration-date` API error occured"
                    )
                case .emptyCardHolderName?:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.empty-card-holder-name.recovery-suggestion",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: "Please review the card holder name",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator in the built-in Payment Creator when there is the `empty-card-holder-name` API error occured"
                    )
                case .unsupportedBrand?:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.unsupported-brand.recovery-suggestion",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: "Please use another card",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator in the built-in Payment Creator when there is the `unsupported-brand` API error occured"
                    )
                case .other?, nil:
                    return NSLocalizedString(
                        "payment-creator.error.api.invalid_card.other.recovery-suggestion",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: CommonStrings.tryAgainLater.rawValue,
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator in the built-in Payment Creator when there is the `other` API error occured"
                    )
                }
            case .badRequest(let badRequestReasons):
                switch badRequestReasons.first {
                case .amountIsLessThanValidAmount(validAmount: let validAmount, currency: let currency)?:
                    if let validAmount = validAmount, let currency = currency {
                        let preferredErrorDescriptionFormat = NSLocalizedString(
                            "payment-creator.error.api.bad_request.amount-is-less-than-valid-amount.with-valid-amount.recovery-suggestion",
                            tableName: "Error",
                            bundle: .omiseSDK,
                            value: "The payment amount is too low. Please make a payment with a higher amount.",
                            comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `amount-is-less-than-valid-amount.with-valid-amount` from the backend has occurred"
                        )
                        let formatter = NumberFormatter.makeAmountFormatter(for: currency)
                        return String.localizedStringWithFormat(
                            preferredErrorDescriptionFormat,
                            formatter.string(from: NSNumber(value: currency.convert(fromSubunit: validAmount))) ?? "\(currency.convert(fromSubunit: validAmount))")
                    } else {
                        return NSLocalizedString(
                            "payment-creator.error.api.bad_request.amount-is-less-than-valid-amount.without-valid-amount.recovery-suggestion",
                            tableName: "Error",
                            bundle: .omiseSDK,
                            value: "The payment amount is too low. Please make a payment with a higher amount.",
                            comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `amount-is-less-than-valid-amount.without-valid-amount` from the backend has occurred"
                        )
                    }
                case .amountIsGreaterThanValidAmount(validAmount: let validAmount, currency: let currency)?:
                    if let validAmount = validAmount, let currency = currency {
                        let preferredErrorDescriptionFormat = NSLocalizedString(
                            "payment-creator.error.api.bad_request.amount-is-greater-than-valid-amount.with-valid-amount.recovery-suggestion",
                            tableName: "Error",
                            bundle: .omiseSDK,
                            value: "The payment amount is too high. Please make a payment with a lower amount.",
                            comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `amount-is-greater-than-valid-amount.with-valid-amount` from the backend has occurred"
                        )
                        let formatter = NumberFormatter.makeAmountFormatter(for: currency)
                        return String.localizedStringWithFormat(
                            preferredErrorDescriptionFormat,
                            formatter.string(from: NSNumber(value: currency.convert(fromSubunit: validAmount))) ?? "\(currency.convert(fromSubunit: validAmount))")
                    } else {
                        return NSLocalizedString(
                            "payment-creator.error.api.bad_request.amount-is-greater-than-valid-amount.without-valid-amount.recovery-suggestion",
                            tableName: "Error",
                            bundle: .omiseSDK,
                            value: "The payment amount is too high. Please make a payment with a lower amount.",
                            comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `amount-is-greater-than-valid-amount.without-valid-amount` from the backend has occurred"
                        )
                    }
                case .invalidCurrency?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.invalid-currency.recovery-suggestion",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: "Please choose another currency or contact customer support",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `invalid-currency` from the backend has occurred"
                    )

                case .emptyName?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.empty-name.recovery-suggestion",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: "Please fill in the customer name",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `empty-name` from the backend has occurred"
                    )

                case .nameIsTooLong(maximum: _)?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.name-is-too-long.recovery-suggestion",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: "Please review the customer name",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `name-is-too-long.without-valid-length` from the backend has occurred"
                    )
                case .invalidName?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.invalid-name.recovery-suggestion",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: "Please review the customer name",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `invalid-name` from the backend has occurred"
                    )

                case .invalidEmail?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.invalid-email.recovery-suggestion",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: "Please review the email",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `invalid-email` from the backend has occurred"
                    )

                case .invalidPhoneNumber?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.invalid-phone-number.recovery-suggestion",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: "Please review the phone number",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `invalid-phone-number` from the backend has occurred"
                    )

                case .typeNotSupported?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.type-not-supported.recovery-suggestion",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: "Please contact customer support",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `type-not-supported` from the backend has occurred"
                    )

                case .currencyNotSupported?:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.currency-not-supported.recovery-suggestion",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: "Please choose another currency",
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `currency-not-supported` from the backend has occurred"
                    )
                case .other?, nil:
                    return NSLocalizedString(
                        "payment-creator.error.api.bad_request.other.recovery-suggestion",
                        tableName: "Error",
                        bundle: .omiseSDK,
                        value: CommonStrings.tryAgainLater.rawValue,
                        comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator an `Bad request` error with `other` from the backend has occurred"
                    )
                }
            case .authenticationFailure, .serviceNotFound:
                return NSLocalizedString(
                    "payment-creator.error.api.unexpected.recovery-suggestion",
                    tableName: "Error",
                    bundle: .omiseSDK,
                    value: CommonStrings.tryAgainLater.rawValue,
                    comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator when there is the `unexpected` API error occured"
                )
            case .other:
                return NSLocalizedString(
                    "payment-creator.error.api.unknown.recovery-suggestion",
                    tableName: "Error",
                    bundle: .omiseSDK,
                    value: CommonStrings.tryAgainLater.rawValue,
                    comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator when there is an `unknown` API error occured"
                )
            }
        case .unexpected:
            return NSLocalizedString(
                "payment-creator.error.unexpected.recovery-suggestion",
                tableName: "Error",
                bundle: .omiseSDK,
                value: CommonStrings.tryAgainLater.rawValue,
                comment: "The displaying recovery from error suggestion showing in the error banner in the built-in Payment Creator when there is the `unexpected` error occured"
            )
        }
    }
}
// swiftlint:enable line_length
