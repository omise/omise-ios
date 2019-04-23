//
//  OMSCustomCreditCardFormViewController.h
//  ExampleApp (Objective-C)
//
//  Created by Pitiphong Phongpattranont on 19/4/19.
//  Copyright © 2019 Omise. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CustomCreditCardFormViewController, OMSToken;
@protocol OMSCustomCreditCardFormViewControllerDelegate <NSObject>

- (void)customCreditCardFormViewController:(CustomCreditCardFormViewController *)controller didSucceedWithToken:(OMSToken *)token;
- (void)customCreditCardFormViewController:(CustomCreditCardFormViewController *)controller didFailWithError:(NSError *)error;

@end


@interface CustomCreditCardFormViewController : UIViewController

@property (weak, nonatomic) id<OMSCustomCreditCardFormViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
