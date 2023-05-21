//
//  NewAtomeTextFieldContainer.swift
//  OmiseSDKUITests
//
//  Created by Andrei Solovev on 21/5/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import UIKit

class NewAtomeTextFieldContainer: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    private lazy var textField: OmiseTextField = {
        let textField = OmiseTextField()
        return textField
    }()
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    @ProxyProperty(\NewAtomeTextFieldContainer.titleLabel.text) var title: String?
    @ProxyProperty(\NewAtomeTextFieldContainer.textField.text) var text: String?
    @ProxyProperty(\NewAtomeTextFieldContainer.errorLabel.text) var error: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(textField)
        addSubview(errorLabel)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
