import UIKit

class SpacerView: UIView {
    enum Direction {
        case vertical(_ height: CGFloat)
        case horizontal(_ width: CGFloat)
    }

    private let direction: Direction

    init(vertical: CGFloat) {
        self.direction = .vertical(vertical)
        super.init(frame: .zero)
        setupViews()
    }

    init(horizontal: CGFloat) {
        self.direction = .horizontal(horizontal)
        super.init(frame: .zero)
        setupViews()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self
            .backgroundColor(.clear)
            .translatesAutoresizingMaskIntoConstraints(false)

        switch direction {
        case .vertical(let height):
            NSLayoutConstraint.activate([
                heightAnchor.constraint(equalToConstant: height)
            ])
        case .horizontal(let width):
            NSLayoutConstraint.activate([
                widthAnchor.constraint(equalToConstant: width)
            ])
        }
    }
}
