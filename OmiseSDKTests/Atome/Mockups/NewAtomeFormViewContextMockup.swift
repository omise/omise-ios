//
//  NewAtomeFormViewContextMockup.swift
//  OmiseSDKTests
//
//  Created by Andrei Solovev on 23/5/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation
import OmiseTestSDK
#if OMISE_SDK_UNIT_TESTING
@testable import OmiseSDK
#endif

extension NewAtomeFormViewContext {
    static func generateMockup(_ generator: OmiseTestSDK.TestCaseValueGenerator) -> Self {
        NewAtomeFormViewContext(fields: [
            .name: generator.cases(
                .valid("Tester"),
                .valid("", "Name is optional"),
                .valid(" ", "Name is optional, should be trimmed"),
                .invalid("T", "Name is too short")
            ),
            .email: generator.cases(
                .valid("a@a.com"),
                .valid("", "Email is optional"),
                .invalid("a@a", "Invalid format"),
                .invalid("Tester", "Invalid format")
            )
        ])
    }
}
