import UIKit
import OmiseSDK

struct ExampleAppDependencies {
    let settingsStore: PaymentSettingsStore
    let config: LocalConfig
}

class ViewModelViewController<ViewModel>: UIViewController {
    let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
