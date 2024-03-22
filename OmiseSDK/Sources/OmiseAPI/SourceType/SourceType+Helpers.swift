import Foundation

extension SourceType {
    var requiresAdditionalDetails: Bool {
        Source.Payment.requiresAdditionalDetails(sourceType: self)
    }
}
