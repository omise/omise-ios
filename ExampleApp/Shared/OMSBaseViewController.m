#import "OMSBaseViewController.h"
#import <ExampleApp-Swift.h>

@interface OMSBaseViewController ()

@end

@implementation OMSBaseViewController


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.usesCapabilityDataForPaymentMethods = YES;
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.usesCapabilityDataForPaymentMethods = YES;
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Workaround of iOS 12 bug on the tint color
    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
    
    [self updateUIColors];
    
    if ([[NSLocale.currentLocale objectForKey:NSLocaleCountryCode] isEqualToString:@"JP"]) {
        self.paymentAmount = Tool.japanPaymentAmount;
        self.paymentCurrencyCode = Tool.japanPaymentCurrency;
        self.allowedPaymentMethods = Tool.japanAllowedPaymentMethods;
    } else if ([[NSLocale.currentLocale objectForKey:NSLocaleCountryCode] isEqualToString:@"SG"]) {
        self.paymentAmount = Tool.singaporePaymentAmount;
        self.paymentCurrencyCode = Tool.singaporePaymentCurrency;
        self.allowedPaymentMethods = Tool.singaporeAllowedPaymentMethods;
    } else {
        self.paymentAmount = Tool.thailandPaymentAmount;
        self.paymentCurrencyCode = Tool.thailandPaymentCurrency;
        self.allowedPaymentMethods = Tool.thailandAllowedPaymentMethods;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"PresentPaymentSettingScene"]) {
        UINavigationController *settingNavigationController = (UINavigationController *)segue.destinationViewController;
        PaymentSettingTableViewController *settingViewController = (PaymentSettingTableViewController *)settingNavigationController.topViewController;
        
        settingViewController.currentAmount = self.paymentAmount;
        settingViewController.currentCurrencyCode = self.paymentCurrencyCode;
        settingViewController.usesCapabilityDataForPaymentMethods = self.usesCapabilityDataForPaymentMethods;
        settingViewController.allowedPaymentMethods = [NSSet setWithArray:self.allowedPaymentMethods];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    [self updateUIColors];
}


- (void)updateUIColors {
    UIColor *modeChooserDefaultBackgroundColor = nil;
    
#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        modeChooserDefaultBackgroundColor = UIColor.systemBackgroundColor;
    } else {
        modeChooserDefaultBackgroundColor = UIColor.whiteColor;
    }
#else
    modeChooserDefaultBackgroundColor = UIColor.whiteColor;
#endif
    
    UIImage *emptyImage = [Tool imageWithSize:CGSizeMake(1, 1) color:modeChooserDefaultBackgroundColor];
    [self.navigationController.navigationBar setBackgroundImage:emptyImage forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundImage:emptyImage forBarMetrics:UIBarMetricsCompact];
    self.navigationController.navigationBar.shadowImage = emptyImage;
    
    UIImage *selectedModeBackgroundImage = [Tool imageWithSize:CGSizeMake(1, 41) actions:^(CGContextRef _Nonnull context) {
        CGContextSetFillColorWithColor(context, modeChooserDefaultBackgroundColor.CGColor);
        CGContextFillRect(context, CGRectMake(0, 0, 1, 40));
        CGContextSetFillColorWithColor(context, self.view.tintColor.CGColor);
        CGContextFillRect(context, CGRectMake(0, 40, 1, 1));
    }];
    
    [self.modeChooser setBackgroundImage:selectedModeBackgroundImage forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    UIImage *normalModeBackgroundImage = [Tool imageWithSize:CGSizeMake(1, 41) color:modeChooserDefaultBackgroundColor];
    [self.modeChooser setBackgroundImage:normalModeBackgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.modeChooser setBackgroundImage:normalModeBackgroundImage forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [self.modeChooser setBackgroundImage:normalModeBackgroundImage forState:UIControlStateSelected | UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    [self.modeChooser setDividerImage:normalModeBackgroundImage
                  forLeftSegmentState:UIControlStateSelected
                    rightSegmentState:UIControlStateNormal
                           barMetrics:UIBarMetricsDefault];
    [self.modeChooser setDividerImage:normalModeBackgroundImage
                  forLeftSegmentState:UIControlStateNormal
                    rightSegmentState:UIControlStateSelected
                           barMetrics:UIBarMetricsDefault];
    [self.modeChooser setDividerImage:normalModeBackgroundImage
                  forLeftSegmentState:UIControlStateHighlighted
                    rightSegmentState:UIControlStateNormal
                           barMetrics:UIBarMetricsDefault];
    [self.modeChooser setDividerImage:normalModeBackgroundImage
                  forLeftSegmentState:UIControlStateNormal
                    rightSegmentState:UIControlStateHighlighted
                           barMetrics:UIBarMetricsDefault];
    [self.modeChooser setDividerImage:normalModeBackgroundImage
                  forLeftSegmentState:UIControlStateSelected
                    rightSegmentState:UIControlStateHighlighted
                           barMetrics:UIBarMetricsDefault];
    [self.modeChooser setDividerImage:normalModeBackgroundImage
                  forLeftSegmentState:UIControlStateHighlighted
                    rightSegmentState:UIControlStateSelected
                           barMetrics:UIBarMetricsDefault];
    [self.modeChooser setDividerImage:normalModeBackgroundImage
                  forLeftSegmentState:UIControlStateNormal
                    rightSegmentState:UIControlStateNormal
                           barMetrics:UIBarMetricsDefault];
    
    NSDictionary<NSAttributedStringKey,id> *highlightedTitleAttributes = @{
        NSForegroundColorAttributeName: self.view.tintColor,
        NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleCallout]
    };
    NSDictionary<NSAttributedStringKey,id> *normalTitleAttributes = nil;

#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        normalTitleAttributes = @{
            NSForegroundColorAttributeName: UIColor.labelColor,
            NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleCallout]
        };
    } else {
        normalTitleAttributes = @{
            NSForegroundColorAttributeName: UIColor.darkTextColor,
            NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleCallout]
        };
    }
#else
    normalTitleAttributes = @{
            NSForegroundColorAttributeName: UIColor.darkTextColor,
            NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleCallout]
    };
#endif
    [self.modeChooser setTitleTextAttributes:normalTitleAttributes
                                    forState:UIControlStateNormal];
    [self.modeChooser setTitleTextAttributes:normalTitleAttributes
                                    forState:UIControlStateHighlighted];
    [self.modeChooser setTitleTextAttributes:highlightedTitleAttributes
                                    forState:UIControlStateSelected];
    [self.modeChooser setTitleTextAttributes:highlightedTitleAttributes
                                    forState:UIControlStateHighlighted | UIControlStateSelected];
}

- (void)dismissForm {
    [self dismissFormWithCompletion:NULL];
}

- (void)dismissFormWithCompletion:(void (^ _Nullable)(void))completion {
    if (self.presentedViewController != nil) {
        [self dismissViewControllerAnimated:true completion:completion];
    } else {
        [self.navigationController popToViewController:self animated:true];
        if (completion) {
            completion();
        }
    }
}

- (IBAction)updatePaymentInformationFromSetting:(UIStoryboardSegue *)sender {
    if (![sender.sourceViewController isKindOfClass:[PaymentSettingTableViewController class]]) {
        return;
    }
    
    PaymentSettingTableViewController *settingViewController = (PaymentSettingTableViewController *)sender.sourceViewController;
    self.paymentAmount = settingViewController.currentAmount;
    self.paymentCurrencyCode = settingViewController.currentCurrencyCode;
    self.usesCapabilityDataForPaymentMethods = settingViewController.usesCapabilityDataForPaymentMethods;
    self.allowedPaymentMethods = settingViewController.allowedPaymentMethods.allObjects;
}

- (IBAction)codePathModeChangedHandler:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 1) {
        self.currentCodePathMode = OMSCodePathModeCode;
    } else {
        self.currentCodePathMode = OMSCodePathModeStoryboard;
    }
}

@end
