//
//  ViewController.h
//  Omise-iOS
//
//  Created on 2014/11/11.
//  Copyright (c) 2014 Omise Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Omise.h"

@interface ViewController : UIViewController <OmiseRequestTokenDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextView *tvJson;
@property (strong, nonatomic) IBOutlet UITextField *tfPublicKey;

@end

