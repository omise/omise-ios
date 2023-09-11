//
//  UITextBoxCustomization.swift
//  OmiseSDK
//
//  Created by Andrei Solovev on 11/9/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation
import ThreeDS_SDK

public class UITextBoxCustomization: UICustomization {
    /// Width of the text box border.
    public var borderWidth: Int?

    /// Color of the text box border in Hex format.
    public var borderColorHex: String?

    /// Dark color of the text box border in Hex format.
    public var darkBorderColorHex: String?

    /// Corner radius of the text box corners.
    public var cornerRadius: Int?

    public init(
        borderWidth: Int? = nil,
        borderColorHex: String? = nil,
        darkBorderColorHex: String? = nil,
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
        self.borderWidth = borderWidth
        self.borderColorHex = borderColorHex
        self.darkBorderColorHex = darkBorderColorHex
        self.cornerRadius = cornerRadius
    }
}

extension ThreeDS_SDK.TextBoxCustomization {
    convenience init(omiseTextBoxCustomization custom: UITextBoxCustomization) throws {
        self.init()
        try customize(omiseUICustomization: custom)
        try customize(omiseTextBoxCustomization: custom)
    }

    func customize(omiseTextBoxCustomization custom: UITextBoxCustomization) throws {
        if let borderWidth = custom.borderWidth {
            try setBorderWidth(borderWidth: borderWidth)
        }

        if let borderColorHex = custom.borderColorHex {
            try setBorderColor(hexColorCode: borderColorHex)
        }

        if let darkBorderColorHex = custom.darkBorderColorHex {
            try setDarkBorderColor(hexColorCode: darkBorderColorHex)
        }

        if let textFontSize = custom.textFontSize {
            try setTextFontSize(fontSize: textFontSize)
        }
    }
}
