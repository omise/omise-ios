import Foundation

// Unique named class to use as a reference to create a current Bundle
private final class OmiseSDK216d048c5feca16469a7a71566256537 {
}

extension Bundle {
#if !SWIFT_PACKAGE
    // Legacy implementation to support other package managers, will be removed in a future releases
    static var localBundle = Bundle(for: OmiseSDK216d048c5feca16469a7a71566256537.self)
    static var omiseSDK = Bundle(path: Bundle.localBundle.path(forResource: "OmiseSDK", ofType: "bundle")!) ?? localBundle
#else
    static var omiseSDK = Bundle.module
#endif
}
