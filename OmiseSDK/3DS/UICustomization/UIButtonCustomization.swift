//
//  UIButtonCustomization.swift
//  OmiseSDK
//
//  Created by Andrei Solovev on 11/9/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation
import ThreeDS_SDK

public class UIButtonCustomization: UICustomization {
    /// Background color of the button in Hex format.
    public var backgroundColorHex: String?

    /// Dark background color of the button in Hex format.
    public var darkBackgroundColorHex: String?

    /// Radius of the button corners.
    public var cornerRadius: Int?

    public init(
        backgroundColorHex: String? = nil,
        darkBackgroundColorHex: String? = nil,
        cornerRadius: Int? = nil,
        textFontName: String? = nil,
        textColorHex: String? = nil,
        darkTextColorHex: String? = nil,
        textFontSize: Int? = nil
    ) {
        super.init(textFontName: textFontName,
                   textColorHex: textColorHex,
                   darkTextColorHex: darkTextColorHex,
                   textFontSize: textFontSize)
        self.backgroundColorHex = backgroundColorHex
        self.darkBackgroundColorHex = darkBackgroundColorHex
        self.cornerRadius = cornerRadius
    }
}

extension ThreeDS_SDK.ButtonCustomization {
    convenience init(omiseButtonCustomization custom: UIButtonCustomization) throws {
        self.init()
        try customize(omiseUICustomization: custom)
        try customize(omiseButtonCustomization: custom)
    }

    func customize(omiseButtonCustomization custom: UIButtonCustomization) throws {
        if let backgroundColorHex = custom.backgroundColorHex {
            try setBackgroundColor(hexColorCode: backgroundColorHex)
        }

        if let darkBackgroundColorHex = custom.darkBackgroundColorHex {
            try setDarkBackgroundColor(hexColorCode: darkBackgroundColorHex)
        }

        if let cornerRadius = custom.cornerRadius {
            try setCornerRadius(cornerRadius: cornerRadius)
        }
    }
}
