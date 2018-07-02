#import "OMSExampleProductViewController.h"


NSString * const OMSPublicKey = @"pkey_test_4y7dh41kuvvawbhslxw";


@implementation OMSExampleProductViewController

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

- (IBAction)showCreditCardForm:(id)sender {
    OMSCreditCardFormViewController *creditCardFormController = [OMSCreditCardFormViewController makeCreditCardFormWithPublicKey:OMSPublicKey];
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


