//
//  CheckoutViewController.h
//  Omise-iOS_Test
//
//  Created on 2014/11/26.
//  Copyright (c) 2014 Omise Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckoutViewController : UIViewController{
    
}
@property (strong, nonatomic) IBOutlet UILabel *lblIslandNum;
@property (strong, nonatomic) IBOutlet UILabel *lblPrice;

+(void)setIslandNum:(int)_islandNum;
+(void)setIsClosing:(BOOL)_isClosing;

@end
