import Foundation

protocol SelectSourceTypeDelegate: AnyObject {
    func didSelectSourceType(_ sourceType: SourceType, completion: @escaping () -> Void)
}
