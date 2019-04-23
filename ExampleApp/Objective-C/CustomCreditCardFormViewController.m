#import "CustomCreditCardFormViewController.h"
#import <OmiseSDK/OmiseSDK.h>

@interface CustomCreditCardFormViewController ()

@property (strong, nonatomic) IBOutlet OMSCardNumberTextField *cardNumberField;
@property (strong, nonatomic) IBOutlet OMSCardNameTextField *cardNameField;
@property (strong, nonatomic) IBOutlet OMSCardExpiryDateTextField *cardExpiryField;
@property (strong, nonatomic) IBOutlet OMSCardCVVTextField *cardCVVField;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (strong) OMSSDKClient *omiseClient;

@end

@implementation CustomCreditCardFormViewController

- (void)loadView {
    [super loadView];
    
    if (!self.storyboard) {
        self.view.backgroundColor = UIColor.whiteColor;
        
        self.cardNumberField = [[OMSCardNumberTextField alloc] init];
        self.cardNumberField.translatesAutoresizingMaskIntoConstraints = false;
        self.cardNumberField.placeholder = @"1234567812345678";
        self.cardNameField = [[OMSCardNameTextField alloc] init];
        self.cardNameField.translatesAutoresizingMaskIntoConstraints = false;
        self.cardNameField.placeholder = @"John Appleseed";
        self.cardExpiryField = [[OMSCardExpiryDateTextField alloc] init];
        self.cardExpiryField.translatesAutoresizingMaskIntoConstraints = false;
        self.cardExpiryField.placeholder = @"MM/yy Date Format";
        self.cardCVVField = [[OMSCardCVVTextField alloc] init];
        self.cardCVVField.translatesAutoresizingMaskIntoConstraints = false;
        self.cardCVVField.placeholder = @"321";
        
        UILabel *cardNumberLabel = [[UILabel alloc] init];
        cardNumberLabel.text = @"Card Number";
        cardNumberLabel.translatesAutoresizingMaskIntoConstraints = false;
        UIStackView *cardNumberStackView = [[UIStackView alloc] initWithArrangedSubviews: @[cardNumberLabel, self.cardNumberField] ];
        UILabel *cardNameLabel = [[UILabel alloc] init];
        cardNameLabel.text = @"Card Name";
        cardNameLabel.translatesAutoresizingMaskIntoConstraints = false;
        UIStackView *cardNameStackView = [[UIStackView alloc] initWithArrangedSubviews: @[cardNameLabel, self.cardNameField] ];
        UILabel *cardExpiryLabel = [[UILabel alloc] init];
        cardExpiryLabel.text = @"Card Expiry";
        cardExpiryLabel.translatesAutoresizingMaskIntoConstraints = false;
        UIStackView *cardExpiryStackView = [[UIStackView alloc] initWithArrangedSubviews: @[cardExpiryLabel, self.cardExpiryField] ];
        UILabel *cardCVVLabel = [[UILabel alloc] init];
        cardCVVLabel.text = @"Card CVV";
        cardCVVLabel.translatesAutoresizingMaskIntoConstraints = false;
        UIStackView *cardCVVStackView = [[UIStackView alloc] initWithArrangedSubviews: @[cardCVVLabel, self.cardCVVField] ];
        
        UIStackView *lowerRowStackView = [[UIStackView alloc] initWithArrangedSubviews: @[cardExpiryStackView, cardCVVStackView]];
        
        cardNumberStackView.axis = UILayoutConstraintAxisVertical;
        cardNumberStackView.distribution = UIStackViewDistributionFill;
        cardNumberStackView.alignment = UIStackViewDistributionFill;
        cardNumberStackView.spacing = 10;
        cardNameStackView.axis = UILayoutConstraintAxisVertical;
        cardNameStackView.distribution = UIStackViewDistributionFill;
        cardNameStackView.alignment = UIStackViewAlignmentFill;
        cardNameStackView.spacing = 10;
        cardExpiryStackView.axis = UILayoutConstraintAxisVertical;
        cardExpiryStackView.distribution = UIStackViewDistributionFill;
        cardExpiryStackView.alignment = UIStackViewAlignmentFill;
        cardExpiryStackView.spacing = 10;
        cardCVVStackView.axis = UILayoutConstraintAxisVertical;
        cardCVVStackView.distribution = UIStackViewDistributionFill;
        cardCVVStackView.alignment = UIStackViewAlignmentFill;
        cardCVVStackView.spacing = 10;
        lowerRowStackView.axis = UILayoutConstraintAxisHorizontal;
        lowerRowStackView.distribution = UIStackViewDistributionFillEqually;
        lowerRowStackView.alignment = UIStackViewAlignmentFill;
        lowerRowStackView.spacing = 10;
        
        
        UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews: @[cardNumberStackView, cardNameStackView, lowerRowStackView] ];
        stackView.translatesAutoresizingMaskIntoConstraints = false;
        stackView.axis = UILayoutConstraintAxisVertical;
        stackView.distribution = UIStackViewDistributionFill;
        stackView.alignment = UIStackViewAlignmentFill;
        stackView.spacing = 20;
        
        [self.view addSubview:stackView];
        [NSLayoutConstraint activateConstraints:
         @[
           [stackView.leadingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor],
           [stackView.trailingAnchor  constraintEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor],
           [stackView.topAnchor  constraintEqualToAnchor:self.view.layoutMarginsGuide.topAnchor constant: 20],
           [stackView.bottomAnchor  constraintLessThanOrEqualToAnchor:self.view.layoutMarginsGuide.bottomAnchor],
           ]
         ];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.omiseClient = [[OMSSDKClient alloc] initWithPublicKey:@"pkey_test_"];
    
    if (!self.storyboard) {
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                    target:self
                                                                                    action:@selector(proceed:)];
        self.navigationItem.rightBarButtonItem = saveButton;
        self.doneButton = saveButton;
        self.navigationItem.title = @"Custom Credit Card Form";
    }
}

- (IBAction)proceed:(id)sender {
    if (!self.cardNumberField.text.length ||
        !self.cardNameField.text.length ||
        !self.cardExpiryField.text.length ||
        !self.cardCVVField.text.length) {
        return;
    }
    
    OMSTokenRequest *tokenRequest = [[OMSTokenRequest alloc] initWithName:self.cardNameField.text
                                                                   number:self.cardNumberField.text
                                                          expirationMonth:self.cardExpiryField.selectedMonth
                                                           expirationYear:self.cardExpiryField.selectedYear
                                                             securityCode:self.cardCVVField.text
                                                                     city:nil
                                                               postalCode:nil];
    
    [self.omiseClient sendTokenRequest:tokenRequest callback:^(OMSToken * _Nullable token, NSError * _Nullable error) {
        if (token) {
            [self.delegate customCreditCardFormViewController:self didSucceedWithToken:token];
        } else if (error) {
            [self.delegate customCreditCardFormViewController:self didFailWithError:error];
        }
    }];
}

@end
