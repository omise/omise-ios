//
//  AtomeFormViewModelMockup.swift
//  OmiseSDKTests
//
//  Created by Andrei Solovev on 23/5/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation
#if OMISE_SDK_UNIT_TESTING
@testable import OmiseSDK
#endif

class AtomeFormViewModelMockup: AtomeFormViewModelProtocol {
    var countryListViewModel = CountryListViewModelMockup()

    var submitButtonTitle: String = "Next"
    var headerText: String = "Please input the below information to complete the charge creation with Atome."
    var logoName: String = "Atome"
    var titles: [Field: String] = [:]
    var errors: [Field: String] = [:]
    var fields: [Field] = []

    var fieldForShippingAddressHeader: Field? { .country }

    init(submitButtonTitle: String? = nil, titles: [Field: String]? = nil, errors: [Field: String]? = nil) {
        if let submitButtonTitle = submitButtonTitle {
            self.submitButtonTitle = submitButtonTitle
        }
        if let titles = titles {
            self.titles = titles
        }
        if let errors = errors {
            self.errors = errors
        }
    }

    func error(for field: Field, validate: String?) -> String? {
        errors[field]
    }
    
    func title(for field: Field) -> String? {
        if field.isOptional {
            return field.title.localized() + " " + "Atome.field.optional".localized()
        } else {
            return field.title.localized()
        }
    }
    func onSubmitButtonPressed(_ viewContext: ViewContext, onComplete: () -> Void) {
        onComplete()
    }
}

extension AtomeFormViewModelMockup {
    @discardableResult
    func applyMockupTitles() -> Self {
        self.titles = Field.allCases.reduce(into: [Field: String]()) { list, field in
            list[field] = field.rawValue
        }
        return self
    }

    @discardableResult
    func applyMockupFields() -> Self {
        fields = Field.allCases
        return self
    }

}
