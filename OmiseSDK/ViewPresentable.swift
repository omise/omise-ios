import Foundation

protocol ViewPresentable {
    var localizedTitle: String { get }
    var iconName: String { get }
    var accessoryIcon: Assets.Icon { get }
    var localizedSubtitle: String? { get }
}

extension ViewPresentable {
    var localizedSubtitle: String? { nil }
}
