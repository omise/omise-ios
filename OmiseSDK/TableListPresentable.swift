import Foundation

protocol TableListPresentable {
    var localizedTitle: String { get }
    var iconName: String { get }
    var accessoryIcon: Assets.Icon { get }
    var localizedSubtitle: String? { get }
}

extension TableListPresentable {
    var localizedSubtitle: String? { nil }
}
