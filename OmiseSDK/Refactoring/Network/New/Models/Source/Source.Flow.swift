import Foundation

extension SourceNew {

    // The processing flow of a Source
    ///
    /// - redirect: The customer need to be redirected to another URL in order to process the source
    /// - offline: The customer need to do something in offline in order to process the source
    /// - other: Other processing flow
    public enum Flow: String, Codable {
        case redirect
        case offline
        case appRedirect = "app_redirect"
        case unknown

        public init(from decoder: Decoder) throws {
            self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
        }
    }
}
