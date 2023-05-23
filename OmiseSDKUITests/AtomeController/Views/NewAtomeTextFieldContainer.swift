//
//  NewAtomeTextFieldContainer.swift
//  OmiseSDKUITests
//
//  Created by Andrei Solovev on 21/5/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import UIKit

class NewAtomeTextFieldContainer: UIView {
    struct Style {
        var errorColor = UIColor(0xFB0000)
        var titleColor = UIColor(0x3C414D)
        var textColor = UIColor(0x3C414D)
    }

    private var style = Style()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = style.titleColor
        return label
    }()
    private lazy var textField: OmiseTextField = {
        let textField = OmiseTextField()
        textField.textColor = style.textColor
        return textField
    }()
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "error!"
        label.textColor = style.errorColor
        return label
    }()
    private lazy var contentView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 0
        return stackView
    }()

    @ProxyProperty(\NewAtomeTextFieldContainer.titleLabel.text) var title: String?
    @ProxyProperty(\NewAtomeTextFieldContainer.textField.placeholder) var placeholder: String?
    @ProxyProperty(\NewAtomeTextFieldContainer.textField.text) var text: String?
    @ProxyProperty(\NewAtomeTextFieldContainer.errorLabel.text) var error: String?

    init(title: String? = nil, text: String? = nil, placeholder: String? = nil, error: String? = nil) {
        super.init(frame: .zero)
        self.title = title
        self.text = text
        self.placeholder = placeholder
        self.error = error
        contentView.addArrangedSubview(titleLabel)
        contentView.addArrangedSubview(textField)
        contentView.addArrangedSubview(errorLabel)
        addSubviewAndFit(contentView)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}


#if SWIFTUI_ENABLED
import SwiftUI
struct NewAtomeTextFieldContainer_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewPresentable(view: NewAtomeTextFieldContainer(title: "Yoo", placeholder: "entered text", error: "!!!!"))
    }
}
#endif
