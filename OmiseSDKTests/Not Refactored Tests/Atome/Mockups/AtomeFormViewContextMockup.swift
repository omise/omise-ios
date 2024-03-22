import Foundation
import OmiseUnitTestKit
#if OMISE_SDK_UNIT_TESTING
@testable import OmiseSDK
#endif

extension AtomePaymentFormViewContext {
    static func generateMockup(_ generator: OmiseUnitTestKit.TestCaseValueGenerator) -> Self {
        AtomePaymentFormViewContext(fields: [
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
