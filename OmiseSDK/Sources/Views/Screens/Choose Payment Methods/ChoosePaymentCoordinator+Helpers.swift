import UIKit

extension ChoosePaymentCoordinator {
    func navigate(to viewController: UIViewController) {
        rootViewController?.navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }

    func processError(_ error: Error) {
        if handleErrors {
            if let error = error as? OmiseError {
                displayErrorWith(title: error.localizedDescription,
                                 message: error.localizedRecoverySuggestion,
                                 animated: true,
                                 sender: self)
            } else if let error = error as? LocalizedError {
                displayErrorWith(title: error.localizedDescription,
                                 message: error.recoverySuggestion,
                                 animated: true,
                                 sender: self)
            } else {
                displayErrorWith(title: error.localizedDescription,
                                 message: nil,
                                 animated: true,
                                 sender: self)
            }
        } else {
            choosePaymentMethodDelegate?.choosePaymentMethodDidComplete(with: error)
        }
    }

    func processPayment(_ card: CreateTokenPayload.Card, completion: @escaping () -> Void) {
        guard let delegate = choosePaymentMethodDelegate else { return }
        let tokenPayload = CreateTokenPayload(card: card)

        client.createToken(payload: tokenPayload) { [weak self, weak delegate] result in
            switch result {
            case .success(let token):
                delegate?.choosePaymentMethodDidComplete(with: token)
            case .failure(let error):
                self?.processError(error)
            }
            completion()
        }
    }

    func processPayment(_ payment: Source.Payment, completion: @escaping () -> Void) {
        guard let delegate = choosePaymentMethodDelegate else { return }
        let sourcePayload = CreateSourcePayload(
            amount: amount,
            currency: currency,
            details: payment
        )

        client.createSource(payload: sourcePayload) { [weak self, weak delegate] result in
            switch result {
            case .success(let source):
                delegate?.choosePaymentMethodDidComplete(with: source)
            case .failure(let error):
                self?.processError(error)
            }
            completion()
        }
    }

    func processWhiteLabelInstallmentPayment(_ payment: Source.Payment, card: CreateTokenPayload.Card, completion: @escaping () -> Void) {

        guard let delegate = choosePaymentMethodDelegate else { return }
        let sourcePayload = CreateSourcePayload(
            amount: amount,
            currency: currency,
            details: payment
        )

        let tokenPayload = CreateTokenPayload(card: card)

        client.createSource(payload: sourcePayload) { [weak self, weak delegate, tokenPayload] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.processError(error)
                DispatchQueue.main.async {
                    completion()
                }
            case .success(let source):
                self.client.createToken(payload: tokenPayload) { [weak self, weak delegate] result in
                    switch result {
                    case .success(let token):
                        delegate?.choosePaymentMethodDidComplete(with: source, token: token)
                    case .failure(let error):
                        self?.processError(error)
                        DispatchQueue.main.async {
                            completion()
                        }
                    }
                }
            }
        }
    }
}

extension ChoosePaymentCoordinator {
    func setupErrorView() {
        errorViewHeightConstraint = errorView.heightAnchor.constraint(equalToConstant: 0)
        errorViewHeightConstraint?.isActive = true

        let dismissErrorBannerTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                            action: #selector(self.dismissErrorMessageBanner(_:)))
        errorView.addGestureRecognizer(dismissErrorBannerTapGestureRecognizer)
    }

    /// Displays an error banner at the top of the UI with the given error message.
    ///
    /// - Parameters:
    ///   - title: Title message to be displayed in the banner
    ///   - message: Subtitle message to be displayed in the banner
    ///   - animated: Pass true to animate the presentation; otherwise, pass false
    ///   - sender: The object that initiated the request
    func displayErrorWith(title: String, message: String?, animated: Bool, sender: Any?) {
        guard let navController = rootViewController?.navigationController else { return }

        errorView.titleLabel.text = title
        errorView.detailLabel.text = message
        navController.view.insertSubview(self.errorView, belowSubview: navController.navigationBar)

        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: navController.navigationBar.bottomAnchor),
            errorView.leadingAnchor.constraint(equalTo: navController.view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: navController.view.trailingAnchor)
        ])

        errorViewHeightConstraint?.isActive = true
        navController.view.layoutIfNeeded()

        let animationBlock = { [weak navController] in
            guard let navController = navController else { return }
            self.errorViewHeightConstraint?.isActive = false
            navController.view.layoutIfNeeded()
            if #available(iOS 13, *) {
                navController.topViewController?.additionalSafeAreaInsets.top = self.errorView.bounds.height
            } else if #available(iOS 11, *) {
                navController.additionalSafeAreaInsets.top = self.errorView.bounds.height
            }
        }

        if animated {
            UIView.animate(withDuration: TimeInterval(UINavigationController.hideShowBarDuration) + 0.07,
                           delay: 0.0,
                           options: [.layoutSubviews, .beginFromCurrentState],
                           animations: animationBlock)
        } else {
            animationBlock()
        }
    }

    @objc func dismissErrorMessageBanner(_ sender: AnyObject) {
        dismissErrorMessage(animated: true, sender: sender)
    }

    func dismissErrorMessage(animated: Bool, sender: Any?) {
        guard errorView.superview != nil, let navController = rootViewController?.navigationController else {
            return
        }

        let animationBlock = { [weak navController] in
            self.errorViewHeightConstraint?.isActive = true
            navController?.view.layoutIfNeeded()
            if #available(iOS 13, *) {
                navController?.topViewController?.additionalSafeAreaInsets.top = 0
            } else if #available(iOS 11, *) {
                navController?.topViewController?.additionalSafeAreaInsets.top = 0
            }
        }

        if animated {
            UIView.animate(
                withDuration: TimeInterval(UINavigationController.hideShowBarDuration),
                delay: 0.0,
                options: [.layoutSubviews],
                animations: animationBlock
            ) { [weak navController] _ in
                var isCompleted: Bool {
                    if #available(iOS 13, *) {
                        return navController?.topViewController?.additionalSafeAreaInsets.top == 0
                    } else if #available(iOS 11, *) {
                        return navController?.topViewController?.additionalSafeAreaInsets.top == 0
                    } else {
                        return true
                    }
                }
                guard isCompleted else { return }
                self.errorView.removeFromSuperview()
            }
        } else {
            animationBlock()
            self.errorView.removeFromSuperview()
        }
    }
}

extension ChoosePaymentCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        dismissErrorMessage(animated: animated, sender: nil)
    }
}
