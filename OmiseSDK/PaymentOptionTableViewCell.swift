import UIKit

class PaymentOptionTableViewCell: UITableViewCell {
    
    let separatorView: UIView = UIView()
    @IBInspectable var separatorHeight: CGFloat = 1
    
    override init(style: TableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initializeInstance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeInstance()
    }
    
    private func initializeInstance() {
        addSubview(separatorView)
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.selectedCellBackgroundColor
        self.selectedBackgroundView = selectedBackgroundView
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame.size.height = bounds.height - separatorHeight
        var separatorFrame = bounds
        if let textLabel = self.textLabel {
            let textLabelFrame = self.convert(textLabel.frame, from: contentView)
            (_, separatorFrame) = separatorFrame.divided(atDistance: textLabelFrame.minX, from: .minXEdge)
        } else {
            (_, separatorFrame) = separatorFrame.divided(atDistance: layoutMargins.left, from: .minXEdge)
        }
        separatorFrame.origin.y = bounds.height - separatorHeight
        separatorFrame.size.height = separatorHeight
        separatorView.frame = separatorFrame
    }

}
