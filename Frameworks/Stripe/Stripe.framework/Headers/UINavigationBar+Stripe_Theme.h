//
//  UINavigationBar+Stripe_Theme.h
//  Stripe
//
//  Created by Jack Flintermann on 5/17/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPTheme.h"

NS_ASSUME_NONNULL_BEGIN

/**
 This allows quickly setting the appearance of a `UINavigationBar` to match your 
 application. This is useful if you're presenting an `STPAddCardViewController` 
 or `STPPaymentMethodsViewController` inside a `UINavigationController`.
 */
@interface UINavigationBar (Stripe_Theme)

/**
 Sets the navigation bar's appearance to the desired theme. This will affect the 
 bar's `tintColor` and `barTintColor` properties, as well as the color of the 
 single-pixel line at the bottom of the navbar.

 @param theme the theme to use to style the navigation bar. @see STPTheme.h
 @deprecated Use the `stp_theme` property instead
 */
- (void)stp_setTheme:(STPTheme *)theme DEPRECATED_MSG_ATTRIBUTE("Use the `stp_theme` property.");

/**
 Sets the navigation bar's appearance to the desired theme. This will affect the bar's `tintColor` and `barTintColor` properties, as well as the color of the single-pixel line at the bottom of the navbar.
 Stripe view controllers will use their navigation bar's theme for their UIBarButtonItems instead of their own theme if it is not nil.

 @see STPTheme.h
 */
@property (nonatomic, nullable, strong) STPTheme *stp_theme;

@end

NS_ASSUME_NONNULL_END

/**
 This function should not be called directly.

 It is used by the SDK when it is built as a static library to force the
 compiler to link in category methods regardless of the integrating
 app's compiler flags.
 */
void linkUINavigationBarThemeCategory(void);
