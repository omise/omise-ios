import UIKit
import OmiseSDK

class BaseViewController: UIViewController {

    @IBOutlet private var modeChooser: UISegmentedControl!

    var paymentAmount: Int64 = 0
    var paymentCurrencyCode: String = ""
    var usesCapabilityDataForPaymentMethods = false
    var allowedPaymentMethods: [SourceType] = []
    private(set) var pkeyFromSettings: String = ""

    required init?(coder: NSCoder) {
        self.usesCapabilityDataForPaymentMethods = true
        super.init(coder: coder)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.usesCapabilityDataForPaymentMethods = true
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Workaround of iOS 12 bug on the tint color
        self.view.tintColor = nil
        self.navigationController?.navigationBar.tintColor = nil

        updateUIColors()

        let localeCountryCode: String? = {
            if #available(iOS 16, *) {
                return Locale.current.region?.identifier
            } else {
                return Locale.current.regionCode
            }
        }()

        switch localeCountryCode {
        case "JP":
            self.paymentAmount = Tool.japanPaymentAmount
            self.paymentCurrencyCode = Tool.japanPaymentCurrency
            self.allowedPaymentMethods = Tool.japanAllowedPaymentMethods
        case "SG":
            self.paymentAmount = Tool.singaporePaymentAmount
            self.paymentCurrencyCode = Tool.singaporePaymentCurrency
            self.allowedPaymentMethods = Tool.singaporeAllowedPaymentMethods
        case "MY":
            self.paymentAmount = Tool.malaysiaPaymentAmount
            self.paymentCurrencyCode = Tool.malaysiaPaymentCurrency
            self.allowedPaymentMethods = Tool.malaysiaAllowedPaymentMethods
        default:
            self.paymentAmount = Tool.thailandPaymentAmount
            self.paymentCurrencyCode = Tool.thailandPaymentCurrency
            self.allowedPaymentMethods = Tool.thailandAllowedPaymentMethods
        }
        
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (vc: Self, _) in
                vc.updateUIColors()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "PresentPaymentSettingScene",
           let settingNavigationController = segue.destination as? UINavigationController,
           let settingViewController = settingNavigationController.topViewController as? PaymentSettingTableViewController {
            settingViewController.currentAmount = self.paymentAmount
            settingViewController.currentCurrencyCode = self.paymentCurrencyCode
            settingViewController.usesCapabilityDataForPaymentMethods = self.usesCapabilityDataForPaymentMethods
            settingViewController.allowedPaymentMethods = Set(self.allowedPaymentMethods)
        }
    }
    
    @available(iOS, introduced: 8.0, deprecated: 17.0)
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateUIColors()
    }

    func updateUIColors() {
        let modeChooserDefaultBackgroundColor: UIColor = .systemBackground

        if #available(iOS 15.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            navigationBarAppearance.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.label
            ]
            self.navigationItem.scrollEdgeAppearance = navigationBarAppearance
            self.navigationItem.standardAppearance = navigationBarAppearance
            self.navigationItem.compactAppearance = navigationBarAppearance

        } else {
            let emptyImage = Tool.imageWith(size: CGSize(width: 1.0, height: 1.0),
                                            color: modeChooserDefaultBackgroundColor)
            self.navigationController?.navigationBar.setBackgroundImage(emptyImage, for: .any, barMetrics: .default)
            self.navigationController?.navigationBar.setBackgroundImage(emptyImage, for: .any, barMetrics: .compact)
            self.navigationController?.navigationBar.shadowImage = emptyImage
        }

        let selectedModeBackgroundImage = Tool.imageWith(size: CGSize(width: 1.0, height: 1.0)) { context in
            context.setFillColor(modeChooserDefaultBackgroundColor.cgColor)
            context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 40.0))
            context.setFillColor(self.view.tintColor.cgColor)
            context.fill(CGRect(x: 0.0, y: 40.0, width: 1.0, height: 1.0))
        }

        self.modeChooser.setBackgroundImage(selectedModeBackgroundImage, for: .selected, barMetrics: .default)

        let normalModeBackgroundImage = Tool.imageWith(size: CGSize(width: 1.0, height: 41.0), color: modeChooserDefaultBackgroundColor)

        self.modeChooser.setBackgroundImage(normalModeBackgroundImage, for: .normal, barMetrics: .default)
        self.modeChooser.setBackgroundImage(normalModeBackgroundImage, for: .highlighted, barMetrics: .default)

        self.modeChooser.setDividerImage(normalModeBackgroundImage, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        self.modeChooser.setDividerImage(normalModeBackgroundImage, forLeftSegmentState: .normal, rightSegmentState: .selected, barMetrics: .default)
        self.modeChooser.setDividerImage(normalModeBackgroundImage, forLeftSegmentState: .highlighted, rightSegmentState: .normal, barMetrics: .default)
        self.modeChooser.setDividerImage(normalModeBackgroundImage, forLeftSegmentState: .normal, rightSegmentState: .highlighted, barMetrics: .default)
        self.modeChooser.setDividerImage(normalModeBackgroundImage, forLeftSegmentState: .highlighted, rightSegmentState: .selected, barMetrics: .default)
        self.modeChooser.setDividerImage(normalModeBackgroundImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)

        let highlightedTitleAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: self.view.tintColor ?? UIColor.lightGray,
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .callout)
        ]

        var normalTitleAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.darkText,
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .callout)
        ]
        normalTitleAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.label,
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .callout)
        ]

        self.modeChooser.setTitleTextAttributes(normalTitleAttributes, for: .normal)
        self.modeChooser.setTitleTextAttributes(normalTitleAttributes, for: .highlighted)
        self.modeChooser.setTitleTextAttributes(highlightedTitleAttributes, for: .selected)
    }

    func dismissForm(_ completion: (() -> Void)? = nil) {
        if self.presentedViewController != nil {
            self.dismiss(animated: true, completion: completion)
        } else {
            self.navigationController?.popToViewController(self, animated: true)
            completion?()
        }
    }

    @IBAction private func updatePaymentInformationFromSetting(_ sender: UIStoryboardSegue) {

        guard let settingViewController = sender.source as? PaymentSettingTableViewController else {
            return
        }

        self.paymentAmount = settingViewController.currentAmount
        self.paymentCurrencyCode = settingViewController.currentCurrencyCode
        self.usesCapabilityDataForPaymentMethods = settingViewController.usesCapabilityDataForPaymentMethods
        self.allowedPaymentMethods = Array(settingViewController.allowedPaymentMethods)
        self.pkeyFromSettings = settingViewController.pkey
    }
}
