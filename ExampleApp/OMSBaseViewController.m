#import "OMSBaseViewController.h"
#import <ExampleApp-Swift.h>

@interface OMSBaseViewController ()

@end

@implementation OMSBaseViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *emptyImage = [Tool imageWithSize:CGSizeMake(1, 1) color:UIColor.whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:emptyImage forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundImage:emptyImage forBarMetrics:UIBarMetricsCompact];
    self.navigationController.navigationBar.shadowImage = emptyImage;
    
    UIImage *selectedModeBackgroundImage = [Tool imageWithSize:CGSizeMake(1, 41) actions:^(CGContextRef _Nonnull context) {
        CGContextSetFillColorWithColor(context, UIColor.whiteColor.CGColor);
        CGContextFillRect(context, CGRectMake(0, 0, 1, 40));
        CGContextSetFillColorWithColor(context, self.view.tintColor.CGColor);
        CGContextFillRect(context, CGRectMake(0, 40, 1, 1));
    }];
    
    [self.modeChooser setBackgroundImage:selectedModeBackgroundImage forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    UIImage *normalModeBackgroundImage = [Tool imageWithSize:CGSizeMake(1, 41) color:UIColor.whiteColor];
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
    
    NSDictionary<NSAttributedStringKey,id> *highlightedTitleAttributes =
    @{
      NSForegroundColorAttributeName: self.view.tintColor,
      NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleCallout]
      };
    NSDictionary<NSAttributedStringKey,id> *normalTitleAttributes =
    @{
      NSForegroundColorAttributeName: UIColor.darkTextColor,
      NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleCallout]
      };
    
    [self.modeChooser setTitleTextAttributes:normalTitleAttributes
                                    forState:UIControlStateNormal];
    [self.modeChooser setTitleTextAttributes:normalTitleAttributes
                                    forState:UIControlStateHighlighted];
    [self.modeChooser setTitleTextAttributes:highlightedTitleAttributes
                                    forState:UIControlStateSelected];
    [self.modeChooser setTitleTextAttributes:highlightedTitleAttributes
                                    forState:UIControlStateHighlighted | UIControlStateSelected];
    
    if ([NSLocale.currentLocale.countryCode isEqualToString:@"JP"]) {
        self.paymentAmount = Tool.japanPaymentAmount;
        self.paymentCurrencyCode = Tool.japanPaymentCurrency;
        self.allowedPaymentMethods = Tool.japanAllowedPaymentMethods;
    } else {
        self.paymentAmount = Tool.thailandPaymentAmount;
        self.paymentCurrencyCode = Tool.thailandPaymentCurrency;
        self.allowedPaymentMethods = Tool.thailandAllowedPaymentMethods;
    }
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
