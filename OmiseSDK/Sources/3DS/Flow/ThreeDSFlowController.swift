import Foundation
import UIKit

public final class ThreeDSFlowController {
    private let coordinator: ThreeDSFlowCoordinatorProtocol
    
    public init(
        repository: ThreeDSRepositoryProtocol = ThreeDSRepository(),
        sdkService: ThreeDSSDKServiceProtocol = NetceteraThreeDSSDKService(),
        callbackQueue: DispatchQueue = .main
    ) {
        self.coordinator = ThreeDSFlowCoordinator(
            repository: repository,
            sdkService: sdkService,
            callbackQueue: callbackQueue
        )
    }
    
    @discardableResult
    public func handleDeepLink(_ url: URL) -> Bool {
        coordinator.handleDeepLink(url)
    }
    
    public func start(
        authorizeURL: URL,
        threeDSRequestorAppURLString: String?,
        uiCustomization: ThreeDSUICustomization?,
        from viewController: UIViewController,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        coordinator.start(
            authURL: authorizeURL,
            returnURL: threeDSRequestorAppURLString,
            uiCustomization: uiCustomization,
            from: viewController
        ) { result in
            switch result {
            case .completed:
                completion(.success(()))
            case .cancelled:
                completion(.failure(ThreeDSFlowControllerError.cancelled))
            case .failed(let message):
                completion(.failure(ThreeDSFlowControllerError.failed(message)))
            }
        }
    }
}
