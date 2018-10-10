#import <UIKit/UIKit.h>
@import OmiseSDK;


typedef NS_ENUM(NSInteger, OMSCodePathMode) {
    OMSCodePathModeStoryboard,
    OMSCodePathModeCode
};

@class ProductHeroImageView;


NS_ASSUME_NONNULL_BEGIN

@interface OMSBaseViewController : UIViewController

@property (assign, nonatomic) OMSCodePathMode currentCodePathMode;

@property (assign, nonatomic) int64_t paymentAmount;
@property (strong, nonatomic) NSString *paymentCurrencyCode;
@property (strong, nonatomic) NSArray<OMSSourceTypeValue> *allowedPaymentMethods;

@property (strong, nonatomic) IBOutlet ProductHeroImageView  *heroImageView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *modeChooser;


- (void)dismissForm;
- (void)dismissFormWithCompletion:(void (^ _Nullable)(void))completion;
- (IBAction)updatePaymentInformationFromSetting:(UIStoryboardSegue *)sender;
- (IBAction)codePathModeChangedHandler:(UISegmentedControl *)sender;

@end

NS_ASSUME_NONNULL_END
