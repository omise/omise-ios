import UIKit

final class PrimaryActionButton: UIButton {
    private var actionHandler: (() -> Void)?
    
    init(title: String, action: @escaping () -> Void) {
        super.init(frame: .zero)
        actionHandler = action
        configure(title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(title: String) {
        translatesAutoresizingMaskIntoConstraints = false
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        backgroundColor = .systemBlue
        layer.cornerRadius = 10
        titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        heightAnchor.constraint(equalToConstant: 48).isActive = true
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }
    
    @objc private func tapped() {
        actionHandler?()
    }
}
