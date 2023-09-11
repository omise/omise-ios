//
//  UILabelCustomization.swift
//  OmiseSDK
//
//  Created by Andrei Solovev on 11/9/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation
import ThreeDS_SDK

public class UILabelCustomization: UICustomization {
    /// Color of the heading label text in Hex format.
    public var headingTextColorHex: String?

    /// Dark color of the heading label text in Hex format.
    public var headingDarkTextColorHex: String?

    /// Font name of the heading label text.
    public var headingTextFontName: String?

    /// Font size of the heading label text.
    public var headingTextFontSize: Int?

    public init(
        headingTextColorHex: String? = nil,
        headingDarkTextColorHex: String? = nil,
        headingTextFontName: String? = nil,
        headingTextFontSize: Int? = nil,
        textFontName: String? = nil,
        textColorHex: String? = nil,
        darkTextColorHex: String? = nil,
        textFontSize: Int? = nil
    ) {
        super.init(textFontName: textFontName,
                   textColorHex: textColorHex,
                   darkTextColorHex: darkTextColorHex,
                   textFontSize: textFontSize)
        self.headingTextColorHex = headingTextColorHex
        self.headingDarkTextColorHex = headingDarkTextColorHex
        self.headingTextFontName = headingTextFontName
        self.headingTextFontSize = headingTextFontSize
    }
}

extension ThreeDS_SDK.LabelCustomization {
    convenience init(omiseLabelCustomization custom: UILabelCustomization) throws {
        self.init()
        try customize(omiseUICustomization: custom)
        try customize(omiseLabelCustomization: custom)
    }

    func customize(omiseLabelCustomization custom: UILabelCustomization) throws {
        if let headingTextColorHex = custom.headingTextColorHex {
            try setHeadingTextColor(hexColorCode: headingTextColorHex)
        }

        if let headingDarkTextColorHex = custom.headingDarkTextColorHex {
            try setHeadingDarkTextColor(hexColorCode: headingDarkTextColorHex)
        }

        if let headingTextFontName = custom.headingTextFontName {
            try setHeadingTextFontName(fontName: headingTextFontName)
        }

        if let headingTextFontSize = custom.headingTextFontSize {
            try setHeadingTextFontSize(fontSize: headingTextFontSize)
        }
    }
}
