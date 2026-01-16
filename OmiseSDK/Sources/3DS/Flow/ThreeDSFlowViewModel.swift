import Foundation
import UIKit

public final class ThreeDSFlowViewModel: ThreeDSFlowViewModelProtocol {
    public private(set) var state: ThreeDSFlowState = .idle {
        didSet { onStateChange?(state) }
    }
    
    public var onStateChange: ((ThreeDSFlowState) -> Void)?
    
    private let coordinator: ThreeDSFlowCoordinatorProtocol
    
    public init(coordinator: ThreeDSFlowCoordinatorProtocol) {
        self.coordinator = coordinator
    }
    
    public func start(
        authURL: URL,
        returnURL: String?,
        uiCustomization: ThreeDSUICustomization?,
        from viewController: UIViewController
    ) {
        state = .loadingConfig
        coordinator.start(authURL: authURL,
                          returnURL: returnURL,
                          uiCustomization: uiCustomization,
                          from: viewController) { [weak self] result in
            guard let self else { return }
            self.state = .completed(result)
        }
    }
    
    public func handleDeepLink(_ url: URL) -> Bool {
        coordinator.handleDeepLink(url)
    }
}
