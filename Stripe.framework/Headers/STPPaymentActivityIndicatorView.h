//
//  STPPaymentActivityIndicatorView.h
//  Stripe
//
//  Created by Jack Flintermann on 5/12/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 This class can be used wherever you'd use a `UIActivityIndicatorView` and is intended to have a similar API. It renders as a spinning circle with a gap in it, similar to what you see in the App Store app or in the Apple Pay dialog when making a purchase. To change its color, set the `tintColor` property.
 */
@interface STPPaymentActivityIndicatorView : UIView

/**
 Tell the view to start or stop spinning. If `hidesWhenStopped` is true, it will fade in/out if animated is true.
 */
- (void)setAnimating:(BOOL)animating
            animated:(BOOL)animated;

/**
 Whether or not the view is animating.
 */
@property (nonatomic) BOOL animating;

/**
 If true, the view will hide when it is not spinning. Default is true.
 */
@property (nonatomic) BOOL hidesWhenStopped;

@end
