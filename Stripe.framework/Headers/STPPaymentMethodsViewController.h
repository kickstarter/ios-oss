//
//  STPPaymentMethodsViewController.h
//  Stripe
//
//  Created by Jack Flintermann on 1/12/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "STPBackendAPIAdapter.h"
#import "STPCoreViewController.h"
#import "STPPaymentConfiguration.h"
#import "STPPaymentMethod.h"
#import "STPUserInformation.h"

NS_ASSUME_NONNULL_BEGIN

@protocol STPPaymentMethod, STPPaymentMethodsViewControllerDelegate;
@class STPPaymentContext, STPPaymentMethodsViewController, STPCustomerContext;

/**
 This view controller presents a list of payment method options to the user, 
 which they can select between. They can also add credit cards to the list. 
 
 It must be displayed inside a `UINavigationController`, so you can either 
 create a `UINavigationController` with an `STPPaymentMethodsViewController` 
 as the `rootViewController` and then present the `UINavigationController`, 
 or push a new `STPPaymentMethodsViewController` onto an existing 
 `UINavigationController`'s stack. You can also have `STPPaymentContext` do this
 for you automatically, by calling `presentPaymentMethodsViewController` 
 or `pushPaymentMethodsViewController` on it.
 */
@interface STPPaymentMethodsViewController : STPCoreViewController

/**
 The delegate for the view controller.
 
 The delegate receives callbacks when the user selects a method or cancels,
 and is responsible for dismissing the payments methods view controller when
 it is finished.
 */
@property (nonatomic, nullable, weak, readonly) id<STPPaymentMethodsViewControllerDelegate>delegate;

/**
 Creates a new payment methods view controller.

 @param paymentContext A payment context to power the view controller's view. 
 The payment context will in turn use its backend API adapter to fetch the 
 information it needs from your application.

 @return an initialized view controller.
 */
- (instancetype)initWithPaymentContext:(STPPaymentContext *)paymentContext;

/**
 Initializes a new payment methods view controller without using a 
 payment context.

 @param configuration   The configuration to use to determine what types of 
 payment method to offer your user. @see STPPaymentConfiguration.h

 @param theme           The theme to inform the appearance of the UI.
 @param customerContext The customer context the view controller will use to 
 fetch and modify its Stripe customer
 @param delegate         A delegate that will be notified when the payment
 methods view controller's selection changes.

 @return an initialized view controller.
 */
- (instancetype)initWithConfiguration:(STPPaymentConfiguration *)configuration
                                theme:(STPTheme *)theme
                      customerContext:(STPCustomerContext *)customerContext
                             delegate:(id<STPPaymentMethodsViewControllerDelegate>)delegate;

/**
 Note: Instead of providing your own backend API adapter, we recommend using
 `STPCustomerContext`, which will manage retrieving and updating a
 Stripe customer for you. @see STPCustomerContext.h
 
 Initializes a new payment methods view controller without using 
 a payment context.

 @param configuration The configuration to use to determine what types of 
 payment method to offer your user.
 @param theme         The theme to inform the appearance of the UI.
 @param apiAdapter    The API adapter to use to retrieve a customer's stored 
 payment methods and save new ones.
 @param delegate      A delegate that will be notified when the payment methods 
 view controller's selection changes.
 */
- (instancetype)initWithConfiguration:(STPPaymentConfiguration *)configuration
                                theme:(STPTheme *)theme
                           apiAdapter:(id<STPBackendAPIAdapter>)apiAdapter
                             delegate:(id<STPPaymentMethodsViewControllerDelegate>)delegate;

/**
 If you've already collected some information from your user, you can set it
 here and it'll be automatically filled out when possible/appropriate in any UI
 that the payment context creates.
*/
@property (nonatomic, strong, nullable) STPUserInformation *prefilledInformation;

/**
 A view that will be placed as the footer of the view controller when it is
 showing a list of saved payment methods to select from.

 When the footer view needs to be resized, it will be sent a
 `sizeThatFits:` call. The view should respond correctly to this method in order
 to be sized and positioned properly.
 */
@property (nonatomic, strong) UIView *paymentMethodsViewControllerFooterView;

/**
 A view that will be placed as the footer of the view controller when it is
 showing the add card view.

 When the footer view needs to be resized, it will be sent a
 `sizeThatFits:` call. The view should respond correctly to this method in order
 to be sized and positioned properly.
 */
@property (nonatomic, strong) UIView *addCardViewControllerFooterView;

/**
 If you're pushing `STPPaymentMethodsViewController` onto an existing 
 `UINavigationController`'s stack, you should use this method to dismiss it, 
 since it may have pushed an additional add card view controller onto the 
 navigation controller's stack.

 @param completion The callback to run after the view controller is dismissed. 
 You may specify nil for this parameter.
 */
- (void)dismissWithCompletion:(nullable STPVoidBlock)completion;

/**
 Use one of the initializers declared in this interface.
 */
- (instancetype)initWithTheme:(STPTheme *)theme NS_UNAVAILABLE;

/**
 Use one of the initializers declared in this interface.
 */
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

/**
 Use one of the initializers declared in this interface.
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end

/**
 An `STPPaymentMethodsViewControllerDelegate` responds when a user selects a 
 payment method from (or cancels) an `STPPaymentMethodsViewController`. In both 
 of these instances, you should dismiss the view controller (either by popping 
 it off the navigation stack, or dismissing it).
 */
@protocol STPPaymentMethodsViewControllerDelegate <NSObject>

/**
 This is called when the view controller encounters an error fetching the user's
 payment methods from its API adapter. You should dismiss the view controller 
 when this is called.

 @param paymentMethodsViewController the view controller in question
 @param error                        the error that occurred
 */
- (void)paymentMethodsViewController:(STPPaymentMethodsViewController *)paymentMethodsViewController
              didFailToLoadWithError:(NSError *)error;

/**
 This is called when the user selects or adds a payment method, so it will often
 be called immediately after calling `paymentMethodsViewController:didSelectPaymentMethod:`.
 You should dismiss the view controller when this is called.

 @param paymentMethodsViewController the view controller that has finished
 */
- (void)paymentMethodsViewControllerDidFinish:(STPPaymentMethodsViewController *)paymentMethodsViewController;

/**
 This is called when the user taps "cancel".
 You should dismiss the view controller when this is called.

 @param paymentMethodsViewController the view controller that has finished
 */
- (void)paymentMethodsViewControllerDidCancel:(STPPaymentMethodsViewController *)paymentMethodsViewController;

@optional
/**
 This is called when the user either makes a selection, or adds a new card. 
 This will be triggered after the view controller loads with the user's current 
 selection (if they have one) and then subsequently when they change their
 choice. You should use this callback to update any necessary UI in your app 
 that displays the user's currently selected payment method. You should *not* 
 dismiss the view controller at this point, instead do this in 
 `paymentMethodsViewControllerDidFinish:`. `STPPaymentMethodsViewController` 
 will also call the necessary methods on your API adapter, so you don't need to 
 call them directly during this method.

 @param paymentMethodsViewController the view controller in question
 @param paymentMethod                the selected payment method
 */
- (void)paymentMethodsViewController:(STPPaymentMethodsViewController *)paymentMethodsViewController
              didSelectPaymentMethod:(id<STPPaymentMethod>)paymentMethod;

@end

NS_ASSUME_NONNULL_END
