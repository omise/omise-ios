//
//  UIToolbarCustomization.swift
//  OmiseSDK
//
//  Created by Andrei Solovev on 11/9/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation
import ThreeDS_SDK

public class UIToolbarCustomization: UICustomization {
    /// Background color for the toolbar in Hex format.
    public var backgroundColorHex: String?

    /// Dark background color for the toolbar in Hex format.
    public var darkBackgroundColorHex: String?

    /// Header text of the toolbar.
    public var headerText: String?

    /// Button text of the toolbar. For example, “Cancel”.
    public var buttonText: String?

    public init(
        backgroundColorHex: String? = nil,
        darkBackgroundColorHex: String? = nil,
        headerText: String? = nil,
        buttonText: String? = nil,
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
        self.headerText = headerText
        self.buttonText = buttonText
    }
}

extension ThreeDS_SDK.ToolbarCustomization {
    convenience init(omiseToolbarCustomization custom: UIToolbarCustomization) throws {
        self.init()
        try customize(omiseUICustomization: custom)
        try customize(omiseToolbarCustomization: custom)
    }

    func customize(omiseToolbarCustomization custom: UIToolbarCustomization) throws {
        if let backgroundColorHex = custom.backgroundColorHex {
            try setBackgroundColor(hexColorCode: backgroundColorHex)
        }

        if let darkBackgroundColorHex = custom.darkBackgroundColorHex {
            try setDarkBackgroundColor(hexColorCode: darkBackgroundColorHex)
        }

        if let headerText = custom.headerText {
            try setHeaderText(headerText: headerText)
        }

        if let buttonText = custom.buttonText {
            try setButtonText(buttonText: buttonText)
        }
    }
}
