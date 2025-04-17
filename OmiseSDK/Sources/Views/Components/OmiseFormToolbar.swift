import UIKit

class OmiseFormToolbar: UIToolbar {
    let onPrevious: VoidClosure
    let onNext: VoidClosure
    let onDone: VoidClosure
    
    private lazy var previousButton: UIBarButtonItem = {
        UIBarButtonItem(
            image: UIImage(omise: "Back"),
            style: .plain,
            target: self,
            action: #selector(previousTapped)
        )
    }()
    
    private lazy var nextButton: UIBarButtonItem = {
        UIBarButtonItem(
            image: UIImage(omise: "Next Field"),
            style: .plain,
            target: self,
            action: #selector(nextTapped)
        )
    }()
    
    private lazy var doneButton: UIBarButtonItem = {
        UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(doneTapped)
        )
    }()
    
    init(
        frame: CGRect = .zero,
        onPrevious: VoidClosure,
        onNext: VoidClosure,
        onDone: VoidClosure
    ) {
        self.onPrevious = onPrevious
        self.onNext = onNext
        self.onDone = onDone
        
        super.init(frame: frame)
        setupToolbar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupToolbar() {
        self.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        
        items = [previousButton, nextButton, flexibleSpace, doneButton]
    }
    
    func setPreviousEnabled(_ isEnabled: Bool) {
        previousButton.isEnabled = isEnabled
    }
    
    func setNextEnabled(_ isEnabled: Bool) {
        nextButton.isEnabled = isEnabled
    }
    
    @objc private func previousTapped() { onPrevious?() }
    
    @objc private func nextTapped() { onNext?() }
    
    @objc private func doneTapped() { onDone?() }
}
