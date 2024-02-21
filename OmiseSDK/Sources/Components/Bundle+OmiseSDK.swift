import Foundation

// Unique named class to use as a reference to create a current Bundle
private final class OmiseSDK216d048c5feca16469a7a71566256537 {
}

extension Bundle {
#if !SWIFT_PACKAGE
    // Legacy implementation to support other package managers, will be removed in a future releases
    static var omiseSDK = Bundle(for: OmiseSDK216d048c5feca16469a7a71566256537.self)
#else
    static var omiseSDK = Bundle.module
#endif
}
