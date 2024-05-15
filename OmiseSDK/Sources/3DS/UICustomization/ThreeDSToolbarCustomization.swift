import Foundation
import ThreeDS_SDK

public class ThreeDSToolbarCustomization: ThreeDSCustomization {
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

    @discardableResult
    public func backgroundColorHex(_ backgroundColorHex: String?) -> Self {
        self.backgroundColorHex = backgroundColorHex
        return self
    }
    @discardableResult
    public func darkBackgroundColorHex(_ darkBackgroundColorHex: String?) -> Self {
        self.darkBackgroundColorHex = darkBackgroundColorHex
        return self
    }
    @discardableResult
    public func headerText(_ headerText: String?) -> Self {
        self.headerText = headerText
        return self
    }
    @discardableResult
    public func buttonText(_ buttonText: String?) -> Self {
        self.buttonText = buttonText
        return self
    }
}

extension ThreeDS_SDK.ToolbarCustomization {
    convenience init(_ custom: ThreeDSToolbarCustomization) throws {
        self.init()
        try customize(custom)
    }

    func customize(_ custom: ThreeDSToolbarCustomization) throws {
        try customize(omiseThreeDSCustomization: custom)

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
