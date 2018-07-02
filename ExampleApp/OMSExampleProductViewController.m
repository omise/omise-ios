#import "OMSExampleProductViewController.h"


NSString * const OMSPublicKey = @"pkey_test_4y7dh41kuvvawbhslxw";


@implementation OMSExampleProductViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PresentCreditFormWithModal"]) {
        CreditCardFormController *creditCardFormController = (CreditCardFormController *)((UINavigationController *)segue.destinationViewController).topViewController;
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
    CreditCardFormController *creditCardFormController = [CreditCardFormController makeCreditCardFormWithPublicKey:OMSPublicKey];
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
        UINavigationController *authorizingPaymentViewController = [OmiseAuthorizingPaymentViewController makeAuthorizingPaymentViewControllerNavigationWithAuthorizedURL:url expectedReturnURLPatterns:@[expectedReturnURL] delegate:self];
        [self presentViewController:authorizingPaymentViewController animated:YES completion:nil];
    }]];
}

- (void)creditCardForm:(CreditCardFormController *)controller didSucceedWithToken:(OMSToken *)token {
    [self dismissCreditCardFormWithCompletion:^{
        [self performSegueWithIdentifier:@"CompletePayment" sender:self];
    }];
}

- (void)creditCardForm:(CreditCardFormController *)controller didFailWithError:(NSError *)error {
    [self dismissCreditCardForm];
}

- (void)omiseAuthorizingPaymentViewController:(OmiseAuthorizingPaymentViewController *)viewController didCompleteAuthorizingPaymentWithRedirectedURL:(NSURL *)redirectedURL {
    NSLog(@"%@", redirectedURL);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)omiseAuthorizingPaymentViewControllerDidCancel:(OmiseAuthorizingPaymentViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end


