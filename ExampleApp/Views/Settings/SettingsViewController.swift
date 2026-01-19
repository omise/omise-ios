import UIKit

final class SettingsViewController: ViewModelViewController<SettingsViewModel> {
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: TextFieldTableViewCell.reuseIdentifier)
        return tableView
    }()
    
    private lazy var modeControl: UISegmentedControl = {
        let control = UISegmentedControl(items: SettingsViewModel.Mode.allCases.map { $0.title })
        control.addTarget(self, action: #selector(modeChanged(_:)), for: .valueChanged)
        control.selectedSegmentIndex = viewModel.mode.rawValue
        control.selectedSegmentTintColor = view.tintColor
        control.setTitleTextAttributes([
            .font: UIFont.preferredFont(forTextStyle: .callout),
            .foregroundColor: UIColor.secondaryLabel
        ], for: .normal)
        control.setTitleTextAttributes([
            .font: UIFont.preferredFont(forTextStyle: .callout),
            .foregroundColor: UIColor.white
        ], for: .selected)
        return control
    }()
    
    private lazy var accessoryToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [flex, done]
        return toolbar
    }()
    
    private var keyboardObservers: [NSObjectProtocol] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Setup"
        view.backgroundColor = .systemBackground
        layout()
        configureBindings()
        registerKeyboardNotifications()
    }
    
    deinit {
        keyboardObservers.forEach { NotificationCenter.default.removeObserver($0) }
    }
    
    private func layout() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let headerContainer = UIView()
        modeControl.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(modeControl)
        NSLayoutConstraint.activate([
            modeControl.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            modeControl.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            modeControl.leadingAnchor.constraint(greaterThanOrEqualTo: headerContainer.leadingAnchor, constant: 16)
        ])
        headerContainer.layoutIfNeeded()
        let size = headerContainer.systemLayoutSizeFitting(CGSize(
            width: view.bounds.width,
            height: UIView.layoutFittingCompressedSize.height
        ))
        headerContainer.frame = CGRect(origin: .zero, size: CGSize(width: view.bounds.width, height: max(56, size.height)))
        tableView.tableHeaderView = headerContainer
    }
    
    private func configureBindings() {
        viewModel.onChange = { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }
                self.modeControl.selectedSegmentIndex = self.viewModel.mode.rawValue
                self.tableView.reloadData()
            }
        }
    }
    
    @objc private func modeChanged(_ sender: UISegmentedControl) {
        guard let mode = SettingsViewModel.Mode(rawValue: sender.selectedSegmentIndex) else { return }
        viewModel.selectMode(mode)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func registerKeyboardNotifications() {
        let center = NotificationCenter.default
        let willChange = center.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleKeyboard(notification: notification)
        }
        keyboardObservers.append(willChange)
    }
    
    private func handleKeyboard(notification: Notification) {
        guard view.window != nil,
              let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let animationCurveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }
        
        let convertedFrame = view.convert(keyboardFrame, from: nil)
        let intersection = view.bounds.intersection(convertedFrame)
        let bottomInset = max(0, intersection.height - view.safeAreaInsets.bottom)
        
        let options = UIView.AnimationOptions(rawValue: animationCurveRaw << 16)
        UIView.animate(withDuration: animationDuration, delay: 0, options: [options, .beginFromCurrentState]) {
            self.tableView.contentInset.bottom = bottomInset
            var indicatorInsets = self.tableView.verticalScrollIndicatorInsets
            indicatorInsets.bottom = bottomInset
            self.tableView.verticalScrollIndicatorInsets = indicatorInsets
            if bottomInset > 0 {
                self.scrollCurrentResponderIntoView()
            }
        }
    }
    
    private func scrollCurrentResponderIntoView() {
        guard let responder = view.currentFirstResponder(), responder.isDescendant(of: tableView) else { return }
        let responderRect = tableView.convert(responder.bounds, from: responder)
        tableView.scrollRectToVisible(responderRect, animated: false)
    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let descriptor = sectionDescriptor(for: section) else { return 0 }
        return viewModel.numberOfRows(in: descriptor)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let descriptor = sectionDescriptor(for: section) else { return nil }
        return viewModel.headerTitle(for: descriptor)
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let descriptor = sectionDescriptor(for: section) else { return nil }
        return viewModel.footerTitle(for: descriptor)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let descriptor = sectionDescriptor(for: indexPath.section) else { return UITableViewCell() }
        switch descriptor {
        case .presets:
            return presetCell(at: indexPath, in: tableView)
        case .payment:
            return paymentCell(at: indexPath, in: tableView)
        case .capability:
            return capabilityCell(at: indexPath, in: tableView)
        case .installments:
            return installmentsCell(at: indexPath, in: tableView)
        case .paymentMethods(let index):
            return paymentMethodCell(at: indexPath, sectionIndex: index, in: tableView)
        case .developer:
            return developerCell(at: indexPath, in: tableView)
        }
    }
    
    private func presetCell(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        let preset = viewModel.presets[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "preset") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "preset")
        cell.textLabel?.text = preset.title
        cell.detailTextLabel?.text = preset.detail
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .footnote)
        cell.accessoryType = preset.isSelected ? .checkmark : .none
        cell.selectionStyle = .default
        return cell
    }
    
    private func paymentCell(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = dequeueTextFieldCell(in: tableView, for: indexPath)
            cell.configure(
                title: "Amount",
                text: viewModel.amountText,
                placeholder: viewModel.amountPlaceholder,
                keyboardType: viewModel.amountKeyboardType,
                accessory: accessoryToolbar
            )
            cell.onCommit = { [weak self] text in
                self?.viewModel.updateAmount(with: text)
            }
            return cell
        } else {
            let option = viewModel.currencyOptions[indexPath.row - 1]
            let cell = tableView.dequeueReusableCell(withIdentifier: "currency")
            ?? UITableViewCell(style: .default, reuseIdentifier: "currency")
            cell.textLabel?.text = option.title
            cell.accessoryType = option.isSelected ? .checkmark : .none
            cell.selectionStyle = .default
            return cell
        }
    }
    
    private func capabilityCell(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        let options = viewModel.capabilityOptions
        let option = options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "capability")
        ?? UITableViewCell(style: .subtitle, reuseIdentifier: "capability")
        cell.textLabel?.text = option.title
        cell.detailTextLabel?.text = option.detail
        cell.detailTextLabel?.numberOfLines = 0
        cell.accessoryType = option.isSelected ? .checkmark : .none
        cell.selectionStyle = .default
        return cell
    }

    private func installmentsCell(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        let option = viewModel.installmentToggleOption
        let cell = tableView.dequeueReusableCell(withIdentifier: "installments")
        ?? UITableViewCell(style: .default, reuseIdentifier: "installments")
        cell.selectionStyle = .none
        cell.textLabel?.text = option.title

        let toggle = UISwitch()
        toggle.isOn = option.isOn
        toggle.isEnabled = option.isEnabled
        toggle.accessibilityIdentifier = "zeroInterestInstallmentsSwitch"
        toggle.addTarget(self, action: #selector(didToggleZeroInterest(_:)), for: .valueChanged)
        cell.accessoryView = toggle
        return cell
    }
    
    private func paymentMethodCell(at indexPath: IndexPath, sectionIndex: Int, in tableView: UITableView) -> UITableViewCell {
        let option = viewModel.paymentMethodSections[sectionIndex].options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "paymentMethod")
        ?? UITableViewCell(style: .default, reuseIdentifier: "paymentMethod")
        cell.textLabel?.text = option.title
        cell.accessoryType = option.isSelected ? .checkmark : .none
        cell.textLabel?.textColor = option.isEnabled ? .label : .tertiaryLabel
        cell.selectionStyle = option.isEnabled ? .default : .none
        return cell
    }

    private func developerCell(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        let cell = dequeueTextFieldCell(in: tableView, for: indexPath)
        cell.configure(
            title: "PKey",
            text: viewModel.publicKey,
            placeholder: viewModel.publicKeyPlaceholder,
            keyboardType: .default,
            accessory: accessoryToolbar
        )
        cell.onCommit = { [weak self] text in
            self?.viewModel.updatePublicKey(text)
        }
        cell.textField.autocapitalizationType = .none
        cell.textField.autocorrectionType = .no
        cell.textField.textContentType = .username
        return cell
    }

    private func sectionDescriptor(for section: Int) -> SettingsViewModel.Section? {
        viewModel.section(at: section)
    }

    private func dequeueTextFieldCell(in tableView: UITableView, for indexPath: IndexPath) -> TextFieldTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TextFieldTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? TextFieldTableViewCell else {
            assertionFailure("Unexpected cell type for TextFieldTableViewCell")
            return TextFieldTableViewCell(style: .default, reuseIdentifier: TextFieldTableViewCell.reuseIdentifier)
        }
        return cell
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let descriptor = sectionDescriptor(for: indexPath.section) else { return }
        switch descriptor {
        case .presets:
            let preset = viewModel.presets[indexPath.row]
            viewModel.applyPreset(preset.definition)
        case .payment:
            if indexPath.row == 0 {
                if let cell = tableView.cellForRow(at: indexPath) as? TextFieldTableViewCell {
                    cell.textField.becomeFirstResponder()
                }
            } else {
                let option = viewModel.currencyOptions[indexPath.row - 1]
                viewModel.selectCurrency(option.currency)
            }
        case .capability:
            let options = viewModel.capabilityOptions
            if indexPath.row < options.count {
                viewModel.selectCapabilityMode(options[indexPath.row].mode)
            }
        case .installments:
            break
        case .paymentMethods(let sectionIndex):
            let option = viewModel.paymentMethodSections[sectionIndex].options[indexPath.row]
            if option.isEnabled {
                viewModel.togglePaymentMethod(option.method)
            }
        case .developer:
            if let cell = tableView.cellForRow(at: indexPath) as? TextFieldTableViewCell {
                cell.textField.becomeFirstResponder()
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard sectionDescriptor(for: section) == .capability else { return nil }
        let message = viewModel.capabilityInfoText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return nil }

        let footerView = UITableViewHeaderFooterView(reuseIdentifier: nil)
        footerView.contentView.backgroundColor = .clear
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        label.text = message
        
        footerView.contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: footerView.contentView.layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: footerView.contentView.layoutMarginsGuide.trailingAnchor),
            label.topAnchor.constraint(equalTo: footerView.contentView.layoutMarginsGuide.topAnchor),
            label.bottomAnchor.constraint(equalTo: footerView.contentView.layoutMarginsGuide.bottomAnchor)
        ])
        
        return footerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard sectionDescriptor(for: section) == .capability else { return UITableView.automaticDimension }
        return UITableView.automaticDimension
    }
}

extension SettingsViewController {
    @objc private func didToggleZeroInterest(_ sender: UISwitch) {
        viewModel.toggleZeroInterestInstallments(sender.isOn)
    }
}

private extension UIView {
    func currentFirstResponder() -> UIView? {
        if isFirstResponder {
            return self
        }
        for subview in subviews {
            if let responder = subview.currentFirstResponder() {
                return responder
            }
        }
        return nil
    }
}
