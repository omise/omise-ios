#import "OMSExampleProductDetailViewController.h"
#import <ExampleApp-Swift.h>


NSString * const OMSPublicKey = @"<#Omise Public Key#>";



@interface OMSExampleProductDetailViewController ()

@property (strong, nonatomic) IBOutlet UISegmentedControl *modeChooser;
@property (strong, nonatomic) IBOutlet ProductHeroImageView *heroImageView;

@property (assign, nonatomic) int64_t currentAmount;
@property (copy, nonatomic) NSString *currentCurrencyCode;
@property (copy, nonatomic) NSArray<OMSSourceTypeValue> *allowedPaymentMethods;

@end


@implementation OMSExampleProductDetailViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initializeInstance];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self initializeInstance];
    }
    return self;
}

- (void)initializeInstance {
    self.currentAmount = Tool.thailandPaymentAmount;
    self.currentCurrencyCode = Tool.thailandPaymentCurrency;
    self.allowedPaymentMethods = Tool.thailandAllowedPaymentMethods;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *emptyImage = [Tool imageWithSize:CGSizeMake(1, 1) color:UIColor.whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:emptyImage forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = emptyImage;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PresentCreditFormWithModal"]) {
        OMSCreditCardFormViewController *creditCardFormController = (OMSCreditCardFormViewController *)((UINavigationController *)segue.destinationViewController).topViewController;
        creditCardFormController.publicKey = OMSPublicKey;
        creditCardFormController.handleErrors = YES;
        creditCardFormController.delegate = self;
        
        creditCardFormController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(dismissCreditCardForm)];
    }
}

- (void)dismissCreditCardForm {
    [self dismissCreditCardFormWithCompletion:nil];
}

- (void)dismissCreditCardFormWithCompletion:(void(^)(void))completion {
    if (self.presentedViewController != nil) {
        [self dismissViewControllerAnimated:YES completion:completion];
    } else {
        [self.navigationController popToViewController:self animated:YES];
        completion();
    }
}

- (IBAction)showModalCreditCardForm:(id)sender {
  OMSCreditCardFormViewController *creditCardFormController = [OMSCreditCardFormViewController creditCardFormViewControllerWithPublicKey:OMSPublicKey];
  creditCardFormController.handleErrors = YES;
  creditCardFormController.delegate = self;
  [self showViewController:creditCardFormController sender:self];
}

- (IBAction)showCreditCardForm:(id)sender {
    OMSCreditCardFormViewController *creditCardFormController = [OMSCreditCardFormViewController creditCardFormViewControllerWithPublicKey:OMSPublicKey];
    creditCardFormController.handleErrors = YES;
    creditCardFormController.delegate = self;
    [self showViewController:creditCardFormController sender:self];
}

- (IBAction)showModalPaymentCreator:(id)sender {
  OMSCreditCardFormViewController *creditCardFormController = [OMSCreditCardFormViewController creditCardFormViewControllerWithPublicKey:OMSPublicKey];
  creditCardFormController.handleErrors = YES;
  creditCardFormController.delegate = self;
  [self showViewController:creditCardFormController sender:self];
}

- (IBAction)authorizingPayment:(UIBarButtonItem *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Authorizing Payment" message:@"Please input your given authorized URL" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:nil];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Go" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alertController.textFields.firstObject;
        NSURL *url = [[NSURL alloc] initWithString:textField.text];
        
        NSURLComponents *expectedReturnURL = [[NSURLComponents alloc] initWithString:@"http://www.example.com/orders"];
        UINavigationController *authorizingPaymentViewController = [OMSAuthorizingPaymentViewController authorizingPaymentViewControllerNavigationWithAuthorizedURL:url expectedReturnURLPatterns:@[expectedReturnURL] delegate:self];
        [self presentViewController:authorizingPaymentViewController animated:YES completion:nil];
    }]];
}



- (IBAction)codePathModeChangedHandler:(id)sender {
  
}

- (void)creditCardFormViewController:(OMSCreditCardFormViewController *)controller didSucceedWithToken:(OMSToken *)token {
    [self dismissCreditCardFormWithCompletion:^{
        [self performSegueWithIdentifier:@"CompletePayment" sender:self];
    }];
}

- (void)creditCardFormViewController:(OMSCreditCardFormViewController *)controller didFailWithError:(NSError *)error {
    [self dismissCreditCardForm];
}

- (void)authorizingPaymentViewController:(OMSAuthorizingPaymentViewController *)viewController didCompleteAuthorizingPaymentWithRedirectedURL:(NSURL *)redirectedURL {
    NSLog(@"%@", redirectedURL);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)authorizingPaymentViewControllerDidCancel:(OMSAuthorizingPaymentViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end


