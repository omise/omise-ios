#import "OMSExampleProductDetailViewController.h"
#import <ExampleApp-Swift.h>


NSString * const OMSPublicKey = @"<#Omise Public Key#>";



@interface OMSExampleProductDetailViewController () <OMSCreditCardFormViewControllerDelegate,
OMSAuthorizingPaymentViewControllerDelegate, OMSPaymentCreatorControllerDelegate>

@end


@implementation OMSExampleProductDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *emptyImage = [Tool imageWithSize:CGSizeMake(1, 1) color:UIColor.whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:emptyImage forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = emptyImage;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"PresentCreditFormWithModal"]
        || [identifier isEqualToString:@"ShowCreditForm"]
            || [identifier isEqualToString:@"PresentPaymentCreator"]) {
        return self.currentCodePathMode == OMSCodePathModeStoryboard;
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PresentCreditFormWithModal"]) {
        OMSCreditCardFormViewController *creditCardFormController = (OMSCreditCardFormViewController *)((UINavigationController *)segue.destinationViewController).topViewController;
        creditCardFormController.publicKey = OMSPublicKey;
        creditCardFormController.handleErrors = YES;
        creditCardFormController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"ShowCreditForm"]) {
        OMSCreditCardFormViewController *creditCardFormController = (OMSCreditCardFormViewController *)segue.destinationViewController;
        creditCardFormController.publicKey = OMSPublicKey;
        creditCardFormController.handleErrors = YES;
        creditCardFormController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"PresentPaymentCreator"]) {
        OMSPaymentCreatorController *paymentCreatorController = (OMSPaymentCreatorController *)segue.destinationViewController;
        paymentCreatorController.publicKey = OMSPublicKey;
        paymentCreatorController.paymentAmount = self.paymentAmount;
        paymentCreatorController.paymentCurrencyCode = self.paymentCurrencyCode;
        paymentCreatorController.allowedPaymentMethods = self.allowedPaymentMethods;
        paymentCreatorController.paymentDelegate = self;
    } else if ([segue.identifier isEqualToString:@"PresentPaymentSettingScene"]) {
        PaymentSettingTableViewController *settingViewController = (PaymentSettingTableViewController *)((UINavigationController *)segue.destinationViewController).topViewController;
        settingViewController.currentAmount = self.paymentAmount;
        settingViewController.currentCurrencyCode = self.paymentCurrencyCode;
        settingViewController.allowedPaymentMethods = [NSSet setWithArray:self.allowedPaymentMethods];
    }
}

- (IBAction)showModalCreditCardForm:(id)sender {
    if (self.currentCodePathMode == OMSCodePathModeStoryboard) {
        return;
    }
    OMSCreditCardFormViewController *creditCardFormController = [OMSCreditCardFormViewController creditCardFormViewControllerWithPublicKey:OMSPublicKey];
    creditCardFormController.handleErrors = YES;
    creditCardFormController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:creditCardFormController];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

- (IBAction)showCreditCardForm:(id)sender {
    if (self.currentCodePathMode == OMSCodePathModeStoryboard) {
        return;
    }
    OMSCreditCardFormViewController *creditCardFormController = [OMSCreditCardFormViewController creditCardFormViewControllerWithPublicKey:OMSPublicKey];
    creditCardFormController.handleErrors = YES;
    creditCardFormController.delegate = self;
    [self showViewController:creditCardFormController sender:self];
}

- (IBAction)showModalPaymentCreator:(id)sender {
    if (self.currentCodePathMode == OMSCodePathModeStoryboard) {
        return;
    }
    OMSPaymentCreatorController *paymentCreatorController = [OMSPaymentCreatorController
                                                             paymentCreatorControllerWithPublicKey:OMSPublicKey amount:self.paymentAmount currency:self.paymentCurrencyCode allowedPaymentMethods:self.allowedPaymentMethods paymentDelegate:self];
    [self presentViewController:paymentCreatorController animated:YES completion:NULL];
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


#pragma mark - Credit Card Form Controller Delegate methods

- (void)creditCardFormViewController:(OMSCreditCardFormViewController *)controller didSucceedWithToken:(OMSToken *)token {
    [self dismissFormWithCompletion:^{
        [self performSegueWithIdentifier:@"CompletePayment" sender:self];
    }];
}

- (void)creditCardFormViewController:(OMSCreditCardFormViewController *)controller didFailWithError:(NSError *)error {
    [self dismissForm];
}

- (void)creditCardFormViewControllerDidCancel:(OMSCreditCardFormViewController *)controller {
    [self dismissForm];
}


#pragma mark - Payment Creator Controller Delegate methods

- (void)authorizingPaymentViewController:(OMSAuthorizingPaymentViewController *)viewController didCompleteAuthorizingPaymentWithRedirectedURL:(NSURL *)redirectedURL {
    NSLog(@"%@", redirectedURL);
    [self dismissForm];
}

- (void)authorizingPaymentViewControllerDidCancel:(OMSAuthorizingPaymentViewController *)viewController {
    [self dismissForm];
}


#pragma mark - Payment Creator Controller Delegate methods

- (void)paymentCreatorControllerDidCancel:(OMSPaymentCreatorController *)paymentCreatorController {
    [self dismissForm];
}

- (void)paymentCreatorController:(OMSPaymentCreatorController *)paymentCreatorController didCreateToken:(OMSToken *)token {
    [self dismissForm];
}

- (void)paymentCreatorController:(OMSPaymentCreatorController *)paymentCreatorController didCreateSource:(OMSSource * _Nonnull)source {
    [self dismissForm];
}

- (void)paymentCreatorController:(OMSPaymentCreatorController *)paymentCreatorController didFailWithError:(NSError *)error {
    [self dismissForm];
}



@end


