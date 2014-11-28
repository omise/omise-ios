//
//  AccessOmiseViewController.h
//  Omise-iOS_Test
//
//  Created on 2014/11/28.
//  Copyright (c) 2014 Omise Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Omise.h"
#import "TokenRequest.h"
#import "Card.h"
#import "Token.h"

@interface AccessOmiseViewController : UIViewController <OmiseRequestTokenDelegate>

@property (strong, nonatomic) IBOutlet UIButton *btnToken;
@property (strong, nonatomic) IBOutlet UIButton *btnReset;

@end
