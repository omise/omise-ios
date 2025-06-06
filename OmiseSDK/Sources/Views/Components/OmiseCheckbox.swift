import UIKit

class OmiseCheckbox: UIView {
    private let checkboxButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints(false)
        btn.tintColor = .omisePrimary
        return btn
    }()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints(false)
        lbl.textColor(.omisePrimary)
        lbl.numberOfLines(0)
        return lbl
    }()
    
    private(set) var isChecked: Bool = false {
        didSet {
            updateButtonAppearance()
            onToggle?(isChecked)
        }
    }
    
    var onToggle: ParamClosure<Bool> = nil
    
    init(text: String, isChecked: Bool = false) {
        super.init(frame: .zero)
        setupViews()
        titleLabel.text = text
        self.isChecked = isChecked
        updateButtonAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(checkboxButton)
        addSubview(titleLabel)
        
        checkboxButton.layoutConstraints(width: .size, height: .size)
        NSLayoutConstraint.activate([
            checkboxButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            checkboxButton.topAnchor.constraint(equalTo: topAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: .padding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        checkboxButton.addTarget(self, action: #selector(toggleChecked), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleChecked))
        addGestureRecognizer(tap)
    }
    
    @objc private func toggleChecked() {
        isChecked.toggle()
    }
    
    private func updateButtonAppearance() {
        let image = UIImage(omise: isChecked ? "checked" : "unchecked")
        checkboxButton.setImage(image, for: .normal)
    }
    
    override var intrinsicContentSize: CGSize {
        let buttonSize: CGFloat = .size
        let labelSize = titleLabel.intrinsicContentSize
        let width = buttonSize + .padding + labelSize.width
        let height = max(labelSize.height, buttonSize)
        return CGSize(width: width, height: height)
    }
}

private extension CGFloat {
    static let size: CGFloat = 24
    static let padding: CGFloat = 8
}
