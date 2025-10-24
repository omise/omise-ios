import UIKit

final class SummaryItemView: UIView {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let contentStack = UIStackView()
    
    var value: String {
        get { valueLabel.text ?? "" }
        set { valueLabel.text = newValue }
    }
    
    init(title: String) {
        super.init(frame: .zero)
        configure(title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(title: String) {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 0
        contentStack.alignment = .fill
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        titleLabel.textColor = .secondaryLabel
        titleLabel.text = title
        titleLabel.numberOfLines = 1
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        
        valueLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.textColor = .label
        valueLabel.numberOfLines = 0
        valueLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        valueLabel.setContentHuggingPriority(.required, for: .vertical)
        
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(valueLabel)
        addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    override var intrinsicContentSize: CGSize {
        let size = contentStack.systemLayoutSizeFitting(
            CGSize(width: UIView.noIntrinsicMetric, height: UIView.layoutFittingCompressedSize.height)
        )
        return CGSize(width: UIView.noIntrinsicMetric, height: size.height)
    }
}
