import Foundation
import ThreeDS_SDK

public class ThreeDSTextBoxCustomization: ThreeDSCustomization {
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

    @discardableResult
    public func borderColorHex(_ borderColorHex: String?) -> Self {
        self.borderColorHex = borderColorHex
        return self
    }
    @discardableResult
    public func darkBorderColorHex(_ darkBorderColorHex: String?) -> Self {
        self.darkBorderColorHex = darkBorderColorHex
        return self
    }
    @discardableResult
    public func cornerRadius(_ cornerRadius: Int?) -> Self {
        self.cornerRadius = cornerRadius
        return self
    }
    @discardableResult
    public func borderWidth(_ borderWidth: Int?) -> Self {
        self.borderWidth = borderWidth
        return self
    }
}

extension ThreeDS_SDK.TextBoxCustomization {
    convenience init(_ custom: ThreeDSTextBoxCustomization) throws {
        self.init()
        try customize(custom)
    }

    func customize(_ custom: ThreeDSTextBoxCustomization) throws {
        try customize(omiseThreeDSCustomization: custom)

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
