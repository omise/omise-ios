//
//  NewAtomeFormViewModelMockup.swift
//  OmiseSDKTests
//
//  Created by Andrei Solovev on 23/5/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation
#if OMISE_SDK_UNIT_TESTING
@testable import OmiseSDK
#endif

class NewAtomeFormViewModelMockup: NewAtomeFormViewModelProtocol {
    var titleForNextButton: String = "Next"
    var titles: [Field: String] = [:]
    var errors: [Field: String] = [:]

    init(titleForNextButton: String? = nil, titles: [Field: String]? = nil, errors: [Field: String]? = nil) {
        if let titleForNextButton = titleForNextButton {
            self.titleForNextButton = titleForNextButton
        }
        if let titles = titles {
            self.titles = titles
        }
        if let errors = errors {
            self.errors = errors
        }
    }

    func error(for field: Field, value: String?) -> String? {
        errors[field]
    }
    func title(for field: Field) -> String? {
        titles[field]
    }
    func onNextButtonPressed(_ viewContext: ViewContext, onComplete: () -> Void) {
        onComplete()
    }
}

extension NewAtomeFormViewModelMockup {
    @discardableResult func applyMockupTitles() -> Self {
        self.titles = Field.allCases.reduce(into: [Field: String]()) { list, field in
            list[field] = field.rawValue
        }
        return self
    }
}
