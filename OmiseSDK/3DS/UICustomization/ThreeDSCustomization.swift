//
//  ThreeDSCustomization.swift
//  OmiseSDK
//
//  Created by Andrei Solovev on 11/9/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation
import ThreeDS_SDK

public class ThreeDSCustomization {
    /// Text font name.
    public var textFontName: String?

    /// Text color in Hex format.
    public var textColorHex: String?

    /// Dark text color in Hex format.
    public var darkTextColorHex: String?

    /// Text font size.
    public var textFontSize: Int?

    public init(
        textFontName: String? = nil,
        textColorHex: String? = nil,
        darkTextColorHex: String? = nil,
        textFontSize: Int? = nil
    ) {
        self.textFontName = textFontName
        self.textColorHex = textColorHex
        self.darkTextColorHex = darkTextColorHex
        self.textFontSize = textFontSize
    }
}

extension ThreeDS_SDK.Customization {
    func customize(omiseThreeDSCustomization custom: ThreeDSCustomization) throws {
        if let textFontName = custom.textFontName {
            try setTextFontName(fontName: textFontName)
        }

        if let textColorHex = custom.textColorHex {
            try setTextColor(hexColorCode: textColorHex)
        }

        if let darkTextColorHex = custom.darkTextColorHex {
            try setDarkTextColor(hexColorCode: darkTextColorHex)
        }

        if let textFontSize = custom.textFontSize {
            try setTextFontSize(fontSize: textFontSize)
        }
    }
}
