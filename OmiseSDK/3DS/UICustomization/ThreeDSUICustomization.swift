//
//  ThreeDSUICustomization.swift
//  OmiseSDK
//
//  Created by Andrei Solovev on 12/9/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation
import ThreeDS_SDK

public class ThreeDSUICustomization {

    public static var shared: ThreeDSUICustomization?

    /// Sets the attributes of a ButtonCustomization object for a particular button type.
    public var buttonCustomization: [ThreeDS_SDK.UiCustomization.ButtonType: ThreeDSButtonCustomization]?

    /// Sets the attributes of a ButtonCustomization object for an implementer-specific button type.
    public var buttonCustomizationStrings: [String: ThreeDSButtonCustomization]?

    /// Sets the attributes of a ToolbarCustomization object.
    public var toolbarCustomization: ThreeDSToolbarCustomization?

    /// Sets the attributes of a LabelCustomization object.
    public var labelCustomization: ThreeDSLabelCustomization?

    /// Sets the attributes of a TextBoxCustomization object.
    public var textBoxCustomization: ThreeDSTextBoxCustomization?

    public init(
        buttonCustomization: [ThreeDS_SDK.UiCustomization.ButtonType: ThreeDSButtonCustomization]? = nil,
        buttonCustomizationStrings: [String: ThreeDSButtonCustomization]? = nil,
        toolbarCustomization: ThreeDSToolbarCustomization? = nil,
        labelCustomization: ThreeDSLabelCustomization? = nil,
        textBoxCustomization: ThreeDSTextBoxCustomization? = nil
    ) {
        self.buttonCustomization = buttonCustomization
        self.buttonCustomizationStrings = buttonCustomizationStrings
        self.toolbarCustomization = toolbarCustomization
        self.labelCustomization = labelCustomization
        self.textBoxCustomization = textBoxCustomization
    }
}

extension ThreeDS_SDK.UiCustomization {
    convenience init(_ custom: ThreeDSUICustomization) throws {
        self.init()
        try customize(custom)
    }

    func customize(_ custom: ThreeDSUICustomization) throws {
        if let buttonCustomization = custom.buttonCustomization {
            for (buttonType, style) in buttonCustomization {
                let omiseButtonCustomization = try ThreeDS_SDK.ButtonCustomization(style)
                setButtonCustomization(buttonCustomization: omiseButtonCustomization,
                                       buttonType: buttonType)
            }
        }

        if let buttonCustomization = custom.buttonCustomizationStrings {
            for (buttonType, style) in buttonCustomization {
                let omiseButtonCustomization = try ThreeDS_SDK.ButtonCustomization(style)
                try setButtonCustomization(buttonCustomization: omiseButtonCustomization,
                                           btnType: buttonType)
            }
        }

        if let toolbarCustomization = custom.toolbarCustomization {
            let omiseToolbarCustomization = try ThreeDS_SDK.ToolbarCustomization(toolbarCustomization)
            setToolbarCustomization(toolbarCustomization: omiseToolbarCustomization)

        }

        if let labelCustomization = custom.labelCustomization {
            let omiseLabelCustomization = try ThreeDS_SDK.LabelCustomization(labelCustomization)
            setLabelCustomization(labelCustomization: omiseLabelCustomization)
        }

        if let textBoxCustomization = custom.textBoxCustomization {
            let omiseTextBoxCustomization = try ThreeDS_SDK.TextBoxCustomization(textBoxCustomization)
            setTextBoxCustomization(textBoxCustomization: omiseTextBoxCustomization)
        }
    }
}
