//
//  STPCoreViewController.h
//  Stripe
//
//  Created by Brian Dorfman on 1/6/17.
//  Copyright © 2017 Stripe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STPTheme;

NS_ASSUME_NONNULL_BEGIN

/**
 This is the base class for all Stripe view controllers. It is intended for use
 only by Stripe classes, you should not subclass it yourself in your app.
 
 It theming, back/cancel button management, and other shared logic for
 Stripe view controllers.
 */
@interface STPCoreViewController : UIViewController

/**
 A convenience initializer; equivalent to calling `initWithTheme:[STPTheme defaultTheme]`.
 */
- (instancetype)init;


/**
 Initializes a new view controller with the specified theme

 @param theme The theme to use to inform the view controller's visual appearance. @see STPTheme
 */
- (instancetype)initWithTheme:(STPTheme *)theme NS_DESIGNATED_INITIALIZER;


/**
 Passes through to the default UIViewController behavior for this initializer,
 and then also sets the default theme as in `init`
 */
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_DESIGNATED_INITIALIZER;

/**
 Passes through to the default UIViewController behavior for this initializer,
 and then also sets the default theme as in `init`
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

